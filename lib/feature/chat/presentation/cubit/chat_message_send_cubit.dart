import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/chat/data/repository/chat_repository.dart';

part 'chat_message_send_cubit.freezed.dart';

@freezed
abstract class ChatMessageSendState with _$ChatMessageSendState {
  const factory ChatMessageSendState.idle() = _ChatSendIdle;
  const factory ChatMessageSendState.sending() = _ChatSendSending;
  const factory ChatMessageSendState.sent(String messageId) = _ChatSendSent;
  const factory ChatMessageSendState.failure(String message) = _ChatSendFailure;
}

@injectable
class ChatMessageSendCubit extends Cubit<ChatMessageSendState> {
  ChatMessageSendCubit(this._repo) : super(const ChatMessageSendState.idle());

  final ChatRepository _repo;

  Future<void> sendText({
    required String conversationId,
    required String text,
    String? replyToMessageId,
  }) async {
    if (isClosed) return;
    emit(const ChatMessageSendState.sending());
    try {
      final id = await _repo.sendText(
        conversationId: conversationId,
        text: text,
        replyToMessageId: replyToMessageId,
      );
      if (isClosed) return;
      emit(ChatMessageSendState.sent(id));
      emit(const ChatMessageSendState.idle());
    } catch (e) {
      if (isClosed) return;
      emit(ChatMessageSendState.failure('$e'));
    }
  }

  Future<void> sendPost({
    required String conversationId,
    required String postId,
    String? caption,
    String? replyToMessageId,
  }) async {
    if (isClosed) return;
    emit(const ChatMessageSendState.sending());
    try {
      final id = await _repo.sendPostRef(
        conversationId: conversationId,
        postId: postId,
        caption: caption,
        replyToMessageId: replyToMessageId,
      );
      if (isClosed) return;
      emit(ChatMessageSendState.sent(id));
      emit(const ChatMessageSendState.idle());
    } catch (e) {
      if (isClosed) return;
      emit(ChatMessageSendState.failure('$e'));
    }
  }

  void reset() {
    if (isClosed) return;
    emit(const ChatMessageSendState.idle());
  }
}

