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
    /// Увеличивается при каждой синхронизации с сервером; иначе Bloc может не emit
    /// при том же глубоком содержимом items (лаг RPC / то же окно из 50 сообщений).
    @Default(0) int syncGeneration,
  }) = _ChatThreadLoaded;
  const factory ChatThreadState.error(String message) = _ChatThreadError;
}

@injectable
class ChatThreadCubit extends Cubit<ChatThreadState> {
  ChatThreadCubit(this._repo, this._client, this._cache) : super(const ChatThreadState.initial());

  final ChatRepository _repo;
  final SupabaseClient _client;
  final ChatThreadCacheStorage _cache;

  static const _pageSize = 50;
  static const _openThreadPollInterval = Duration(seconds: 5);

  RealtimeChannel? _channel;
  Timer? _debounceReload;
  /// Пока открыт экран чата — периодически тянем `list_messages_enriched`. Список диалогов
  /// дергает только `list_conversations_enriched`; без этого опроса при сбое Realtime
  /// в логах видны POST list_conversations_enriched, а лента диалога не обновляется.
  Timer? _openThreadPoll;

  static String _localId() => 'local_${DateTime.now().microsecondsSinceEpoch}';

  /// После синка с сервером всегда увеличиваем поколение — иначе при том же списке
  /// сообщений [emit] игнорируется и лента не перестраивается.
  ChatThreadState _bumpLoadedGeneration(ChatThreadState next) {
    return next.maybeMap(
      loaded: (l) => l.copyWith(syncGeneration: l.syncGeneration + 1),
      orElse: () => next,
    );
  }

  Future<void> load(String conversationId) async {
    final cid = conversationId.trim();
    if (cid.isEmpty) {
      emit(const ChatThreadState.error('Пустой conversationId'));
      return;
    }
    final uid = _client.auth.currentUser?.id.trim();
    if (uid != null && uid.isNotEmpty) {
      final cached = await _cache.read(userId: uid, conversationId: cid);
      if (cached != null && cached.isNotEmpty) {
        emit(
          ChatThreadState.loaded(
            conversationId: cid,
            items: cached.map(ChatThreadItem.server).toList(growable: false),
            hasMore: cached.length >= _pageSize,
          ),
        );
      } else {
        emit(const ChatThreadState.loading());
      }
    } else {
      emit(const ChatThreadState.loading());
    }
    try {
      final list = await _repo.listMessages(conversationId: cid, limit: _pageSize);
      final current = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (current != null) {
        emit(_bumpLoadedGeneration(_reconcileWithOptimistic(current, list)));
      } else {
        emit(
          _bumpLoadedGeneration(
            ChatThreadState.loaded(
              conversationId: cid,
              items: list.map(ChatThreadItem.server).toList(growable: false),
              hasMore: list.length >= _pageSize,
            ),
          ),
        );
      }
      _subscribeRealtime(cid);
      _startOpenThreadPoll(cid);
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(userId: uid, conversationId: cid, messages: list));
      }
      // Mark read best-effort.
      if (list.isNotEmpty) {
        unawaited(_repo.markRead(conversationId: cid, lastMessageId: list.last.message.id));
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
    try {
      final list = await _repo.listMessages(conversationId: s.conversationId, limit: _pageSize);
      emit(_bumpLoadedGeneration(_reconcileWithOptimistic(s, list)));
      final uid = _client.auth.currentUser?.id.trim();
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(userId: uid, conversationId: s.conversationId, messages: list));
      }
      if (list.isNotEmpty) {
        unawaited(_repo.markRead(conversationId: s.conversationId, lastMessageId: list.last.message.id));
      }
    } catch (e) {
      emit(s.copyWith(errorMessage: '$e'));
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
        limit: _pageSize,
        before: before,
      );
      final merged = [
        ...older.map(ChatThreadItem.server),
        ...s.items,
      ];
      emit(s.copyWith(
        items: merged,
        isLoadingMore: false,
        hasMore: older.length >= _pageSize,
        syncGeneration: s.syncGeneration + 1,
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
      unawaited(refresh());
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
      unawaited(refresh());
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
      hasMore: serverMessages.length >= _pageSize,
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
      hasMore: serverMessages.length >= _pageSize,
      errorMessage: null,
    );
  }

  void _subscribeRealtime(String conversationId) {
    _channel?.unsubscribe();
    final cidNorm = conversationId.trim().toLowerCase();
    _channel = _client.channel('chat_thread_$conversationId');

    // Do not use PostgresChangeFilter on conversation_id: server-side eq on UUID
    // often fails to match, so no events arrive while the list (unfiltered) still updates.
    // RLS still limits which rows we receive; we filter to this thread in the callback.
    bool messageBelongsToThread(PostgresChangePayload payload) {
      final fromNew = payload.newRecord['conversation_id'];
      final fromOld = payload.oldRecord['conversation_id'];
      final raw = fromNew ?? fromOld;
      if (raw == null) return false;
      return raw.toString().trim().toLowerCase() == cidNorm;
    }

    _channel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: (payload) {
          if (messageBelongsToThread(payload)) _scheduleReload();
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_reactions',
        callback: (_) => _scheduleReload(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_attachments',
        callback: (_) => _scheduleReload(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_post_refs',
        callback: (_) => _scheduleReload(),
      );

    _channel!.subscribe();
  }

  void _startOpenThreadPoll(String conversationId) {
    _openThreadPoll?.cancel();
    final cid = conversationId.trim();
    if (cid.isEmpty) return;
    _openThreadPoll = Timer.periodic(_openThreadPollInterval, (_) {
      if (isClosed) return;
      final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (s == null || s.conversationId.trim() != cid) return;
      unawaited(refresh());
    });
  }

  void _scheduleReload() {
    _debounceReload?.cancel();
    _debounceReload = Timer(const Duration(milliseconds: 180), () {
      if (isClosed) return;
      unawaited(_refreshRealtimeTwiceForReaderLag());
    });
  }

  /// Realtime приходит до того, как read replica / RPC отдаёт новую строку — второй refresh добирает хвост.
  Future<void> _refreshRealtimeTwiceForReaderLag() async {
    await refresh();
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (isClosed) return;
    await refresh();
  }

  @override
  Future<void> close() async {
    _debounceReload?.cancel();
    _openThreadPoll?.cancel();
    await _channel?.unsubscribe();
    return super.close();
  }
}


