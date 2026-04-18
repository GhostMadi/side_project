import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/chat_thread_cache_storage.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';
import 'package:side_project/feature/chat/domain/chat_outgoing_attachment.dart';
import 'package:side_project/feature/chat/presentation/models/chat_optimistic_delivery.dart';
import 'package:side_project/feature/chat/presentation/models/chat_optimistic_outgoing_part.dart';
import 'package:side_project/feature/chat/presentation/models/chat_thread_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_thread_cubit.freezed.dart';

@freezed
abstract class ChatThreadState with _$ChatThreadState {
  const factory ChatThreadState.initial() = _ChatThreadInitial;
  const factory ChatThreadState.loading() = _ChatThreadLoading;
  const factory ChatThreadState.loaded({
    required String conversationId,
    @Default(<ChatThreadItem>[]) List<ChatThreadItem> items,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    String? errorMessage,
    /// Счётчик синхронизации: Bloc не эмитит при равном глубоком [items]; инкремент при любом ответе сервера.
    @Default(0) int viewRevision,
  }) = _ChatThreadLoaded;
  const factory ChatThreadState.error(String message) = _ChatThreadError;
}

@injectable
class ChatThreadCubit extends Cubit<ChatThreadState> {
  final ChatRepository _repo;
  final SupabaseClient _client;
  final ChatThreadCacheStorage _cache;

  /// Окно видимых сообщений + буфер под merge realtime без лишних обрезаний.
  static const _messageWindow = 40;
  static const _realtimeMergeBuffer = 10;
  static const _fetchLimit = _messageWindow + _realtimeMergeBuffer;
  /// Резерв, если Realtime недоступен.
  static const _safetyPollInterval = Duration(seconds: 18);
  /// Пока недавно был трафик по сокету — полный refresh не делаем (см. safety poll).
  static const _safetyPollSkipAfterRealtime = Duration(seconds: 55);
  /// Одна повторная попытка get_message_enriched (лаг коммита); дальше — один refresh.
  static const _mergeRetryDelay = Duration(milliseconds: 60);
  static const _debounceRealtimeRefresh = Duration(milliseconds: 140);

  RealtimeChannel? _channel;
  Timer? _debounceReload;
  Timer? _safetyPoll;
  DateTime? _lastThreadRealtimeActivityAt;

  ChatThreadCubit(this._repo, this._client, this._cache) : super(const ChatThreadState.initial());

  static String _localId() => 'local_${DateTime.now().microsecondsSinceEpoch}';

  /// Детерминированный порядок: одинаковый created_at возможен — различаем по id.
  static int _compareEnrichedMessages(ChatMessageEnriched a, ChatMessageEnriched b) {
    final byTime = a.message.createdAt.compareTo(b.message.createdAt);
    if (byTime != 0) return byTime;
    return a.message.id.compareTo(b.message.id);
  }

  void _bumpThreadRealtimeActivity() {
    _lastThreadRealtimeActivityAt = DateTime.now();
  }

  ChatThreadState _withServerViewRevision(ChatThreadState? previous, ChatThreadState next) {
    final prevRev = previous?.maybeMap(loaded: (l) => l.viewRevision, orElse: () => null);
    final gen = (prevRev ?? 0) + 1;
    return next.maybeMap(
      loaded: (l) => l.copyWith(viewRevision: gen),
      orElse: () => next,
    );
  }

  /// Следующий `list_messages_enriched` может прийти без новой строки (лаг реплики). Объединяем с тем,
  /// что уже показано, иначе refresh «съедает» сообщение, которое только что докинули через Realtime/merge.
  List<ChatMessageEnriched> _mergeFetchedWithVisibleServer(
    _ChatThreadLoaded visible,
    List<ChatMessageEnriched> fetched,
  ) {
    final byId = <String, ChatMessageEnriched>{};
    for (final it in visible.items) {
      it.maybeWhen(
        server: (d) => byId[d.message.id] = d,
        orElse: () {},
      );
    }
    for (final m in fetched) {
      byId[m.message.id] = m;
    }
    final merged = byId.values.toList()..sort(_compareEnrichedMessages);
    if (merged.length <= _fetchLimit) return merged;
    return merged.sublist(merged.length - _fetchLimit);
  }

  Future<void> load(String conversationId) async {
    final cid = conversationId.trim();
    if (cid.isEmpty) {
      emit(const ChatThreadState.error('Пустой conversationId'));
      return;
    }
    _lastThreadRealtimeActivityAt = null;
    final uid = _client.auth.currentUser?.id.trim();
    if (uid != null && uid.isNotEmpty) {
      final cached = await _cache.read(userId: uid, conversationId: cid);
      if (cached != null && cached.isNotEmpty) {
        emit(
          ChatThreadState.loaded(
            conversationId: cid,
            items: cached.map(ChatThreadItem.server).toList(growable: false),
            hasMore: cached.length >= _fetchLimit,
          ),
        );
      } else {
        emit(const ChatThreadState.loading());
      }
    } else {
      emit(const ChatThreadState.loading());
    }
    try {
      final list = await _repo.listMessages(conversationId: cid, limit: _fetchLimit);
      final current = state.maybeMap(loaded: (v) => v, orElse: () => null);
      late final List<ChatMessageEnriched> serverSnapshotForPersistence;
      if (current != null) {
        final mergedList = _mergeFetchedWithVisibleServer(current, list);
        serverSnapshotForPersistence = mergedList;
        emit(_withServerViewRevision(state, _reconcileWithOptimistic(current, mergedList)));
      } else {
        serverSnapshotForPersistence = list;
        emit(
          _withServerViewRevision(
            state,
            ChatThreadState.loaded(
              conversationId: cid,
              items: list.map(ChatThreadItem.server).toList(growable: false),
              hasMore: list.length >= _fetchLimit,
            ),
          ),
        );
      }
      _subscribeRealtime(cid);
      _startSafetyPoll(cid);
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(userId: uid, conversationId: cid, messages: serverSnapshotForPersistence));
      }
      // Mark read best-effort.
      if (serverSnapshotForPersistence.isNotEmpty) {
        unawaited(_repo.markRead(conversationId: cid, lastMessageId: serverSnapshotForPersistence.last.message.id));
      } else {
        unawaited(_repo.markRead(conversationId: cid));
      }
    } catch (e) {
      emit(ChatThreadState.error('$e'));
    }
  }

  Future<void> refresh() async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    final cid = s.conversationId.trim();
    try {
      final list = await _repo.listMessages(conversationId: cid, limit: _fetchLimit);
      final cur = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (cur == null || cur.conversationId.trim() != cid) return;
      final mergedList = _mergeFetchedWithVisibleServer(cur, list);
      emit(_withServerViewRevision(state, _reconcileWithOptimistic(cur, mergedList)));
      final uid = _client.auth.currentUser?.id.trim();
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(userId: uid, conversationId: cid, messages: mergedList));
      }
      if (mergedList.isNotEmpty) {
        unawaited(_repo.markRead(conversationId: cid, lastMessageId: mergedList.last.message.id));
      }
    } catch (e) {
      final again = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (again != null && again.conversationId.trim() == cid) {
        emit(again.copyWith(errorMessage: '$e'));
      }
    }
  }

  Future<void> loadMore() async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null || s.isLoadingMore || !s.hasMore) return;
    emit(s.copyWith(isLoadingMore: true));
    try {
      final serverItems = s.items.where((e) => e.maybeWhen(server: (_) => true, orElse: () => false)).toList();
      final before = serverItems.isEmpty
          ? null
          : serverItems.first.maybeWhen(
              server: (d) => d.message.createdAt,
              orElse: () => null,
            );
      final older = await _repo.listMessages(
        conversationId: s.conversationId,
        limit: _fetchLimit,
        before: before,
      );
      final merged = [
        ...older.map(ChatThreadItem.server),
        ...s.items,
      ];
      emit(_withServerViewRevision(
        state,
        s.copyWith(
          items: merged,
          isLoadingMore: false,
          hasMore: older.length >= _fetchLimit,
        ),
      ));
    } catch (e) {
      emit(s.copyWith(isLoadingMore: false, errorMessage: '$e'));
    }
  }

  /// Оптимистичная отправка: сразу добавляем bubble; RPC уходит в фоне (композер не ждёт сеть).
  Future<void> optimisticSendText(String text) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    final t = text.trim();

    final localId = _localId();
    final optimistic = ChatThreadItem.optimisticText(
      localId: localId,
      conversationId: s.conversationId,
      text: t,
      createdAt: DateTime.now(),
      delivery: ChatOptimisticDelivery.sending,
    );
    emit(s.copyWith(items: [...s.items, optimistic], errorMessage: null));
    unawaited(_completeOptimisticTextSend(localId: localId, text: t, conversationId: s.conversationId));
  }

  /// Фото / видео / файлы / голос — сразу в ленте; RPC в фоне.
  Future<void> optimisticSendAttachments({
    required List<ChatOutgoingAttachment> outgoing,
    String? caption,
  }) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null || outgoing.isEmpty) return;

    final localId = _localId();
    final parts = outgoing
        .map(
          (o) => ChatOptimisticOutgoingPart(
            filename: o.filename,
            mimeType: o.mimeType,
            bytes: o.bytes,
          ),
        )
        .toList(growable: false);

    final optimistic = ChatThreadItem.optimisticAttachments(
      localId: localId,
      conversationId: s.conversationId,
      createdAt: DateTime.now(),
      parts: parts,
      caption: caption,
      delivery: ChatOptimisticDelivery.sending,
    );
    emit(s.copyWith(items: [...s.items, optimistic], errorMessage: null));
    unawaited(
      _completeOptimisticAttachmentsSend(
        localId: localId,
        conversationId: s.conversationId,
        outgoing: outgoing,
        caption: caption,
      ),
    );
  }

  Future<void> _completeOptimisticAttachmentsSend({
    required String localId,
    required String conversationId,
    required List<ChatOutgoingAttachment> outgoing,
    String? caption,
  }) async {
    try {
      await _repo.sendMessageWithAttachments(
        conversationId: conversationId,
        caption: caption,
        parts: outgoing,
      );
      final curAck = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (curAck != null) {
        emit(
          curAck.copyWith(
            items: [
              for (final it in curAck.items)
                it.maybeWhen(
                  optimisticAttachments: (id, cid, ca, parts, cap, srv, delivery) => id == localId
                      ? ChatThreadItem.optimisticAttachments(
                          localId: id,
                          conversationId: cid,
                          createdAt: ca,
                          parts: parts,
                          caption: cap,
                          server: srv,
                          delivery: ChatOptimisticDelivery.ack,
                        )
                      : it,
                  orElse: () => it,
                ),
            ],
            errorMessage: null,
          ),
        );
      }
      // Полный list не дергаем: подтверждение придёт через Realtime INSERT → merge (или reconcile с сервером).
    } catch (e) {
      final cur = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (cur == null) return;
      final next = [
        for (final it in cur.items)
          it.maybeWhen(
            optimisticAttachments: (id, cid, ca, parts, cap, srv, delivery) => id == localId
                ? ChatThreadItem.optimisticAttachments(
                    localId: id,
                    conversationId: cid,
                    createdAt: ca,
                    parts: parts,
                    caption: cap,
                    server: srv,
                    delivery: ChatOptimisticDelivery.failed,
                  )
                : it,
            orElse: () => it,
          ),
      ];
      emit(cur.copyWith(items: next, errorMessage: null));
    }
  }

  Future<void> _completeOptimisticTextSend({
    required String localId,
    required String text,
    required String conversationId,
  }) async {
    try {
      await _repo.sendText(conversationId: conversationId, text: text);
      final curAck = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (curAck != null) {
        emit(
          curAck.copyWith(
            items: [
              for (final it in curAck.items)
                it.maybeWhen(
                  optimisticText: (id, cid, txt, ca, srv, delivery) => id == localId
                      ? ChatThreadItem.optimisticText(
                          localId: id,
                          conversationId: cid,
                          text: txt,
                          createdAt: ca,
                          server: srv,
                          delivery: ChatOptimisticDelivery.ack,
                        )
                      : it,
                  orElse: () => it,
                ),
            ],
            errorMessage: null,
          ),
        );
      }
      // Без refresh после send: Realtime доставит строку; иначе сработает safety poll / pull.
    } catch (e) {
      final cur = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (cur == null) return;
      final next = [
        for (final it in cur.items)
          it.maybeWhen(
            optimisticText: (id, cid, txt, ca, srv, delivery) => id == localId
                ? ChatThreadItem.optimisticText(
                    localId: id,
                    conversationId: cid,
                    text: txt,
                    createdAt: ca,
                    server: srv,
                    delivery: ChatOptimisticDelivery.failed,
                  )
                : it,
            orElse: () => it,
          ),
      ];
      emit(cur.copyWith(items: next, errorMessage: null));
    }
  }

  Future<void> retryPending(String localId) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    String? text;
    for (final it in s.items) {
      it.when(
        server: (_) {},
        optimisticText: (id, _, t, __, ___, ____) {
          if (id == localId) text = t;
        },
        optimisticAttachments: (_, __, ___, ____, _____, ______, _______) {},
      );
      if (text != null) break;
    }
    if (text == null) return;
    // Remove old optimistic, re-send.
    emit(s.copyWith(
      items: s.items
          .where(
            (e) => e.maybeWhen(optimisticText: (id, __, ___, ____, _____, ______) => id != localId, orElse: () => true),
          )
          .toList(),
    ));
    await optimisticSendText(text!);
  }

  ChatThreadState _reconcileWithOptimistic(_ChatThreadLoaded prev, List<ChatMessageEnriched> serverMessages) {
    final myId = _client.auth.currentUser?.id;

    final optimistic = <ChatThreadItem>[];
    for (final it in prev.items) {
      it.when(
        server: (_) {},
        optimisticText: (localId, conversationId, text, createdAt, server, delivery) {
          optimistic.add(
            ChatThreadItem.optimisticText(
              localId: localId,
              conversationId: conversationId,
              text: text,
              createdAt: createdAt,
              server: server,
              delivery: delivery,
            ),
          );
        },
        optimisticAttachments: (localId, conversationId, createdAt, parts, caption, server, delivery) {
          optimistic.add(
            ChatThreadItem.optimisticAttachments(
              localId: localId,
              conversationId: conversationId,
              createdAt: createdAt,
              parts: parts,
              caption: caption,
              server: server,
              delivery: delivery,
            ),
          );
        },
      );
    }

    // Build mutable list of server entries.
    final server = prev.copyWith(
      items: serverMessages.map(ChatThreadItem.server).toList(),
      hasMore: serverMessages.length >= _fetchLimit,
      errorMessage: null,
    );

    // If no optimistic — done.
    if (optimistic.isEmpty || myId == null) return server;

    // Extract server list for matching and "consume" matches so we don't duplicate.
    final serverList = server.items.toList();
    final usedServerIds = <String>{};

    ChatThreadItem attachIfMatch(ChatThreadItem opt) {
      return opt.maybeWhen(
        optimisticText: (localId, conversationId, text, createdAt, attached, delivery) {
          if (delivery == ChatOptimisticDelivery.failed) return opt;
          if (attached != null) return opt;

          int bestIdx = -1;
          int bestDeltaMs = 1 << 30;

          for (var i = 0; i < serverList.length; i++) {
            final sItem = serverList[i];
            final data = sItem.maybeWhen(server: (d) => d, orElse: () => null);
            if (data == null) continue;
            if (usedServerIds.contains(data.message.id)) continue;
            if (data.message.senderId != myId) continue;
            if (data.message.kind != 'text') continue;
            if ((data.message.text ?? '') != text) continue;

            final dt = (data.message.createdAt).difference(createdAt).inMilliseconds.abs();
            if (dt <= 30000 && dt < bestDeltaMs) {
              bestDeltaMs = dt;
              bestIdx = i;
            }
          }

          if (bestIdx >= 0) {
            final matched = serverList[bestIdx].when(
              server: (d) => d,
              optimisticText: (_, __, ___, ____, _____, ______) =>
                  throw StateError('unexpected optimistic in serverList'),
              optimisticAttachments: (_, __, ___, ____, _____, ______, _______) =>
                  throw StateError('unexpected optimistic in serverList'),
            );
            usedServerIds.add(matched.message.id);
            return ChatThreadItem.optimisticText(
              localId: localId,
              conversationId: conversationId,
              text: text,
              createdAt: createdAt,
              server: matched,
              delivery: ChatOptimisticDelivery.synced,
            );
          }

          return opt;
        },
        optimisticAttachments: (localId, conversationId, createdAt, parts, caption, attached, delivery) {
          if (delivery == ChatOptimisticDelivery.failed) return opt;
          if (attached != null) return opt;

          int bestIdx = -1;
          int bestDeltaMs = 1 << 30;

          for (var i = 0; i < serverList.length; i++) {
            final sItem = serverList[i];
            final data = sItem.maybeWhen(server: (d) => d, orElse: () => null);
            if (data == null) continue;
            if (usedServerIds.contains(data.message.id)) continue;
            if (data.message.senderId != myId) continue;
            if (data.attachments.length != parts.length) continue;

            final dt = (data.message.createdAt).difference(createdAt).inMilliseconds.abs();
            if (dt <= 120000 && dt < bestDeltaMs) {
              bestDeltaMs = dt;
              bestIdx = i;
            }
          }

          if (bestIdx >= 0) {
            final matched = serverList[bestIdx].when(
              server: (d) => d,
              optimisticText: (_, __, ___, ____, _____, ______) =>
                  throw StateError('unexpected optimistic in serverList'),
              optimisticAttachments: (_, __, ___, ____, _____, ______, _______) =>
                  throw StateError('unexpected optimistic in serverList'),
            );
            usedServerIds.add(matched.message.id);
            return ChatThreadItem.optimisticAttachments(
              localId: localId,
              conversationId: conversationId,
              createdAt: createdAt,
              parts: parts,
              caption: caption,
              server: matched,
              delivery: ChatOptimisticDelivery.synced,
            );
          }

          return opt;
        },
        orElse: () => opt,
      );
    }

    final updatedOptimistic = optimistic.map(attachIfMatch).toList();

    // Remove server messages that were attached to optimistic (avoid duplicates).
    final filteredServer = <ChatThreadItem>[];
    for (final it in server.items) {
      final data = it.maybeWhen(server: (d) => d, orElse: () => null);
      if (data != null && usedServerIds.contains(data.message.id)) continue;
      filteredServer.add(it);
    }

    // Final list = server (filtered) + optimistic (keeps stable keys/position).
    return prev.copyWith(
      items: [...filteredServer, ...updatedOptimistic],
      hasMore: serverMessages.length >= _fetchLimit,
      errorMessage: null,
    );
  }

  /// Новое сообщение из Realtime: одна строка через RPC — без полного списка и без лишних POST.
  Future<void> _mergeIncomingMessageRow(String messageId, {int attempt = 0}) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    final conversationId = s.conversationId.trim();

    var row = await _repo.getMessageEnriched(messageId);
    if (row == null && attempt == 0) {
      await Future<void>.delayed(_mergeRetryDelay);
      if (isClosed) return;
      await _mergeIncomingMessageRow(messageId, attempt: 1);
      return;
    }
    if (row == null) {
      await refresh();
      return;
    }

    if (row.message.conversationId.trim() != conversationId) return;

    final live = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (live == null || live.conversationId.trim() != conversationId) return;

    final serverMsgs = <ChatMessageEnriched>[];
    for (final it in live.items) {
      it.maybeWhen(
        server: (d) => serverMsgs.add(d),
        orElse: () {},
      );
    }
    if (serverMsgs.any((m) => m.message.id == row.message.id)) return;

    serverMsgs.add(row);
    serverMsgs.sort(_compareEnrichedMessages);
    while (serverMsgs.length > _fetchLimit) {
      serverMsgs.removeAt(0);
    }

    final emitBase = state;
    emit(_withServerViewRevision(emitBase, _reconcileWithOptimistic(live, serverMsgs)));

    final uid = _client.auth.currentUser?.id.trim();
    if (uid != null && uid.isNotEmpty) {
      unawaited(_cache.write(userId: uid, conversationId: conversationId, messages: serverMsgs));
    }
    // Не блокируем появление пузыря — прочитано уходит после отрисовки.
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (isClosed) return;
        unawaited(_repo.markRead(conversationId: conversationId, lastMessageId: row.message.id));
      }),
    );
  }

  void _startSafetyPoll(String conversationId) {
    _safetyPoll?.cancel();
    final cid = conversationId.trim();
    if (cid.isEmpty) return;
    _safetyPoll = Timer.periodic(_safetyPollInterval, (_) {
      if (isClosed) return;
      final loaded = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (loaded == null || loaded.conversationId.trim() != cid) return;
      final last = _lastThreadRealtimeActivityAt;
      if (last != null && DateTime.now().difference(last) < _safetyPollSkipAfterRealtime) {
        return;
      }
      unawaited(refresh());
    });
  }

  void _subscribeRealtime(String conversationId) {
    _channel?.unsubscribe();
    final cidNorm = conversationId.trim().toLowerCase();
    _channel = _client.channel('chat_thread_$conversationId');

    bool messageBelongsToThread(PostgresChangePayload payload) {
      final fromNew = payload.newRecord['conversation_id'];
      final fromOld = payload.oldRecord['conversation_id'];
      final raw = fromNew ?? fromOld;
      if (raw == null) return false;
      return raw.toString().trim().toLowerCase() == cidNorm;
    }

    void onMessagesChange(PostgresChangePayload payload) {
      if (!messageBelongsToThread(payload)) return;
      _bumpThreadRealtimeActivity();
      if (payload.eventType == PostgresChangeEvent.insert) {
        final rawId = payload.newRecord['id'];
        if (rawId != null) {
          unawaited(_mergeIncomingMessageRow(rawId.toString()));
        }
        return;
      }
      _scheduleDebouncedFullRefresh();
    }

    _channel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: onMessagesChange,
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_reactions',
        callback: (_) => _scheduleDebouncedFullRefresh(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_attachments',
        callback: (_) => _scheduleDebouncedFullRefresh(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_post_refs',
        callback: (_) => _scheduleDebouncedFullRefresh(),
      );

    _channel!.subscribe((status, _) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _bumpThreadRealtimeActivity();
      }
    });
  }

  void _scheduleDebouncedFullRefresh() {
    _debounceReload?.cancel();
    _debounceReload = Timer(_debounceRealtimeRefresh, () {
      if (isClosed) return;
      unawaited(refresh());
    });
  }

  @override
  Future<void> close() async {
    _debounceReload?.cancel();
    _safetyPoll?.cancel();
    await _channel?.unsubscribe();
    return super.close();
  }
}


