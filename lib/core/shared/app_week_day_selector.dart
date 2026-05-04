import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';

/// Сегодня, 12:00 локально (срез для карты / фильтра).
DateTime appMapSliceTodayNoon() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, 12);
}

/// Следом 7 календарных дней: [сегодня … сегодня+6], каждая в 12:00.
List<DateTime> appNextSevenCalendarDaysAtNoon() {
  final t0 = appMapSliceTodayNoon();
  return List.generate(7, (i) => t0.add(Duration(days: i)));
}

bool appSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// [initial] приводит к дню в ближайших 7 суток (от сегодня); иначе — сегодня.
DateTime appClampSliceToNextSevenDays(DateTime initial) {
  final local = initial.toLocal();
  final d = DateTime(local.year, local.month, local.day, 12);
  final t0 = appMapSliceTodayNoon();
  final last = t0.add(const Duration(days: 6));
  if (!d.isBefore(t0) && !d.isAfter(last)) {
    return d;
  }
  return t0;
}

const _monthsGen = <String>[
  '',
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

const _monthsShort = <String>[
  '',
  'янв',
  'фев',
  'мар',
  'апр',
  'мая',
  'июн',
  'июл',
  'авг',
  'сен',
  'окт',
  'ноя',
  'дек',
];

const _weekdaysFull = <String>[
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];

const _weekdaysShort = <String>['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String _weekdayFull(DateTime d) => _weekdaysFull[d.weekday - 1];

String _weekdayShort(DateTime d) => _weekdaysShort[d.weekday - 1];

String _dateGenitiveLine(DateTime d) {
  final m = _monthsGen[d.month];
  final y = d.year;
  final nowY = DateTime.now().year;
  if (y == nowY) {
    return '${d.day} $m';
  }
  return '${d.day} $m $y';
}

/// Краткий текст в поле (как на инпуте).
String? _formatFieldValue(DateTime? value) {
  if (value == null) return null;
  final d = value.toLocal();
  final justDay = DateTime(d.year, d.month, d.day, 12);
  final t0 = appMapSliceTodayNoon();
  if (appSameCalendarDay(justDay, t0)) {
    return 'Сегодня · ${d.day} ${_monthsGen[d.month]}';
  }
  final t1 = t0.add(const Duration(days: 1));
  if (appSameCalendarDay(justDay, t1)) {
    return 'Завтра · ${d.day} ${_monthsGen[d.month]}';
  }
  return '${_weekdayShort(justDay)}, ${d.day} ${_monthsShort[justDay.month]}';
}

/// 7 дней: сегодня с меткой, далее +6. Значение — конкретный календарный день 12:00.
class AppWeekDaySelector extends StatelessWidget {
  const AppWeekDaySelector({
    super.key,
    this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.sheetTitle,
  });

  final String? label;
  final String hint;

  /// Локальная дата среза (сравнение по календарю; удобно 12:00).
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  final String? sheetTitle;

  static const _radius = 12.0;

  Future<void> _openSheet(BuildContext context) async {
    final picked = await AppBottomSheet.show<DateTime>(
      context: context,
      title: sheetTitle ?? label ?? hint,
      upperCaseTitle: false,
      showCloseButton: true,
      contentBottomSpacing: 16,
      content: _AppWeekDaySheetContent(selected: value),
    );
    if (!context.mounted || picked == null) return;
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final display = _formatFieldValue(value);
    final hasValue = display != null;
    final displayText = display ?? hint;

    final field = Material(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: () => _openSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: AppTextStyle.base(
                    16,
                    color: hasValue ? AppColors.textColor : AppColors.subTextColor.withValues(alpha: 0.65),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.subTextColor.withValues(alpha: 0.55),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyle.base(14, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        field,
      ],
    );
  }
}

class _AppWeekDaySheetContent extends StatelessWidget {
  const _AppWeekDaySheetContent({this.selected});

  final DateTime? selected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final days = appNextSevenCalendarDaysAtNoon();
    final s = selected?.toLocal();
    final DateTime? selectedDay =
        s == null ? null : DateTime(s.year, s.month, s.day, 12);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 8 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
            _DaySliceTile(
              day: days[i],
              daysFromToday: i,
              isSelected: selectedDay != null && appSameCalendarDay(selectedDay, days[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _DaySliceTile extends StatelessWidget {
  const _DaySliceTile({
    required this.day,
    required this.daysFromToday,
    required this.isSelected,
  });

  final DateTime day;
  final int daysFromToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isToday = daysFromToday == 0;
    final isTomorrow = daysFromToday == 1;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isToday) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
              ),
              child: Text(
                'Сегодня',
                style: AppTextStyle.base(12, color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 10),
          ] else if (isTomorrow) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.subTextColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Завтра',
                style: AppTextStyle.base(12, color: AppColors.subTextColor, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              _weekdayFull(day),
              style: AppTextStyle.base(
                16,
                color: AppColors.textColor,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _dateGenitiveLine(day),
          style: AppTextStyle.base(
            14,
            color: AppColors.subTextColor.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_rounded, color: AppColors.btnBackground, size: 22) : null,
      onTap: () => Navigator.pop(context, day),
    );
  }
}
