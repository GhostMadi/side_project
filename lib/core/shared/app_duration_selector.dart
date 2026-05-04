library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';

/// Dumb reusable duration selector (minutes).
///
/// - Shows a tappable field
/// - Opens [AppBottomSheet] with presets + slider
/// - Enforces [minMinutes] / [maxMinutes]
class AppDurationSelector extends StatelessWidget {
  const AppDurationSelector({
    super.key,
    this.label,
    required this.minutes,
    required this.onChanged,
    this.minMinutes = 15,
    this.maxMinutes = 24 * 60,
    this.stepMinutes = 15,
    this.presetsMinutes = const [30, 60, 90, 120, 180, 240, 360, 720, 1440],
    this.sheetTitle,
    this.hint = 'Длительность',
  });

  final String? label;
  final int? minutes;
  final ValueChanged<int> onChanged;
  final int minMinutes;
  final int maxMinutes;
  final int stepMinutes;
  final List<int> presetsMinutes;
  final String? sheetTitle;
  final String hint;

  static const _radius = 12.0;

  static String formatRu(int m) {
    if (m <= 0) return '—';
    final h = m ~/ 60;
    final mm = m % 60;
    if (h == 0) return '$mm мин';
    if (mm == 0) return '$h ч';
    return '$hч $mm м';
  }

  int get _effMinMinutes => math.min(minMinutes, maxMinutes);

  int get _effMaxMinutes => math.max(minMinutes, maxMinutes);

  int _clamp(int v) => v.clamp(_effMinMinutes, _effMaxMinutes);

  Future<void> _open(BuildContext context) async {
    final initial = _clamp(minutes ?? 120);
    final picked = await AppBottomSheet.show<int>(
      context: context,
      title: sheetTitle ?? label ?? 'Длительность',
      upperCaseTitle: false,
      showCloseButton: true,
      contentBottomSpacing: 16,
      content: _DurationSheet(
        initialMinutes: initial,
        minMinutes: _effMinMinutes,
        maxMinutes: _effMaxMinutes,
        stepMinutes: stepMinutes,
        presetsMinutes: presetsMinutes,
      ),
    );
    if (!context.mounted || picked == null) return;
    onChanged(_clamp(picked));
  }

  @override
  Widget build(BuildContext context) {
    final v = minutes;
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
              Icon(Icons.timer_outlined, color: AppColors.subTextColor.withValues(alpha: 0.55), size: 22),
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

class _DurationSheet extends StatefulWidget {
  const _DurationSheet({
    required this.initialMinutes,
    required this.minMinutes,
    required this.maxMinutes,
    required this.stepMinutes,
    required this.presetsMinutes,
  });

  final int initialMinutes;
  final int minMinutes;
  final int maxMinutes;
  final int stepMinutes;
  final List<int> presetsMinutes;

  @override
  State<_DurationSheet> createState() => _DurationSheetState();
}

class _DurationSheetState extends State<_DurationSheet> {
  late int _m;

  @override
  void initState() {
    super.initState();
    _m = widget.initialMinutes.clamp(widget.minMinutes, widget.maxMinutes);
  }

  int _clamp(int v) => v.clamp(widget.minMinutes, widget.maxMinutes);

  int _snap(int v) {
    final step = widget.stepMinutes.clamp(1, 60);
    final snapped = ((v / step).round() * step);
    return _clamp(snapped);
  }

  @override
  Widget build(BuildContext context) {
    final presets =
        widget.presetsMinutes
            .map(_clamp)
            .toSet()
            .where((v) => v >= widget.minMinutes && v <= widget.maxMinutes)
            .toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppDurationSelector.formatRu(_m),
          textAlign: TextAlign.center,
          style: AppTextStyle.base(16, fontWeight: FontWeight.w800, color: AppColors.textColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in presets)
              _Chip(
                label: AppDurationSelector.formatRu(p),
                selected: _m == p,
                onTap: () => setState(() => _m = p),
              ),
          ],
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.hintCardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Slider(
              value: _m.toDouble().clamp(
                    widget.minMinutes.toDouble(),
                    widget.maxMinutes.toDouble(),
                  ),
              min: widget.minMinutes.toDouble(),
              max: widget.maxMinutes.toDouble(),
              divisions: widget.maxMinutes > widget.minMinutes
                  ? ((widget.maxMinutes - widget.minMinutes) / widget.stepMinutes.clamp(1, 120))
                        .round()
                        .clamp(1, 3000)
                  : 1,
              onChanged: widget.maxMinutes <= widget.minMinutes
                  ? null
                  : (v) => setState(() => _m = _snap(v.round())),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.borderSoft,
            ),
          ),
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
          onPressed: () => Navigator.of(context).pop(_m),
          child: Text(
            'Выбрать',
            style: AppTextStyle.base(15, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary.withValues(alpha: 0.10) : AppColors.surface;
    final border = selected ? AppColors.primary.withValues(alpha: 0.45) : AppColors.hintCardBorder;
    final text = selected ? AppColors.primary : AppColors.textColor;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            label,
            style: AppTextStyle.base(13, fontWeight: FontWeight.w700, color: text),
          ),
        ),
      ),
    );
  }
}
