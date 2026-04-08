import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';

@RoutePage()
class BusinessClientImportPage extends StatefulWidget {
  const BusinessClientImportPage({super.key});

  @override
  State<BusinessClientImportPage> createState() => _BusinessClientImportPageState();
}

class _BusinessClientImportPageState extends State<BusinessClientImportPage> {
  String _selected = 'excel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Перенос клиентской базы', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMiddle,
          AppDimensions.spaceJunior,
          AppDimensions.paddingMiddle,
          AppDimensions.spaceSenior,
        ),
        children: [
          Text(
            'Выберите удобный способ переноса. Это мок-экран: мы показываем UX-поток без реальной загрузки.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          _methodTile(
            id: 'excel',
            title: 'Импорт из Excel / CSV',
            subtitle: 'Загрузите файл с колонками: имя, телефон, комментарий',
            icon: Icons.table_chart_outlined,
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          _methodTile(
            id: 'paste',
            title: 'Вставить список',
            subtitle: 'Скопируйте и вставьте клиентов текстом',
            icon: Icons.content_paste_rounded,
          ),
          SizedBox(height: AppDimensions.spaceJunior),
          _methodTile(
            id: 'manual',
            title: 'Добавить вручную',
            subtitle: 'Создать клиентов по одному прямо в приложении',
            icon: Icons.person_add_alt_1_rounded,
          ),
          SizedBox(height: AppDimensions.spaceHuge),
          AppButton(
            text: 'Продолжить',
            onPressed: () => context.router.push(BusinessClientMappingRoute(methodId: _selected)),
          ),
        ],
      ),
    );
  }

  Widget _methodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selected == id;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selected = id),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3F9EC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFFCEE4B2) : const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.btnBackground),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.base(15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: AppTextStyle.base(13, color: AppColors.subTextColor)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppColors.btnBackground : AppColors.subTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
