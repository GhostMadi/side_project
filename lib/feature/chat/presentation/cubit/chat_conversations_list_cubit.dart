import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/core/storage/prefs/chat_conversations_cache_storage.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
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
        callback: (_) => _scheduleReload(),
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
    _debounceReload = Timer(const Duration(milliseconds: 250), () {
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

