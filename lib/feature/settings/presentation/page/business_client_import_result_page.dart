import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_outlined_button.dart';

@RoutePage()
class BusinessClientImportResultPage extends StatelessWidget {
  const BusinessClientImportResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Импорт завершён', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceMiddle,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5E9BC)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.btnBackground, size: 22),
                        const SizedBox(width: 8),
                        Text('База перенесена', style: AppTextStyle.base(16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Успешно: 317 клиентов', style: AppTextStyle.base(14, color: AppColors.textColor)),
                    Text('Требуют проверки: 7 записей', style: AppTextStyle.base(14, color: AppColors.textColor)),
                    Text('Дубли объединены: 41', style: AppTextStyle.base(14, color: AppColors.textColor)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              text: 'Открыть все графики и услуги',
              onPressed: () => context.router.push(BusinessScheduleRoute(showWorkers: true)),
            ),
            const SizedBox(height: 10),
            AppOutlinedButton(
              text: 'Вернуться в бизнес-аккаунт',
              onPressed: () => context.router.push(const BusinessAccountRoute()),
            ),
          ],
        ),
      ),
    );
  }
}
