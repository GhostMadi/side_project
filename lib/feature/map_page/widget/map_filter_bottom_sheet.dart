import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_week_day_selector.dart';
import 'package:side_project/feature/marker_tag/domain/marker_tag_dictionary.dart';
import 'package:side_project/feature/marker_tag/presentation/widget/marker_tag_multi_selector.dart';

class MapFilterBottomSheet {
  const MapFilterBottomSheet._();

  static Future<void> show(
    BuildContext context, {
    required DateTime initialAtTime,
    required List<MarkerTagKey> initialTagKeys,
    required void Function(DateTime atTime, List<MarkerTagKey> tagKeys) onApply,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      title: 'Фильтр',
      showCloseButton: true,
      upperCaseTitle: false,
      contentBottomSpacing: 8,
      content: _MapFilterContent(
        initialAtTime: initialAtTime,
        initialTagKeys: List<MarkerTagKey>.from(initialTagKeys),
        onApply: onApply,
      ),
    );
  }
}

class _MapFilterContent extends StatefulWidget {
  const _MapFilterContent({required this.initialAtTime, required this.initialTagKeys, required this.onApply});

  final DateTime initialAtTime;
  final List<MarkerTagKey> initialTagKeys;
  final void Function(DateTime at, List<MarkerTagKey> keys) onApply;

  @override
  State<_MapFilterContent> createState() => _MapFilterContentState();
}

class _MapFilterContentState extends State<_MapFilterContent> {
  late DateTime _sliceAt;
  late Set<MarkerTagKey> _tagKeys;

  @override
  void initState() {
    super.initState();
    _sliceAt = appClampSliceToNextSevenDays(widget.initialAtTime);
    _tagKeys = Set<MarkerTagKey>.from(widget.initialTagKeys);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Все типы, одна дата (ближайшие 7 дней)',
          style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.4),
        ),
        const SizedBox(height: 6),
        AppWeekDaySelector(
          label: 'Срез: день',
          value: _sliceAt,
          onChanged: (d) => setState(() => _sliceAt = d),
          hint: 'Выбрать день',
          sheetTitle: 'Календарь',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Доступны сегодня и ещё 6 дней вперёд (полдень — для среза на сервере). '
            'На карте — маркеры с датой начала события в этот календарный день; полностью закончившиеся не показываются.',
            style: AppTextStyle.base(12, color: AppColors.subTextColor.withValues(alpha: 0.9), height: 1.35),
          ),
        ),
        const SizedBox(height: 16),
        MarkerTagMultiSelector(
          label: 'Теги',
          selected: _tagKeys,
          onChanged: (next) => setState(() => _tagKeys = next),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Чтобы не сужать по тегам — ничего не отмечайте (подсказка: «любые»). «Выбрать все» в списке — другой смысл: тогда в фильтр уйдут маркеры с любым из отмеченных тегов.',
            style: AppTextStyle.base(12, color: AppColors.subTextColor.withValues(alpha: 0.9), height: 1.35),
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Готово',
          onPressed: () {
            widget.onApply(_sliceAt, _tagKeys.toList());
            Navigator.of(context).maybePop();
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
