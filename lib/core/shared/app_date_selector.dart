library;

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';

/// Dumb reusable date+time selector.
///
/// - Shows a tappable field
/// - Opens [AppBottomSheet] with calendar + time dropdowns
/// - Enforces [min] / [max] bounds
class AppDateTimeSelector extends StatelessWidget {
  const AppDateTimeSelector({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.minuteStep = 5,
    this.sheetTitle,
    this.hint = 'Выбрать дату',
  });

  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? min;
  final DateTime? max;
  final int minuteStep;
  final String? sheetTitle;
  final String hint;

  static const _radius = 12.0;

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String formatRu(DateTime dt) =>
      '${_two(dt.day)}.${_two(dt.month)}.${dt.year} • ${_two(dt.hour)}:${_two(dt.minute)}';

  DateTime _clamp(DateTime dt) {
    final lo = min;
    final hi = max;
    var out = dt;
    if (lo != null && out.isBefore(lo)) out = lo;
    if (hi != null && out.isAfter(hi)) out = hi;
    return out;
  }

  Future<void> _open(BuildContext context) async {
    final now = DateTime.now();
    final initial = _clamp(value ?? now);

    final picked = await AppBottomSheet.show<DateTime>(
      context: context,
      title: sheetTitle ?? label ?? 'Дата и время',
      upperCaseTitle: false,
      showCloseButton: true,
      contentBottomSpacing: 16,
      content: _AppDateTimeSheet(initial: initial, min: min, max: max, minuteStep: minuteStep),
    );

    if (!context.mounted || picked == null) return;
    onChanged(_clamp(picked));
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    final hasValue = v != null;

    final field = Material(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: () => _open(context),
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
                  hasValue ? formatRu(v) : hint,
                  style: AppTextStyle.base(
                    16,
                    color: hasValue ? AppColors.textColor : AppColors.subTextColor.withValues(alpha: 0.65),
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.subTextColor.withValues(alpha: 0.55),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: AppTextStyle.base(14, color: AppColors.subTextColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}

class _AppDateTimeSheet extends StatefulWidget {
  const _AppDateTimeSheet({
    required this.initial,
    required this.min,
    required this.max,
    required this.minuteStep,
  });

  final DateTime initial;
  final DateTime? min;
  final DateTime? max;
  final int minuteStep;

  @override
  State<_AppDateTimeSheet> createState() => _AppDateTimeSheetState();
}

class _AppDateTimeSheetState extends State<_AppDateTimeSheet> {
  late DateTime _date; // date part
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initial.year, widget.initial.month, widget.initial.day);
    _hour = widget.initial.hour;
    _minute = _roundMinute(widget.initial.minute, widget.minuteStep);
    _ensureSelectionWithinBounds();
  }

  int _roundMinute(int m, int step) => ((m / step).round() * step).clamp(0, 59);

  DateTime _compose() => DateTime(_date.year, _date.month, _date.day, _hour, _minute);

  int get _step => widget.minuteStep.clamp(1, 30);

  /// Кандидаты минут по шагу (0, 5, 10, …).
  List<int> _minuteStepValues() {
    final out = <int>[];
    for (var m = 0; m < 60; m += _step) {
      out.add(m);
    }
    return out;
  }

  bool _isWithinBounds(DateTime dt) {
    final lo = widget.min;
    final hi = widget.max;
    if (lo != null && dt.isBefore(lo)) return false;
    if (hi != null && dt.isAfter(hi)) return false;
    return true;
  }

  List<int> _allowedMinutesForHour(int hour) {
    return _minuteStepValues().where((m) {
      return _isWithinBounds(DateTime(_date.year, _date.month, _date.day, hour, m));
    }).toList();
  }

  List<int> _allowedHours() {
    final out = <int>[];
    for (var h = 0; h < 24; h++) {
      if (_allowedMinutesForHour(h).isNotEmpty) out.add(h);
    }
    return out;
  }

  /// Подстраивает час/минуту так, чтобы [DropdownButton] всегда имел валидное value.
  void _ensureSelectionWithinBounds() {
    var hours = _allowedHours();
    if (hours.isEmpty) {
      final fallback = _clamp(_compose());
      _date = DateTime(fallback.year, fallback.month, fallback.day);
      hours = _allowedHours();
    }
    if (hours.isEmpty) return;

    if (!hours.contains(_hour)) {
      _hour = _closestInt(_hour, hours);
    }

    var minutes = _allowedMinutesForHour(_hour);
    if (minutes.isEmpty) {
      for (final h in hours) {
        final ms = _allowedMinutesForHour(h);
        if (ms.isNotEmpty) {
          _hour = h;
          minutes = ms;
          break;
        }
      }
    }
    if (minutes.isEmpty) return;

    if (!minutes.contains(_minute)) {
      _minute = _closestInt(_minute, minutes);
    }
  }

  int _closestInt(int value, List<int> sortedOrAny) {
    if (sortedOrAny.isEmpty) return value;
    var best = sortedOrAny.first;
    var bestDist = (value - best).abs();
    for (final x in sortedOrAny) {
      final d = (value - x).abs();
      if (d < bestDist) {
        bestDist = d;
        best = x;
      }
    }
    return best;
  }

  DateTime _clamp(DateTime dt) {
    final lo = widget.min;
    final hi = widget.max;
    var out = dt;
    if (lo != null && out.isBefore(lo)) out = lo;
    if (hi != null && out.isAfter(hi)) out = hi;
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final scheme = base.colorScheme.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textColor,
    );
    final themed = base.copyWith(
      colorScheme: scheme,
      datePickerTheme: base.datePickerTheme.copyWith(
        backgroundColor: AppColors.surface,
        // Keep "today" subtle; primary highlight should be for the selected day.
        todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        todayForegroundColor: WidgetStatePropertyAll(AppColors.primary.withValues(alpha: 0.85)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textColor;
        }),
        dayOverlayColor: WidgetStatePropertyAll(AppColors.primary.withValues(alpha: 0.10)),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        yearForegroundColor: const WidgetStatePropertyAll(AppColors.textColor),
        headerForegroundColor: AppColors.textColor,
        headerBackgroundColor: AppColors.surfaceSoft,
        dividerColor: AppColors.borderSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );

    final minDate = widget.min ?? DateTime(2000);
    final maxDate = widget.max ?? DateTime(2100);

    final preview = _clamp(_compose());

    final hourItems = _allowedHours();
    final minuteItems = _allowedMinutesForHour(_hour);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Когда клавиатура открыта, высоты может не хватать для Column → делаем скролл.
        final maxCalendarHeight = (constraints.maxHeight.isFinite ? constraints.maxHeight : 600) * 0.62;

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppDateTimeSelector.formatRu(preview),
                textAlign: TextAlign.center,
                style: AppTextStyle.base(16, fontWeight: FontWeight.w800, color: AppColors.textColor),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxCalendarHeight.clamp(260, 420)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.hintCardBorder),
                  ),
                  child: Theme(
                    data: themed,
                    child: CalendarDatePicker(
                      initialDate: preview,
                      firstDate: DateTime(minDate.year, minDate.month, minDate.day),
                      lastDate: DateTime(maxDate.year, maxDate.month, maxDate.day),
                      onDateChanged: (d) => setState(() {
                        _date = DateTime(d.year, d.month, d.day);
                        _ensureSelectionWithinBounds();
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (hourItems.isEmpty || minuteItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Для выбранной даты нет времени в допустимом диапазоне.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.base(13, color: AppColors.subTextColor, height: 1.35),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _Dropdown<int>(
                        label: 'Часы',
                        value: hourItems.contains(_hour) ? _hour : hourItems.first,
                        items: hourItems,
                        itemLabel: (v) => v.toString().padLeft(2, '0'),
                        onChanged: hourItems.length <= 1
                            ? null
                            : (v) => setState(() {
                                  _hour = v;
                                  _ensureSelectionWithinBounds();
                                }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Dropdown<int>(
                        label: 'Минуты',
                        value: minuteItems.contains(_minute) ? _minute : minuteItems.first,
                        items: minuteItems,
                        itemLabel: (v) => v.toString().padLeft(2, '0'),
                        onChanged: minuteItems.length <= 1
                            ? null
                            : (v) => setState(() {
                                  _minute = v;
                                  _ensureSelectionWithinBounds();
                                }),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: hourItems.isEmpty || minuteItems.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_clamp(_compose())),
                child: Text(
                  'Выбрать',
                  style: AppTextStyle.base(15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T v) itemLabel;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            dropdownColor: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            value: value,
            isExpanded: true,
            items: [
              for (final it in items)
                DropdownMenuItem<T>(
                  value: it,
                  child: Text(itemLabel(it), style: AppTextStyle.base(14, fontWeight: FontWeight.w700)),
                ),
            ],
            onChanged: onChanged == null ? null : (v) => v == null ? null : onChanged!(v),
          ),
        ),
      ),
    );
  }
}
