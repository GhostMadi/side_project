import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/dimension/app_dimension.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/router/app_router.gr.dart';
import 'package:side_project/core/shared/app_appbar.dart';
import 'package:side_project/core/shared/app_button.dart';

@RoutePage()
class BusinessClientMappingPage extends StatefulWidget {
  const BusinessClientMappingPage({super.key, required this.methodId});

  final String methodId;

  @override
  State<BusinessClientMappingPage> createState() => _BusinessClientMappingPageState();
}

class _BusinessClientMappingPageState extends State<BusinessClientMappingPage> {
  String _nameField = 'full_name';
  String _phoneField = 'phone';
  String _commentField = 'note';

  static const _options = <DropdownMenuItem<String>>[
    DropdownMenuItem(value: 'full_name', child: Text('Имя клиента')),
    DropdownMenuItem(value: 'phone', child: Text('Телефон')),
    DropdownMenuItem(value: 'note', child: Text('Комментарий')),
    DropdownMenuItem(value: 'master', child: Text('Мастер')),
    DropdownMenuItem(value: 'service', child: Text('Услуга')),
    DropdownMenuItem(value: 'skip', child: Text('Пропустить')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text('Сопоставление полей', style: AppTextStyle.base(18, fontWeight: FontWeight.w700)),
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
            'Способ: ${_methodLabel(widget.methodId)}. Укажите, какие колонки куда перенести.',
            style: AppTextStyle.base(14, height: 1.4, color: AppColors.subTextColor),
          ),
          SizedBox(height: AppDimensions.spaceMiddle),
          _mapRow('Колонка A', _nameField, (v) => setState(() => _nameField = v ?? _nameField)),
          SizedBox(height: AppDimensions.spaceJunior),
          _mapRow('Колонка B', _phoneField, (v) => setState(() => _phoneField = v ?? _phoneField)),
          SizedBox(height: AppDimensions.spaceJunior),
          _mapRow('Колонка C', _commentField, (v) => setState(() => _commentField = v ?? _commentField)),
          SizedBox(height: AppDimensions.spaceMiddle),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0EBD2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Мок: найдено 324 клиента, 41 возможный дубль, 7 записей с неполным телефоном.',
                style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceHuge),
          AppButton(
            text: 'Завершить импорт',
            onPressed: () => context.router.push(const BusinessClientImportResultRoute()),
          ),
        ],
      ),
    );
  }

  String _methodLabel(String id) {
    switch (id) {
      case 'paste':
        return 'Вставить список';
      case 'manual':
        return 'Добавить вручную';
      default:
        return 'Excel / CSV';
    }
  }

  Widget _mapRow(String source, String selected, ValueChanged<String?> onChanged) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(source, style: AppTextStyle.base(13, color: AppColors.subTextColor, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selected,
              items: _options,
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
