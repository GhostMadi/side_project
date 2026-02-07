import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_project/core/dependencies/get_it.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/feature/request/presentation/cubit/brand_request_cubit.dart';
import 'package:side_project/feature/request/presentation/widget/create_request_view.dart';

@RoutePage()
class BusinessRequestsPage extends StatelessWidget {
  const BusinessRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Оборачиваем в Provider, чтобы создать кубит и сразу загрузить данные
    return BlocProvider(
      create: (_) => sl<BrandRequestCubit>()..loadMyRequests(),
      child: Scaffold(
        appBar: AppAppBar(
          automaticallyImplyLeading: true,
          title: Text('Ваши запросы', style: AppTextStyle.base(19)),
        ),
        floatingActionButton: Builder(
          // Builder нужен, чтобы получить контекст С кубитом
          builder: (context) {
            return AppButton(
              isExpanded: false,
              text: '',
              // loadingWidget: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                
              },
            );
          },
        ),
        body: BlocBuilder<BrandRequestCubit, BrandRequestState>(
          builder: (context, state) {
            return state.maybeWhen(
              // 1. ЗАГРУЗКА
              loading: () => const Center(child: CircularProgressIndicator()),

              // 2. ОШИБКА
              error: (message) => Center(
                child: Text(
                  'Ошибка: $message',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

              // 3. СПИСОК ЗАГРУЖЕН
              loaded: (requests) {
                if (requests.isEmpty) {
                  return Text('isEmpty');
                }
                return Text('not empty');
              },

              // 4. УСПЕШНОЕ ДЕЙСТВИЕ (обычно переходит в loaded, но на всякий случай)
              success: () => const Center(child: CircularProgressIndicator()),

              // 5. ИНИЦИАЛИЗАЦИЯ
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}
