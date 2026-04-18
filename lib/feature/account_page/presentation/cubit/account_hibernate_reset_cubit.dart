import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/account_page/data/account_actions_repository.dart';

part 'account_hibernate_reset_cubit.freezed.dart';

/// Кубит режима сна аккаунта ([hibernate_account]).
@injectable
class AccountHibernateResetCubit extends Cubit<AccountHibernateResetState> {
  AccountHibernateResetCubit(this._repository) : super(const AccountHibernateResetState.idle());

  final AccountActionsRepository _repository;

  Future<void> hibernateAccount() async {
    emit(const AccountHibernateResetState.submitting());
    try {
      await _repository.hibernateAccount();
      if (isClosed) return;
      emit(const AccountHibernateResetState.success('Включён режим сна: профиль скрыт от других пользователей.'));
    } catch (e) {
      if (isClosed) return;
      emit(AccountHibernateResetState.error(mapAccountRpcError(e)));
    }
  }

  void clearTransient() {
    emit(const AccountHibernateResetState.idle());
  }
}

@freezed
sealed class AccountHibernateResetState with _$AccountHibernateResetState {
  const factory AccountHibernateResetState.idle() = _Idle;
  const factory AccountHibernateResetState.submitting() = _Submitting;
  const factory AccountHibernateResetState.success(String message) = _Success;
  const factory AccountHibernateResetState.error(String message) = _Error;
}
