import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AccountActionsRepository {
  /// Режим сна: скрыть профиль и публикации у других ([hibernate_account], лимит 30 дней).
  Future<void> hibernateAccount();
}

String mapAccountRpcError(Object e) {
  if (e is PostgrestException) {
    final m = e.message.toLowerCase();
    final code = e.code;
    if (code == '404' ||
        m.contains('could not find the function') ||
        m.contains('function public.hibernate_account')) {
      return 'На сервере нет функции hibernate_account. Накатите миграции: supabase db push '
          '(см. supabase/migrations с account_state / hibernate).';
    }
    if (m.contains('hibernate_rate_limited')) {
      return 'Спящий режим можно менять не чаще одного раза в 30 дней.';
    }
    if (m.contains('not_authenticated')) {
      return 'Войдите в аккаунт.';
    }
    return e.message;
  }
  return e.toString();
}

@LazySingleton(as: AccountActionsRepository)
class AccountActionsRepositoryImpl implements AccountActionsRepository {
  AccountActionsRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<void> hibernateAccount() async {
    await _client.rpc('hibernate_account');
  }
}
