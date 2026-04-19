import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/chat_thread_cache_storage.dart';
import 'package:side_project/feature/chat/debug/chat_read_receipt_debug_log.dart';
import 'package:side_project/feature/chat/data/models/chat_message_enriched.dart';
import 'package:side_project/feature/chat/data/models/chat_message_model.dart';
import 'package:side_project/feature/chat/data/models/chat_profile_mini_model.dart';
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

  /// Одна повторная попытка get_message_enriched (лаг коммита); дальше — один refresh.
  static const _mergeRetryDelay = Duration(milliseconds: 60);
  static const _debounceRealtimeRefresh = Duration(milliseconds: 140);

  /// После того как пользователь прокрутил к концу ленты — один RPC mark_read (не на каждый апсерт сообщения).
  static const _readReceiptDebounceWindow = Duration(milliseconds: 500);

  RealtimeChannel? _channel;
  Timer? _debounceReload;
  Timer? _readReceiptDebounce;
  String? _lastMarkedReadMessageId;

  /// Пока уходит RPC отправки сообщения — не вызывать `mark_conversation_read` по debounce скролла:
  /// иначе фиксируется хвост **до** нового сообщения (гонка как в логах: af1fb429 vs a9fff433).
  int _outstandingOutgoingSendRpc = 0;

  /// Прочие участники (`user_id` → `last_read_message_id`). После [load]/[refresh] синхронизируется с БД; Realtime UPDATE только дополняет.
  final Map<String, String?> _peerLastReadByUserId = {};
  bool _peerReadMapReady = false;

  /// Пока [load] ждёт `list_messages_enriched`, INSERT уже мог прийти по WS — обработаем после перехода в loaded.
  final List<Map<String, dynamic>> _pendingMessageInsertRows = [];

  /// Полная строка уже пришла broadcast-ом — не дёргаем `get_message_enriched` зря.
  final Set<String> _skipRpcEnrichmentIds = {};

  ChatThreadCubit(this._repo, this._client, this._cache) : super(const ChatThreadState.initial());

  void _emitIfOpen(ChatThreadState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Совпадает с `client_message_id` на сервере / в broadcast — merge O(1).
  static String _newClientMessageId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    const h = '0123456789abcdef';
    final sb = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) sb.write('-');
      sb.write(h[bytes[i] >> 4]);
      sb.write(h[bytes[i] & 0xf]);
    }
    return sb.toString();
  }

  static String _localId() => 'local_${DateTime.now().microsecondsSinceEpoch}';

  /// Supabase Auth и uuid в Postgres могут отличаться регистром — без нормализации «мои» исходящие не матчятся и read_by_peer не патчится.
  static String? _normUuid(String? raw) {
    final s = raw?.trim().toLowerCase();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  /// Детерминированный порядок: одинаковый created_at возможен — различаем по id.
  static int _compareEnrichedMessages(ChatMessageEnriched a, ChatMessageEnriched b) {
    final byTime = a.message.createdAt.compareTo(b.message.createdAt);
    if (byTime != 0) return byTime;
    return a.message.id.compareTo(b.message.id);
  }

  static DateTime _threadItemSortTime(ChatThreadItem it) {
    return it.when(
      server: (d) => d.message.createdAt,
      // localId, conversationId, text, createdAt, server, delivery, …
      optimisticText: (_, __, ___, localAt, server, _, _, _, _) =>
          server?.message.createdAt ?? localAt,
      // localId, conversationId, createdAt, parts, caption, server, delivery, …
      optimisticAttachments: (_, __, localAt, ___, ____, server, _, _, _, _) =>
          server?.message.createdAt ?? localAt,
    );
  }

  /// Хронология ленты: время, затем стабильный ключ (uuid сообщения / client_id / local id).
  static int _compareThreadItemsChrono(ChatThreadItem a, ChatThreadItem b) {
    final byT = _threadItemSortTime(a).compareTo(_threadItemSortTime(b));
    if (byT != 0) return byT;
    return a.stableBubbleKey.compareTo(b.stableBubbleKey);
  }

  List<ChatMessageEnriched> _dedupeEnrichedByMessageId(List<ChatMessageEnriched> list) {
    final byId = <String, ChatMessageEnriched>{};
    for (final e in list) {
      final k = _normUuid(e.message.id);
      if (k != null) byId[k] = e;
    }
    return byId.values.toList()..sort(_compareEnrichedMessages);
  }

  /// Дубликаты `ChatThreadItem.server` с тем же `message.id` и лишний server-ряд, если этот id уже внутри synced optimistic.
  List<ChatThreadItem> _dedupeOverlappingServerRows(List<ChatThreadItem> sorted) {
    final embeddedServerIds = <String>{};
    for (final it in sorted) {
      it.maybeWhen(
        optimisticText: (_, __, ___, ____, server, _, _, _, _) {
          if (server != null) embeddedServerIds.add(server.message.id);
        },
        optimisticAttachments: (_, __, ___, ____, _____, server, _, _, _, _) {
          if (server != null) embeddedServerIds.add(server.message.id);
        },
        orElse: () {},
      );
    }
    final seenStandalone = <String>{};
    final out = <ChatThreadItem>[];
    for (final it in sorted) {
      final sid = it.maybeWhen(server: (d) => d.message.id, orElse: () => null);
      if (sid != null) {
        if (seenStandalone.contains(sid)) continue;
        if (embeddedServerIds.contains(sid)) continue;
        seenStandalone.add(sid);
      }
      out.add(it);
    }
    return out;
  }

  List<ChatThreadItem> _sortedThreadItems(List<ChatThreadItem> items) {
    final out = List<ChatThreadItem>.from(items);
    out.sort(_compareThreadItemsChrono);
    return out;
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
  ///
  /// Для совпадающего `message.id`: ответ RPC перезаписывает строку, но **`read_by_peer`** берём как логическое ИЛИ
  /// с уже видимым состоянием — иначе локальные галочки после WS обнуляются при устаревшем RPC (лаг реплики).
  List<ChatMessageEnriched> _mergeFetchedWithVisibleServer(
    _ChatThreadLoaded visible,
    List<ChatMessageEnriched> fetched,
  ) {
    final byId = <String, ChatMessageEnriched>{};
    void putServer(ChatMessageEnriched e) {
      final k = _normUuid(e.message.id);
      if (k != null) byId[k] = e;
    }

    for (final it in visible.items) {
      it.maybeWhen(
        server: putServer,
        optimisticText: (_, __, ___, ____, server, _, _, _, _) {
          if (server != null) putServer(server);
        },
        optimisticAttachments: (_, __, ___, ____, _____, server, _, _, _, _) {
          if (server != null) putServer(server);
        },
        orElse: () {},
      );
    }
    for (final m in fetched) {
      final kid = _normUuid(m.message.id);
      if (kid == null) continue;
      final prev = byId[kid];
      if (prev != null) {
        final rb = prev.message.readByPeer || m.message.readByPeer;
        byId[kid] = m.copyWith(message: m.message.copyWith(readByPeer: rb));
      } else {
        byId[kid] = m;
      }
    }
    final merged = byId.values.toList()..sort(_compareEnrichedMessages);
    if (merged.length <= _fetchLimit) return merged;
    return merged.sublist(merged.length - _fetchLimit);
  }

  /// Все серверные [ChatMessageEnriched] из ленты: верхнеуровневые и вложенные в synced optimistic.
  Map<String, ChatMessageEnriched> _serverMessagesMapFromThreadItems(List<ChatThreadItem> items) {
    final byId = <String, ChatMessageEnriched>{};
    void put(ChatMessageEnriched m) {
      final k = _normUuid(m.message.id);
      if (k != null) byId[k] = m;
    }

    for (final it in items) {
      it.maybeWhen(
        server: put,
        optimisticText: (_, __, ___, ____, server, _, _, _, _) {
          if (server != null) put(server);
        },
        optimisticAttachments: (_, __, ___, ____, _____, server, _, _, _, _) {
          if (server != null) put(server);
        },
        orElse: () {},
      );
    }
    return byId;
  }

  /// Строка из актуального ответа `list_messages*` / `_emitThreadWithEnrichedUpsert` для того же сообщения,
  /// что уже лежит внутри optimistic `[server]` (до фикса optimistic «залипал» со старым read_by_peer).
  ChatMessageEnriched? _findFreshServerRowInList(List<ChatThreadItem> serverRows, ChatMessageEnriched attached) {
    final mid = _normUuid(attached.message.id);
    final cidKey = attached.message.clientMessageId?.trim().toLowerCase();
    for (final sItem in serverRows) {
      final data = sItem.maybeWhen(server: (d) => d, orElse: () => null);
      if (data == null) continue;
      if (_normUuid(data.message.id) == mid) return data;
      final cm = data.message.clientMessageId?.trim().toLowerCase();
      if (cidKey != null && cidKey.isNotEmpty && cm == cidKey) return data;
    }
    return null;
  }

  ChatMessageEnriched _mergeAttachedWithFreshFetch(ChatMessageEnriched attached, ChatMessageEnriched fresh) {
    final rb = attached.message.readByPeer || fresh.message.readByPeer;
    return fresh.copyWith(message: fresh.message.copyWith(readByPeer: rb));
  }

  Future<void> load(String conversationId) async {
    final cid = conversationId.trim();
    if (cid.isEmpty) {
      _emitIfOpen(const ChatThreadState.error('Пустой conversationId'));
      return;
    }
    ChatReadReceiptDebugLog.d('load: start cid=$cid');
    _pendingMessageInsertRows.clear();
    _skipRpcEnrichmentIds.clear();
    _readReceiptDebounce?.cancel();
    _lastMarkedReadMessageId = null;
    _peerLastReadByUserId.clear();
    _peerReadMapReady = false;
    final uid = _client.auth.currentUser?.id.trim();
    if (uid != null && uid.isNotEmpty) {
      final cached = await _cache.read(userId: uid, conversationId: cid);
      if (cached != null && cached.isNotEmpty) {
        _emitIfOpen(
          ChatThreadState.loaded(
            conversationId: cid,
            items: cached.map(ChatThreadItem.server).toList(growable: false),
            hasMore: cached.length >= _fetchLimit,
          ),
        );
      } else {
        _emitIfOpen(const ChatThreadState.loading());
      }
    } else {
      _emitIfOpen(const ChatThreadState.loading());
    }
    try {
      _subscribeRealtime(cid);

      final list = await _repo.listMessages(conversationId: cid, limit: _fetchLimit);
      final current = state.maybeMap(loaded: (v) => v, orElse: () => null);
      late final List<ChatMessageEnriched> serverSnapshotForPersistence;
      if (current != null) {
        final mergedList = _mergeFetchedWithVisibleServer(current, list);
        serverSnapshotForPersistence = mergedList;
        _emitIfOpen(_withServerViewRevision(state, _reconcileWithOptimistic(current, mergedList)));
      } else {
        final deduped = _dedupeEnrichedByMessageId(list);
        serverSnapshotForPersistence = deduped;
        _emitIfOpen(
          _withServerViewRevision(
            state,
            ChatThreadState.loaded(
              conversationId: cid,
              items: deduped.map(ChatThreadItem.server).toList(growable: false),
              hasMore: deduped.length >= _fetchLimit,
            ),
          ),
        );
      }
      _flushPendingMessageInserts(cid);
      await _syncPeerReadCursorsFromServer(cid);
      _peerReadMapReady = true;
      ChatReadReceiptDebugLog.d('load: peerReadMapReady=true cursors=${_peerLastReadByUserId.length}');
      _applyPeerReadByPeerLocally();
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(userId: uid, conversationId: cid, messages: serverSnapshotForPersistence));
      }
      // Прочитано только когда пользователь докрутил до конца — см. [scheduleMarkReadAfterViewingBottom] на странице.
    } catch (e) {
      final loaded = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (loaded != null && loaded.conversationId.trim() == cid) {
        _emitIfOpen(loaded.copyWith(errorMessage: '$e'));
      } else {
        _emitIfOpen(ChatThreadState.error('$e'));
      }
    }
  }

  /// Синхронизация ленты с сервером. [syncReadReceipt] — вызывать `mark_conversation_read`
  /// только когда пользователь явно «дочитывает» экран (pull / возврат из фона); иначе
  /// каждый фоновый refresh порождал бы лишний RPC и цепочку обновления списка диалогов.
  Future<void> refresh({bool syncReadReceipt = false}) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    final cid = s.conversationId.trim();
    try {
      final list = await _repo.listMessages(conversationId: cid, limit: _fetchLimit);
      final cur = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (cur == null || cur.conversationId.trim() != cid) return;
      final mergedList = _mergeFetchedWithVisibleServer(cur, list);
      _emitIfOpen(_withServerViewRevision(state, _reconcileWithOptimistic(cur, mergedList)));
      await _syncPeerReadCursorsFromServer(cid);
      _peerReadMapReady = true;
      ChatReadReceiptDebugLog.d('refresh: peerReadMapReady=true cursors=${_peerLastReadByUserId.length}');
      _applyPeerReadByPeerLocally();
      final uid = _client.auth.currentUser?.id.trim();
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(userId: uid, conversationId: cid, messages: mergedList));
      }
      if (syncReadReceipt && mergedList.isNotEmpty) {
        unawaited(_repo.markRead(conversationId: cid, lastMessageId: mergedList.last.message.id));
      }
    } catch (e) {
      final again = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (again != null && again.conversationId.trim() == cid) {
        _emitIfOpen(again.copyWith(errorMessage: '$e'));
      }
    }
  }

  void _beginOutgoingSendRpcGate() {
    _readReceiptDebounce?.cancel();
    _outstandingOutgoingSendRpc++;
    ChatReadReceiptDebugLog.d(
      'markRead(reader): pause until send RPC ends (outstanding=$_outstandingOutgoingSendRpc)',
    );
  }

  void _endOutgoingSendRpcGate() {
    _outstandingOutgoingSendRpc--;
    if (_outstandingOutgoingSendRpc < 0) _outstandingOutgoingSendRpc = 0;
    ChatReadReceiptDebugLog.d(
      'markRead(reader): send RPC gate done outstanding=$_outstandingOutgoingSendRpc → '
      '${_outstandingOutgoingSendRpc == 0 ? 'schedule mark_read' : 'still busy'}',
    );
    if (_outstandingOutgoingSendRpc == 0 && !isClosed) {
      scheduleMarkReadAfterViewingBottom();
    }
  }

  /// Вызывать со страницы, когда скролл у нижнего края ленты (пользователь видит последние сообщения).
  void scheduleMarkReadAfterViewingBottom() {
    if (_outstandingOutgoingSendRpc > 0) {
      ChatReadReceiptDebugLog.d(
        'markRead(reader): skip schedule while send RPC in flight ($_outstandingOutgoingSendRpc)',
      );
      return;
    }
    _readReceiptDebounce?.cancel();
    ChatReadReceiptDebugLog.d(
      'markRead(reader): debounce ${_readReceiptDebounceWindow.inMilliseconds}ms '
      '(lastMarked=$_lastMarkedReadMessageId tailPreview=${_debugTailPreviewForMarkReadLog()})',
    );
    _readReceiptDebounce = Timer(_readReceiptDebounceWindow, () {
      if (isClosed) return;
      unawaited(_runMarkReadDebounced());
    });
  }

  Future<void> _runMarkReadDebounced() async {
    if (_outstandingOutgoingSendRpc > 0) {
      ChatReadReceiptDebugLog.d(
        'markRead(reader): skip debounce body — send RPC in flight ($_outstandingOutgoingSendRpc)',
      );
      return;
    }
    final mid = _latestServerMessageIdForReadCursor();
    ChatReadReceiptDebugLog.d(
      'markRead(reader): debounce fired computedTail=${mid ?? 'null'} lastMarked=$_lastMarkedReadMessageId',
    );
    if (mid == null || mid.isEmpty) {
      ChatReadReceiptDebugLog.d('markRead(reader): skip no last server message id in thread');
      return;
    }
    if (mid == _lastMarkedReadMessageId) {
      ChatReadReceiptDebugLog.d('markRead(reader): skip same as last mark mid=$mid');
      return;
    }
    final cid = state.maybeMap(loaded: (v) => v.conversationId.trim(), orElse: () => '');
    if (cid.isEmpty) return;
    _lastMarkedReadMessageId = mid;
    ChatReadReceiptDebugLog.d('markRead(reader): POST mark_conversation_read conv=$cid lastMessageId=$mid');
    try {
      await _repo.markRead(conversationId: cid, lastMessageId: mid);
      ChatReadReceiptDebugLog.d('markRead(reader): RPC mark_conversation_read completed (expect 204)');
    } catch (e, st) {
      ChatReadReceiptDebugLog.e('markRead(reader): RPC mark_conversation_read failed', e, st);
    }
  }

  /// Короткая строка для лога до debounce (без тяжёлых вычислений).
  String _debugTailPreviewForMarkReadLog() {
    if (!ChatReadReceiptDebugLog.enabled) return '';
    final t = _latestServerMessageIdForReadCursor();
    return t ?? 'null';
  }

  /// Самый «новый» в чате server id (как в SQL по `created_at`, `id`) — не «последний в списке»,
  /// иначе без пересортировки после send хвостовой id остаётся старым.
  String? _latestServerMessageIdForReadCursor() {
    final loaded = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (loaded == null || loaded.items.isEmpty) return null;
    final messages = <ChatMessageModel>[];
    for (final it in loaded.items) {
      it.maybeWhen(
        server: (d) => messages.add(d.message),
        optimisticText: (_, __, ___, ____, server, _, _, _, _) {
          if (server != null) messages.add(server.message);
        },
        optimisticAttachments: (_, __, ___, ____, _____, server, _, _, _, _) {
          if (server != null) messages.add(server.message);
        },
        orElse: () {},
      );
    }
    if (messages.isEmpty) return null;
    var best = messages.first;
    for (var i = 1; i < messages.length; i++) {
      final m = messages[i];
      if (_lexMsgStrictlyAfter(m, best)) best = m;
    }
    return best.id;
  }

  /// После `send_message` строка уже в БД — подтягиваем enriched, чтобы optimistic сразу имел server id:
  /// иначе `_latestServerMessageIdForReadCursor` остаётся на предыдущем сообщении → mark_read не сдвигается.
  Future<ChatMessageEnriched?> _fetchEnrichedAfterSend(String messageId) async {
    final mid = messageId.trim();
    if (mid.isEmpty) return null;
    try {
      final row = await _repo.getMessageEnriched(mid);
      if (row != null) {
        ChatReadReceiptDebugLog.d('getEnrichedAfterSend: ok first try id=$mid');
        return row;
      }
      ChatReadReceiptDebugLog.d('getEnrichedAfterSend: null first try id=$mid → retry ${_mergeRetryDelay.inMilliseconds}ms');
    } catch (e) {
      ChatReadReceiptDebugLog.d('getEnrichedAfterSend: error first try id=$mid err=$e');
    }
    await Future<void>.delayed(_mergeRetryDelay);
    if (isClosed) return null;
    try {
      final row = await _repo.getMessageEnriched(mid);
      ChatReadReceiptDebugLog.d('getEnrichedAfterSend: retry id=$mid ${row != null ? 'ok' : 'still null'}');
      return row;
    } catch (e) {
      ChatReadReceiptDebugLog.d('getEnrichedAfterSend: retry error id=$mid err=$e');
      return null;
    }
  }

  ChatMessageEnriched _minimalTextEnrichedAfterSend({
    required String messageId,
    required String conversationId,
    required String text,
    required String clientLocalId,
  }) {
    final uid = _client.auth.currentUser?.id.trim();
    if (uid == null || uid.isEmpty) {
      throw StateError('Нет сессии после send_message');
    }
    final m = ChatMessageModel(
      id: messageId,
      conversationId: conversationId,
      senderId: uid,
      kind: 'text',
      text: text,
      clientMessageId: clientLocalId,
      createdAt: DateTime.now().toUtc(),
      readByPeer: false,
    );
    return ChatMessageEnriched(
      message: m,
      sender: ChatProfileMiniModel(id: uid, username: null, avatarUrl: null),
    );
  }

  Future<void> loadMore() async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null || s.isLoadingMore || !s.hasMore) return;
    _emitIfOpen(s.copyWith(isLoadingMore: true));
    try {
      final serverItems = s.items
          .where((e) => e.maybeWhen(server: (_) => true, orElse: () => false))
          .toList();
      final before = serverItems.isEmpty
          ? null
          : serverItems.first.maybeWhen(server: (d) => d.message.createdAt, orElse: () => null);
      final older = await _repo.listMessages(
        conversationId: s.conversationId,
        limit: _fetchLimit,
        before: before,
      );
      final merged = _dedupeOverlappingServerRows(
        _sortedThreadItems([...older.map(ChatThreadItem.server), ...s.items]),
      );
      _emitIfOpen(
        _withServerViewRevision(
          state,
          s.copyWith(items: merged, isLoadingMore: false, hasMore: older.length >= _fetchLimit),
        ),
      );
    } catch (e) {
      _emitIfOpen(s.copyWith(isLoadingMore: false, errorMessage: '$e'));
    }
  }

  /// Оптимистичная отправка: сразу добавляем bubble; RPC уходит в фоне (композер не ждёт сеть).
  Future<void> optimisticSendText(
    String text, {
    String? replyToMessageId,
    ChatReplyPreview? quotedPreview,
    String? quotedSenderLabel,
  }) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    final t = text.trim();

    final localId = _newClientMessageId();
    final rTrim = replyToMessageId?.trim();
    final optimistic = ChatThreadItem.optimisticText(
      localId: localId,
      conversationId: s.conversationId,
      text: t,
      createdAt: DateTime.now(),
      delivery: ChatOptimisticDelivery.sending,
      replyToMessageId: rTrim != null && rTrim.isNotEmpty ? rTrim : null,
      quotedPreview: quotedPreview,
      quotedSenderLabel: quotedSenderLabel,
    );
    _emitIfOpen(s.copyWith(items: _sortedThreadItems([...s.items, optimistic]), errorMessage: null));
    unawaited(
      _completeOptimisticTextSend(
        localId: localId,
        text: t,
        conversationId: s.conversationId,
        replyToMessageId: rTrim != null && rTrim.isNotEmpty ? rTrim : null,
      ),
    );
  }

  /// Фото / видео / файлы / голос — сразу в ленте; RPC в фоне.
  Future<void> optimisticSendAttachments({
    required List<ChatOutgoingAttachment> outgoing,
    String? caption,
    String? replyToMessageId,
    ChatReplyPreview? quotedPreview,
    String? quotedSenderLabel,
  }) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null || outgoing.isEmpty) return;

    final localId = _localId();
    final parts = outgoing
        .map((o) => ChatOptimisticOutgoingPart(filename: o.filename, mimeType: o.mimeType, bytes: o.bytes))
        .toList(growable: false);

    final rTrim = replyToMessageId?.trim();
    final optimistic = ChatThreadItem.optimisticAttachments(
      localId: localId,
      conversationId: s.conversationId,
      createdAt: DateTime.now(),
      parts: parts,
      caption: caption,
      delivery: ChatOptimisticDelivery.sending,
      replyToMessageId: rTrim != null && rTrim.isNotEmpty ? rTrim : null,
      quotedPreview: quotedPreview,
      quotedSenderLabel: quotedSenderLabel,
    );
    _emitIfOpen(s.copyWith(items: _sortedThreadItems([...s.items, optimistic]), errorMessage: null));
    unawaited(
      _completeOptimisticAttachmentsSend(
        localId: localId,
        conversationId: s.conversationId,
        outgoing: outgoing,
        caption: caption,
        replyToMessageId: rTrim != null && rTrim.isNotEmpty ? rTrim : null,
      ),
    );
  }

  Future<void> _completeOptimisticAttachmentsSend({
    required String localId,
    required String conversationId,
    required List<ChatOutgoingAttachment> outgoing,
    String? caption,
    String? replyToMessageId,
  }) async {
    _beginOutgoingSendRpcGate();
    try {
      final serverMsgId = await _repo.sendMessageWithAttachments(
        conversationId: conversationId,
        caption: caption,
        replyToMessageId: replyToMessageId,
        parts: outgoing,
      );
      final enriched = await _fetchEnrichedAfterSend(serverMsgId);
      final curAck = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (curAck != null) {
        final nextItems = [
          for (final it in curAck.items)
            it.maybeWhen(
              optimisticAttachments: (id, cid, ca, parts, cap, srv, delivery, rTo, qPrev, qLab) =>
                  id == localId
                  ? ChatThreadItem.optimisticAttachments(
                      localId: id,
                      conversationId: cid,
                      createdAt: ca,
                      parts: parts,
                      caption: cap,
                      server: enriched ?? srv,
                      delivery: enriched != null
                          ? ChatOptimisticDelivery.synced
                          : ChatOptimisticDelivery.ack,
                      replyToMessageId: rTo,
                      quotedPreview: qPrev,
                      quotedSenderLabel: qLab,
                    )
                  : it,
              orElse: () => it,
            ),
        ];
        _emitIfOpen(
          curAck.copyWith(
            items: _dedupeOverlappingServerRows(_sortedThreadItems(nextItems)),
            errorMessage: null,
          ),
        );
        _lastMarkedReadMessageId = null;
        ChatReadReceiptDebugLog.d(
          'attachSend: rpcMsgId=$serverMsgId clientLocal=$localId enriched=${enriched != null} '
          'tail=${_latestServerMessageIdForReadCursor()} clearedLastMarked=1',
        );
        if (enriched != null) _syncReadReceiptsAfterServerRowMutation();
      }
    } catch (e) {
      final cur = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (cur == null) return;
      final next = [
        for (final it in cur.items)
          it.maybeWhen(
            optimisticAttachments: (id, cid, ca, parts, cap, srv, delivery, rTo, qPrev, qLab) => id == localId
                ? ChatThreadItem.optimisticAttachments(
                    localId: id,
                    conversationId: cid,
                    createdAt: ca,
                    parts: parts,
                    caption: cap,
                    server: srv,
                    delivery: ChatOptimisticDelivery.failed,
                    replyToMessageId: rTo,
                    quotedPreview: qPrev,
                    quotedSenderLabel: qLab,
                  )
                : it,
            orElse: () => it,
          ),
      ];
      _emitIfOpen(cur.copyWith(items: next, errorMessage: null));
    } finally {
      _endOutgoingSendRpcGate();
    }
  }

  Future<void> _completeOptimisticTextSend({
    required String localId,
    required String text,
    required String conversationId,
    String? replyToMessageId,
  }) async {
    _beginOutgoingSendRpcGate();
    try {
      final serverMsgId = await _repo.sendText(
        conversationId: conversationId,
        text: text,
        clientMessageId: localId,
        replyToMessageId: replyToMessageId,
      );
      final rowFromRpc = await _fetchEnrichedAfterSend(serverMsgId);
      final usedMinimalFallback = rowFromRpc == null;
      var enriched = rowFromRpc ??
          _minimalTextEnrichedAfterSend(
            messageId: serverMsgId,
            conversationId: conversationId,
            text: text,
            clientLocalId: localId,
          );
      final curAck = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (curAck != null) {
        final nextItems = [
          for (final it in curAck.items)
            it.maybeWhen(
              optimisticText: (id, cid, txt, ca, srv, delivery, rTo, qPrev, qLab) => id == localId
                  ? ChatThreadItem.optimisticText(
                      localId: id,
                      conversationId: cid,
                      text: txt,
                      createdAt: ca,
                      server: enriched,
                      delivery: ChatOptimisticDelivery.synced,
                      replyToMessageId: rTo,
                      quotedPreview: qPrev,
                      quotedSenderLabel: qLab,
                    )
                  : it,
              orElse: () => it,
            ),
        ];
        _emitIfOpen(
          curAck.copyWith(
            items: _dedupeOverlappingServerRows(_sortedThreadItems(nextItems)),
            errorMessage: null,
          ),
        );
        _lastMarkedReadMessageId = null;
        ChatReadReceiptDebugLog.d(
          'sendText: rpcMsgId=$serverMsgId clientLocal=$localId minimalFallback=$usedMinimalFallback '
          'tailChronoAfterEmit=${_latestServerMessageIdForReadCursor()} clearedLastMarked=1',
        );
        _syncReadReceiptsAfterServerRowMutation();
      }
    } catch (e) {
      final cur = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (cur == null) return;
      final next = [
        for (final it in cur.items)
          it.maybeWhen(
            optimisticText: (id, cid, txt, ca, srv, delivery, rTo, qPrev, qLab) => id == localId
                ? ChatThreadItem.optimisticText(
                    localId: id,
                    conversationId: cid,
                    text: txt,
                    createdAt: ca,
                    server: srv,
                    delivery: ChatOptimisticDelivery.failed,
                    replyToMessageId: rTo,
                    quotedPreview: qPrev,
                    quotedSenderLabel: qLab,
                  )
                : it,
            orElse: () => it,
          ),
      ];
      _emitIfOpen(cur.copyWith(items: next, errorMessage: null));
    } finally {
      _endOutgoingSendRpcGate();
    }
  }

  Future<void> retryPending(String localId) async {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    String? text;
    String? replyToMessageId;
    ChatReplyPreview? quotedPreview;
    String? quotedSenderLabel;
    for (final it in s.items) {
      it.when(
        server: (_) {},
        optimisticText: (id, _, t, __, ___, ____, rTo, qPrev, qLab) {
          if (id == localId) {
            text = t;
            replyToMessageId = rTo;
            quotedPreview = qPrev;
            quotedSenderLabel = qLab;
          }
        },
        optimisticAttachments:
            (_, __, ___, ____, _____, ______, _______, __________, ___________, ____________) {},
      );
      if (text != null) break;
    }
    if (text == null) return;
    // Remove old optimistic, re-send.
    _emitIfOpen(
      s.copyWith(
        items: s.items
            .where(
              (e) => e.maybeWhen(
                optimisticText: (id, __, ___, ____, _____, ______, _______, __________, ___________) =>
                    id != localId,
                orElse: () => true,
              ),
            )
            .toList(),
      ),
    );
    await optimisticSendText(
      text!,
      replyToMessageId: replyToMessageId,
      quotedPreview: quotedPreview,
      quotedSenderLabel: quotedSenderLabel,
    );
  }

  ChatThreadState _reconcileWithOptimistic(_ChatThreadLoaded prev, List<ChatMessageEnriched> serverMessages) {
    final myId = _client.auth.currentUser?.id;

    final optimistic = <ChatThreadItem>[];
    for (final it in prev.items) {
      it.when(
        server: (_) {},
        optimisticText:
            (
              localId,
              conversationId,
              text,
              createdAt,
              server,
              delivery,
              replyToMessageId,
              quotedPreview,
              quotedSenderLabel,
            ) {
              optimistic.add(
                ChatThreadItem.optimisticText(
                  localId: localId,
                  conversationId: conversationId,
                  text: text,
                  createdAt: createdAt,
                  server: server,
                  delivery: delivery,
                  replyToMessageId: replyToMessageId,
                  quotedPreview: quotedPreview,
                  quotedSenderLabel: quotedSenderLabel,
                ),
              );
            },
        optimisticAttachments:
            (
              localId,
              conversationId,
              createdAt,
              parts,
              caption,
              server,
              delivery,
              replyToMessageId,
              quotedPreview,
              quotedSenderLabel,
            ) {
              optimistic.add(
                ChatThreadItem.optimisticAttachments(
                  localId: localId,
                  conversationId: conversationId,
                  createdAt: createdAt,
                  parts: parts,
                  caption: caption,
                  server: server,
                  delivery: delivery,
                  replyToMessageId: replyToMessageId,
                  quotedPreview: quotedPreview,
                  quotedSenderLabel: quotedSenderLabel,
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
        optimisticText: (localId, conversationId, text, createdAt, attached, delivery, rTo, qPrev, qLab) {
          if (delivery == ChatOptimisticDelivery.failed) return opt;
          if (attached != null) {
            final fresh = _findFreshServerRowInList(serverList, attached);
            if (fresh != null) {
              final merged = _mergeAttachedWithFreshFetch(attached, fresh);
              return ChatThreadItem.optimisticText(
                localId: localId,
                conversationId: conversationId,
                text: text,
                createdAt: createdAt,
                server: merged,
                delivery: delivery == ChatOptimisticDelivery.sending ? delivery : ChatOptimisticDelivery.synced,
                replyToMessageId: rTo,
                quotedPreview: qPrev,
                quotedSenderLabel: qLab,
              );
            }
            return opt;
          }

          for (var i = 0; i < serverList.length; i++) {
            final sItem = serverList[i];
            final data = sItem.maybeWhen(server: (d) => d, orElse: () => null);
            if (data == null) continue;
            if (usedServerIds.contains(data.message.id)) continue;
            final cm = data.message.clientMessageId?.trim();
            if (cm != null && cm.isNotEmpty && cm.toLowerCase() == localId.trim().toLowerCase()) {
              final matched = serverList[i].when(
                server: (d) => d,
                optimisticText: (_, __, ___, ____, _____, ______, _______, __________, ___________) =>
                    throw StateError('unexpected optimistic in serverList'),
                optimisticAttachments:
                    (_, __, ___, ____, _____, ______, _______, __________, ___________, ____________) =>
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
                replyToMessageId: rTo,
                quotedPreview: qPrev,
                quotedSenderLabel: qLab,
              );
            }
          }

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
              optimisticText: (_, __, ___, ____, _____, ______, _______, __________, ___________) =>
                  throw StateError('unexpected optimistic in serverList'),
              optimisticAttachments:
                  (_, __, ___, ____, _____, ______, _______, __________, ___________, ____________) =>
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
              replyToMessageId: rTo,
              quotedPreview: qPrev,
              quotedSenderLabel: qLab,
            );
          }

          return opt;
        },
        optimisticAttachments:
            (localId, conversationId, createdAt, parts, caption, attached, delivery, rTo, qPrev, qLab) {
              if (delivery == ChatOptimisticDelivery.failed) return opt;
              if (attached != null) {
                final fresh = _findFreshServerRowInList(serverList, attached);
                if (fresh != null) {
                  final merged = _mergeAttachedWithFreshFetch(attached, fresh);
                  return ChatThreadItem.optimisticAttachments(
                    localId: localId,
                    conversationId: conversationId,
                    createdAt: createdAt,
                    parts: parts,
                    caption: caption,
                    server: merged,
                    delivery: delivery == ChatOptimisticDelivery.sending ? delivery : ChatOptimisticDelivery.synced,
                    replyToMessageId: rTo,
                    quotedPreview: qPrev,
                    quotedSenderLabel: qLab,
                  );
                }
                return opt;
              }

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
                  optimisticText: (_, __, ___, ____, _____, ______, _______, __________, ___________) =>
                      throw StateError('unexpected optimistic in serverList'),
                  optimisticAttachments:
                      (_, __, ___, ____, _____, ______, _______, __________, ___________, ____________) =>
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
                  replyToMessageId: rTo,
                  quotedPreview: qPrev,
                  quotedSenderLabel: qLab,
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

    // Одна хронология: серверные + optimistic (раньше optimistic всегда в конце — ломало порядок по времени).
    return prev.copyWith(
      items: _dedupeOverlappingServerRows(_sortedThreadItems([...filteredServer, ...updatedOptimistic])),
      hasMore: serverMessages.length >= _fetchLimit,
      errorMessage: null,
    );
  }

  void _flushPendingMessageInserts(String cid) {
    final norm = cid.trim();
    if (_pendingMessageInsertRows.isEmpty) return;
    final batch = List<Map<String, dynamic>>.from(_pendingMessageInsertRows);
    _pendingMessageInsertRows.clear();
    for (final row in batch) {
      final c = row['conversation_id'] ?? row['conversationId'];
      if (c == null || c.toString().trim() != norm) continue;
      final id = row['id'];
      if (id == null) continue;
      _mergeIncomingMessageRow(id.toString(), insertRow: row);
    }
  }

  /// Новое сообщение из Realtime: мгновенно из строки WAL (как список чатов); RPC — только в фоне.
  void _mergeIncomingMessageRow(String messageId, {Map<String, dynamic>? insertRow}) {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) {
      if (insertRow != null && insertRow.isNotEmpty) {
        _pendingMessageInsertRows.add(Map<String, dynamic>.from(insertRow));
      }
      return;
    }

    final fast = insertRow != null && insertRow.isNotEmpty
        ? _repo.enrichedFromRealtimeInsertRow(insertRow)
        : null;
    final hadFast = fast != null;
    if (fast != null) {
      _emitThreadWithEnrichedUpsert(fast);
    }

    unawaited(_pullFullMessageAndUpsert(messageId, hadFastPreview: hadFast));
  }

  Future<void> _pullFullMessageAndUpsert(
    String messageId, {
    required bool hadFastPreview,
    int attempt = 0,
  }) async {
    final mid = messageId.trim();
    if (_skipRpcEnrichmentIds.contains(mid)) return;

    var row = await _repo.getMessageEnriched(messageId);
    if (row == null && attempt == 0) {
      await Future<void>.delayed(_mergeRetryDelay);
      if (isClosed) return;
      await _pullFullMessageAndUpsert(messageId, hadFastPreview: hadFastPreview, attempt: 1);
      return;
    }
    if (row == null) {
      if (hadFastPreview) return;
      await refresh(syncReadReceipt: false);
      return;
    }

    final cid = state.maybeMap(loaded: (v) => v.conversationId.trim(), orElse: () => '');
    if (row.message.conversationId.trim() != cid.trim()) return;

    final live = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (live == null || live.conversationId.trim() != cid.trim()) return;

    _emitThreadWithEnrichedUpsert(row);
  }

  void _emitThreadWithEnrichedUpsert(ChatMessageEnriched row) {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null) return;
    final conversationId = s.conversationId.trim();
    if (row.message.conversationId.trim() != conversationId) return;

    final byMsgId = _serverMessagesMapFromThreadItems(s.items);
    final rowKey = _normUuid(row.message.id);
    if (rowKey == null) return;
    byMsgId[rowKey] = row;
    var serverMsgs = byMsgId.values.toList()..sort(_compareEnrichedMessages);
    while (serverMsgs.length > _fetchLimit) {
      serverMsgs.removeAt(0);
    }

    final emitBase = state;
    _emitIfOpen(_withServerViewRevision(emitBase, _reconcileWithOptimistic(s, serverMsgs)));
    _syncReadReceiptsAfterServerRowMutation();

    final uid = _client.auth.currentUser?.id.trim();
    if (uid != null && uid.isNotEmpty) {
      final postRead = state.maybeMap(loaded: (v) => v, orElse: () => null);
      if (postRead != null) {
        final snap = _serverMessagesMapFromThreadItems(postRead.items).values.toList()
          ..sort(_compareEnrichedMessages);
        unawaited(_cache.write(userId: uid, conversationId: conversationId, messages: snap));
      }
    }
    // mark_read только при прокрутке к концу ([scheduleMarkReadAfterViewingBottom]), не на каждый INSERT/broadcast.
  }

  void _markSkipRpcEnrichment(String messageId) {
    final id = messageId.trim();
    if (id.isEmpty) return;
    _skipRpcEnrichmentIds.add(id);
    unawaited(
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (isClosed) return;
        _skipRpcEnrichmentIds.remove(id);
      }),
    );
  }

  Map<String, dynamic>? _unwrapBroadcastEnrichedPayload(Map<String, dynamic> raw) {
    if (raw['message'] is Map && raw['sender'] is Map) return raw;
    final p = raw['payload'];
    if (p is Map<String, dynamic>) return _unwrapBroadcastEnrichedPayload(p);
    if (p is Map) return _unwrapBroadcastEnrichedPayload(Map<String, dynamic>.from(p));
    final d = raw['data'];
    if (d is Map<String, dynamic>) return _unwrapBroadcastEnrichedPayload(d);
    if (d is Map) return _unwrapBroadcastEnrichedPayload(Map<String, dynamic>.from(d));
    return null;
  }

  void _onBroadcastMessageEnriched(Map<String, dynamic> raw) {
    final map = _unwrapBroadcastEnrichedPayload(raw);
    if (map == null) return;
    try {
      final row = ChatMessageEnriched.fromJson(map);
      final cid = state.maybeMap(loaded: (s) => s.conversationId.trim(), orElse: () => '');
      if (cid.isEmpty || row.message.conversationId.trim() != cid) return;
      _markSkipRpcEnrichment(row.message.id);
      _emitThreadWithEnrichedUpsert(row);
    } catch (_) {}
  }

  Future<void> _syncPeerReadCursorsFromServer(String conversationId) async {
    try {
      final cid = conversationId.trim();
      if (cid.isEmpty) return;
      final m = await _repo.peerLastReadCursors(cid);
      if (isClosed) return;
      _peerLastReadByUserId.clear();
      for (final e in m.entries) {
        final k = _normUuid(e.key);
        if (k != null) _peerLastReadByUserId[k] = e.value;
      }
      ChatReadReceiptDebugLog.d(
        'syncPeerCursors REST ok cid=$cid map=${_peerLastReadByUserId.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
      );
    } catch (e, st) {
      ChatReadReceiptDebugLog.d('syncPeerCursors REST error: $e\n$st');
    }
  }

  /// Совпадает с SQL в `list_messages_enriched`: порядок хронологический `(created_at, id)`, не сравнение UUID как строк.
  static bool _lexMsgStrictlyAfter(ChatMessageModel a, ChatMessageModel b) {
    final c = a.createdAt.compareTo(b.createdAt);
    if (c > 0) return true;
    if (c < 0) return false;
    final ia = _normUuid(a.id) ?? a.id.trim();
    final ib = _normUuid(b.id) ?? b.id.trim();
    return ia.compareTo(ib) > 0;
  }

  /// При UPDATE Realtime может прислать в `new` только изменённые колонки (без `user_id`).
  /// Без merge с `old` мы теряли user_id → ранний `return` → галочки не двигались до полного reload.
  static Map<String, dynamic> _mergedParticipantRealtimeRow(PostgresChangePayload payload) {
    final merged = Map<String, dynamic>.from(payload.oldRecord);
    merged.addAll(payload.newRecord);
    return merged;
  }

  static String? _conversationIdFromMergedRow(Map<String, dynamic> merged) {
    for (final e in merged.entries) {
      if (e.key.toString().toLowerCase() == 'conversation_id') {
        return _normUuid(e.value?.toString());
      }
    }
    return null;
  }

  void _onChatParticipantsRealtimeUpdate(PostgresChangePayload payload) {
    if (payload.eventType != PostgresChangeEvent.update) return;
    final raw = _mergedParticipantRealtimeRow(payload);
    if (raw.isEmpty) {
      ChatReadReceiptDebugLog.d('participants handler: empty merged row');
      return;
    }

    dynamic column(String snake) {
      final s = snake.toLowerCase();
      for (final e in raw.entries) {
        if (e.key.toString().toLowerCase() == s) return e.value;
      }
      return null;
    }

    final uidRow = _normUuid(column('user_id')?.toString());
    final myId = _normUuid(_client.auth.currentUser?.id);
    if (uidRow == null || uidRow.isEmpty || myId == null || myId.isEmpty) {
      ChatReadReceiptDebugLog.d(
        'participants handler: skip missing uid (uidRow=$uidRow myId=$myId)',
      );
      return;
    }
    if (uidRow == myId) {
      ChatReadReceiptDebugLog.d('participants handler: skip own row');
      return;
    }

    final lrRaw = column('last_read_message_id');
    final lrTrim = lrRaw?.toString().trim();
    _peerLastReadByUserId[uidRow] = lrTrim == null || lrTrim.isEmpty
        ? null
        : (_normUuid(lrTrim) ?? lrTrim.toLowerCase());

    final loaded = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (loaded == null) {
      ChatReadReceiptDebugLog.d('participants handler: skip not loaded');
      return;
    }
    if (!_peerReadMapReady) {
      ChatReadReceiptDebugLog.d(
        'participants handler: skip peerReadMapReady=false peer=$uidRow last_read=${lrTrim ?? ''}',
      );
      return;
    }
    ChatReadReceiptDebugLog.d(
      'participants WS → apply peer=$uidRow last_read=${lrTrim ?? ''}',
    );
    _applyPeerReadByPeerLocally();
  }

  /// После апсерта сообщения из RPC (`get_message_enriched` / превью с WAL) свежая строка часто приходит с read_by_peer=false,
  /// пока курсор собеседника у нас в [_peerLastReadByUserId] уже актуален — без второго прохода галочки «съедаются».
  void _syncReadReceiptsAfterServerRowMutation() {
    if (!_peerReadMapReady || isClosed) return;
    _applyPeerReadByPeerLocally();
  }

  /// Галочки после `UPDATE chat_participants`: только патч локального состояния по курсорам собеседников —
  /// без `list_messages_enriched` и без полного refresh.
  void _applyPeerReadByPeerLocally() {
    final loaded = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (loaded == null) return;
    final myId = _normUuid(_client.auth.currentUser?.id);
    if (myId == null || myId.isEmpty) return;

    final byId = <String, ChatMessageModel>{};
    for (final e in _serverMessagesMapFromThreadItems(loaded.items).values) {
      final nk = _normUuid(e.message.id);
      if (nk != null) byId[nk] = e.message;
    }

    for (final cursorId in _peerLastReadByUserId.values) {
      final id = _normUuid(cursorId);
      if (id == null || id.isEmpty) continue;
      if (!byId.containsKey(id)) {
        ChatReadReceiptDebugLog.d(
          'applyPeerRead: cursor msg not in visible window → debounced refresh cursor=$id',
        );
        _scheduleDebouncedFullRefresh();
        return;
      }
    }

    var any = false;
    final nextItems = loaded.items
        .map((it) {
          return it.map(
            server: (s) {
              final nm = _patchOutgoingReadPeer(s.data.message, myId, byId);
              if (identical(nm, s.data.message)) return it;
              any = true;
              return ChatThreadItem.server(s.data.copyWith(message: nm));
            },
            optimisticText: (o) {
              final srv = o.server;
              if (srv == null) return it;
              final nm = _patchOutgoingReadPeer(srv.message, myId, byId);
              if (identical(nm, srv.message)) return it;
              any = true;
              return o.copyWith(server: srv.copyWith(message: nm));
            },
            optimisticAttachments: (o) {
              final srv = o.server;
              if (srv == null) return it;
              final nm = _patchOutgoingReadPeer(srv.message, myId, byId);
              if (identical(nm, srv.message)) return it;
              any = true;
              return o.copyWith(server: srv.copyWith(message: nm));
            },
          );
        })
        .toList(growable: false);

    if (!any) {
      final buf = StringBuffer(
        'applyPeerRead(sndr): no tick myId=$myId peerCursors=$_peerLastReadByUserId ready=$_peerReadMapReady',
      );
      if (ChatReadReceiptDebugLog.verbose) {
        final mine = <ChatMessageModel>[];
        for (final m in byId.values) {
          if (_normUuid(m.senderId) == myId) mine.add(m);
        }
        mine.sort((a, b) {
          final c = a.createdAt.compareTo(b.createdAt);
          if (c != 0) return c;
          return (_normUuid(a.id) ?? a.id).compareTo(_normUuid(b.id) ?? b.id);
        });
        final newestMine = mine.isEmpty ? null : mine.last;
        buf.write(' | newestMine=${newestMine?.id} newestRp=${newestMine?.readByPeer}');
        for (final raw in _peerLastReadByUserId.values) {
          final cid = _normUuid(raw);
          if (cid == null) continue;
          final rm = cid.isEmpty ? null : byId[cid];
          if (rm == null) {
            buf.write(' | cursor=$cid rm=MISSING (not in window)');
          } else if (newestMine != null) {
            final unreadTip = _lexMsgStrictlyAfter(newestMine, rm);
            buf.write(
              ' | vsCursor=$cid rmId=${rm.id} newestStrictlyAfterRm=$unreadTip '
              '(peer read up to rm → your newest ${unreadTip ? "NOT read yet" : "read or same"})',
            );
          }
        }
        final tail = mine.length <= 8 ? mine : mine.sublist(mine.length - 8);
        buf.write(
          ' | lastOutgoingChrono=[${tail.map((m) => '${m.id.substring(0, 8)}… rp=${m.readByPeer} w=${_readByPeerForOutgoing(m, myId, byId)}').join('; ')}]',
        );
      }
      ChatReadReceiptDebugLog.d(buf.toString());
      return;
    }
    ChatReadReceiptDebugLog.d('applyPeerRead: emit tick patch');
    _emitIfOpen(_withServerViewRevision(state, loaded.copyWith(items: nextItems)));
  }

  ChatMessageModel _patchOutgoingReadPeer(
    ChatMessageModel m,
    String myId,
    Map<String, ChatMessageModel> byId,
  ) {
    if (_normUuid(m.senderId) != myId) return m;
    if (!_peerReadMapReady) return m;
    final next = _readByPeerForOutgoing(m, myId, byId);
    if (next == m.readByPeer) return m;
    return m.copyWith(readByPeer: next);
  }

  bool _readByPeerForOutgoing(ChatMessageModel m, String myId, Map<String, ChatMessageModel> byId) {
    if (_peerLastReadByUserId.isEmpty) return false;
    for (final cursorId in _peerLastReadByUserId.values) {
      final raw = _normUuid(cursorId);
      if (raw == null || raw.isEmpty) return false;
      final rm = byId[raw];
      if (rm == null) return m.readByPeer;
      if (_lexMsgStrictlyAfter(m, rm)) return false;
    }
    return true;
  }

  /// Realtime по этому каналу: новые сообщения (`chat_messages`) и **прочитано собеседником** —
  /// это `UPDATE` в `chat_participants` у другого участника (`last_read_message_id`).
  /// Отдельный REST по курсорам только при [load]/[refresh] (начальный снимок); после открытия треда —
  /// только события WS + локальный патч [_applyPeerReadByPeerLocally].
  void _subscribeRealtime(String conversationId) {
    _channel?.unsubscribe();
    final cid = conversationId.trim().toLowerCase();
    if (cid.isEmpty) return;

    /// Фильтр по `conversation_id` для сообщений — в INSERT/new обычно есть вся строка.
    final convFilter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'conversation_id',
      value: cid,
    );

    _channel = _client.channel('chat_thread_$conversationId');

    /// Важно: для **UPDATE** `chat_participants` WAL часто содержит в `new` только изменённые поля
    /// (`last_read_*`), **без** `conversation_id`. Серверный фильтр Realtime `conversation_id=eq…`
    /// тогда **не матчится** → событие **не доходит до клиента** (пока не сделали full reload с БД).
    /// Поэтому подписка на участников **без** server-side filter; отсекаем чужие диалоги по строке здесь (RLS и так ограничивает строки).
    void onParticipantsChange(PostgresChangePayload payload) {
      if (payload.eventType != PostgresChangeEvent.update) {
        ChatReadReceiptDebugLog.d('participants WS skip event=${payload.eventType.name}');
        return;
      }
      final merged = _mergedParticipantRealtimeRow(payload);
      final conv = _conversationIdFromMergedRow(merged);
      final uidPeek = merged['user_id'] ?? merged['USER_ID'];
      final lrPeek = merged['last_read_message_id'] ?? merged['LAST_READ_MESSAGE_ID'];
      ChatReadReceiptDebugLog.d(
        'participants WS UPDATE mergedConv=$conv expected=$cid user_id=$uidPeek last_read=$lrPeek keys=${merged.keys.join(',')}',
      );
      if (conv == null || conv != cid) {
        ChatReadReceiptDebugLog.d('participants WS UPDATE filtered (conv mismatch or null)');
        return;
      }
      _onChatParticipantsRealtimeUpdate(payload);
    }

    void onMessagesChange(PostgresChangePayload payload) {
      if (payload.eventType == PostgresChangeEvent.insert) {
        final rawId = payload.newRecord['id'];
        if (rawId != null) {
          _mergeIncomingMessageRow(rawId.toString(), insertRow: payload.newRecord);
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
        filter: convFilter,
        callback: onMessagesChange,
      )
      // Без PostgresChangeFilter — см. [onParticipantsChange].
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_participants',
        callback: onParticipantsChange,
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_reactions',
        filter: convFilter,
        callback: (_) => _scheduleDebouncedFullRefresh(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_attachments',
        filter: convFilter,
        callback: (_) => _scheduleDebouncedFullRefresh(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_message_post_refs',
        filter: convFilter,
        callback: (_) => _scheduleDebouncedFullRefresh(),
      )
      ..onBroadcast(event: 'message_enriched', callback: _onBroadcastMessageEnriched);

    _channel!.subscribe((status, err) {
      ChatReadReceiptDebugLog.d(
        'realtime: channel status=$status err=$err name=chat_thread_${conversationId.trim()} expectedCid=$cid',
      );
      if (status == RealtimeSubscribeStatus.channelError) {
        ChatReadReceiptDebugLog.e('realtime: channelError (проверь publication/RLS/права)', err);
      }
    });
  }

  void _scheduleDebouncedFullRefresh() {
    _debounceReload?.cancel();
    _debounceReload = Timer(_debounceRealtimeRefresh, () {
      if (isClosed) return;
      unawaited(refresh(syncReadReceipt: false));
    });
  }

  @override
  Future<void> close() async {
    _debounceReload?.cancel();
    _readReceiptDebounce?.cancel();
    _outstandingOutgoingSendRpc = 0;
    _peerLastReadByUserId.clear();
    _peerReadMapReady = false;
    _pendingMessageInsertRows.clear();
    _skipRpcEnrichmentIds.clear();
    await _channel?.unsubscribe();
    return super.close();
  }
}
