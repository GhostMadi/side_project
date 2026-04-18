import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/chat_conversations_cache_storage.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/chat/data/models/chat_message_model.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_conversations_list_cubit.freezed.dart';

@freezed
abstract class ChatConversationsListState with _$ChatConversationsListState {
  const factory ChatConversationsListState.initial() = _ChatConvInitial;
  const factory ChatConversationsListState.loading() = _ChatConvLoading;
  const factory ChatConversationsListState.loaded({
    @Default(<ChatConversationEnriched>[]) List<ChatConversationEnriched> items,
    @Default(false) bool isRefreshing,
    String? errorMessage,
  }) = _ChatConvLoaded;
  const factory ChatConversationsListState.error(String message) = _ChatConvError;
}

@injectable
class ChatConversationsListCubit extends Cubit<ChatConversationsListState> {
  ChatConversationsListCubit(this._repo, this._client, this._cache) : super(const ChatConversationsListState.initial());

  final ChatRepository _repo;
  final SupabaseClient _client;
  final ChatConversationsCacheStorage _cache;

  RealtimeChannel? _channel;
  Timer? _debounceReload;

  static DateTime _conversationSortKey(ChatConversationEnriched e) {
    final lm = e.lastMessage?.createdAt;
    final c = e.conversation.createdAt;
    if (lm != null && c != null) return lm.isAfter(c) ? lm : c;
    return lm ?? c ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  ChatMessageModel? _chatMessageFromInsertRow(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = Map<String, dynamic>.from(raw);
      final kindVal = m['kind'];
      if (kindVal != null && kindVal is! String) {
        final s = kindVal.toString();
        m['kind'] = s.contains('.') ? s.split('.').last : s;
      }
      return ChatMessageModel.fromJson(m);
    } catch (_) {
      return null;
    }
  }

  /// Локальный patch без `list_conversations_enriched`, если чат уже в списке.
  bool _tryPatchFromChatMessageInsert(PostgresChangePayload payload) {
    final s = state.maybeMap(loaded: (v) => v, orElse: () => null);
    if (s == null || s.items.isEmpty) return false;

    final msg = _chatMessageFromInsertRow(payload.newRecord);
    if (msg == null) return false;

    final convId = msg.conversationId.trim();
    final idx = s.items.indexWhere((e) => e.conversation.id.trim() == convId);
    if (idx < 0) return false;

    final uid = _client.auth.currentUser?.id.trim();
    final isOther = uid == null || uid.isEmpty || msg.senderId.trim() != uid;

    final prev = s.items[idx];
    final nextUnread = isOther ? prev.unreadCount + 1 : prev.unreadCount;

    final updated = prev.copyWith(lastMessage: msg, unreadCount: nextUnread);

    final items = [...s.items];
    items[idx] = updated;
    items.sort((a, b) {
      final ka = _conversationSortKey(a);
      final kb = _conversationSortKey(b);
      final c = kb.compareTo(ka);
      if (c != 0) return c;
      return b.conversation.id.compareTo(a.conversation.id);
    });

    emit(s.copyWith(items: items, errorMessage: null));
    final cacheUid = _client.auth.currentUser?.id.trim();
    if (cacheUid != null && cacheUid.isNotEmpty) {
      unawaited(_cache.write(cacheUid, items));
    }
    return true;
  }

  Future<void> load() async {
    final uid = _client.auth.currentUser?.id.trim();
    if (uid != null && uid.isNotEmpty) {
      final cached = await _cache.read(uid);
      if (cached != null && cached.isNotEmpty) {
        emit(ChatConversationsListState.loaded(items: cached, isRefreshing: true));
      } else {
        emit(const ChatConversationsListState.loading());
      }
    } else {
      emit(const ChatConversationsListState.loading());
    }

    try {
      final items = await _repo.listConversations();
      emit(ChatConversationsListState.loaded(items: items));
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(uid, items));
      }
      _subscribeRealtime();
    } catch (e) {
      final prev = state.maybeMap(loaded: (s) => s.items, orElse: () => const <ChatConversationEnriched>[]);
      if (prev.isNotEmpty) {
        emit(ChatConversationsListState.loaded(items: prev, isRefreshing: false, errorMessage: '$e'));
      } else {
        emit(ChatConversationsListState.error('$e'));
      }
    }
  }

  Future<void> refresh() async {
    final prev = state.maybeMap(loaded: (s) => s.items, orElse: () => const <ChatConversationEnriched>[]);
    emit(ChatConversationsListState.loaded(items: prev, isRefreshing: true));
    try {
      final items = await _repo.listConversations();
      emit(ChatConversationsListState.loaded(items: items));
      final uid = _client.auth.currentUser?.id.trim();
      if (uid != null && uid.isNotEmpty) {
        unawaited(_cache.write(uid, items));
      }
    } catch (e) {
      emit(ChatConversationsListState.loaded(items: prev, isRefreshing: false, errorMessage: '$e'));
    }
  }

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;

    _channel = _client.channel('chat_conversations_list_$uid');
    // We cannot easily filter to user's conversations without view. So we listen to the relevant tables
    // and debounce a reload (cheap RPC).
    _channel!
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_messages',
        callback: (payload) {
          if (payload.eventType == PostgresChangeEvent.insert) {
            final patched = _tryPatchFromChatMessageInsert(payload);
            if (!patched) {
              _scheduleReload();
            }
          } else {
            _scheduleReload();
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_participants',
        callback: (_) => _scheduleReload(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'chat_conversations',
        callback: (_) => _scheduleReload(),
      );

    _channel!.subscribe();
  }

  void _scheduleReload() {
    _debounceReload?.cancel();
    _debounceReload = Timer(const Duration(milliseconds: 520), () {
      if (isClosed) return;
      unawaited(refresh());
    });
  }

  @override
  Future<void> close() async {
    _debounceReload?.cancel();
    await _channel?.unsubscribe();
    return super.close();
  }
}

