import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';
import 'package:side_project/core/resources/text_settings/app_text_style.dart';
import 'package:side_project/core/shared/app_bottom_sheet.dart';
import 'package:side_project/core/shared/app_button.dart';
import 'package:side_project/core/shared/app_checkbox.dart';
import 'package:side_project/core/shared/app_single_select.dart';
import 'package:side_project/core/shared/app_text_field.dart';

/// Поле выбора нескольких значений: шторка с поиском, чекбоксами и «Готово».
///
/// Использует [AppSingleSelectOption] как элементы списка.
class AppMultiSelector<T> extends StatelessWidget {
  const AppMultiSelector({
    super.key,
    this.label,
    required this.hint,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.searchHint = 'Поиск',
    this.sheetTitle,
    this.doneLabel = 'Готово',
  });

  final String? label;
  final String hint;
  final List<AppSingleSelectOption<T>> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;

  final String searchHint;
  final String? sheetTitle;
  final String doneLabel;

  static const double _radius = 12;

  String? _labelFor(T value) {
    for (final o in options) {
      if (o.value == value) return o.label;
    }
    return null;
  }

  String? _summary() {
    if (selected.isEmpty) return null;
    if (selected.length == options.length && options.isNotEmpty) {
      return 'Все';
    }
    if (selected.length <= 2) {
      return selected.map(_labelFor).whereType<String>().join(', ');
    }
    return 'Выбрано: ${selected.length}';
  }

  Future<void> _openSheet(BuildContext context) async {
    final h = MediaQuery.sizeOf(context).height * 0.58;
    final result = await AppBottomSheet.show<Set<T>>(
      context: context,
      title: sheetTitle ?? label ?? hint,
      upperCaseTitle: false,
      showCloseButton: true,
      contentHeight: h,
      contentBottomSpacing: 0,
      content: _AppMultiSelectContent<T>(
        searchHint: searchHint,
        options: options,
        initial: Set<T>.from(selected),
        doneLabel: doneLabel,
      ),
    );
    if (!context.mounted || result == null) return;
    onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final display = _summary();
    final hasValue = display != null && display.isNotEmpty;

    final field = Material(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: options.isEmpty ? null : () => _openSheet(context),
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
                  hasValue ? display : hint,
                  style: AppTextStyle.base(
                    16,
                    color: hasValue ? AppColors.textColor : AppColors.subTextColor.withValues(alpha: 0.65),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.checklist_rounded, color: AppColors.subTextColor.withValues(alpha: 0.55), size: 24),
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

class _AppMultiSelectContent<T> extends StatefulWidget {
  const _AppMultiSelectContent({
    required this.searchHint,
    required this.options,
    required this.initial,
    required this.doneLabel,
  });

  final String searchHint;
  final List<AppSingleSelectOption<T>> options;
  final Set<T> initial;
  final String doneLabel;

  @override
  State<_AppMultiSelectContent<T>> createState() => _AppMultiSelectContentState<T>();
}

class _AppMultiSelectContentState<T> extends State<_AppMultiSelectContent<T>> {
  late final TextEditingController _search;
  late Set<T> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _selected = Set<T>.from(widget.initial);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AppSingleSelectOption<T>> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options.where((e) => e.label.toLowerCase().contains(q)).toList();
  }

  void _setSelected(T value, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(value);
      } else {
        _selected.remove(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: widget.searchHint,
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Ничего не найдено',
                      style: AppTextStyle.base(14, color: AppColors.subTextColor),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
                  itemBuilder: (context, i) {
                    final o = _filtered[i];
                    final checked = _selected.contains(o.value);
                    return AppCheckboxListTile(
                      value: checked,
                      onChanged: (v) => _setSelected(o.value, v),
                      label: o.label,
                    );
                  },
                ),
        ),
        if (widget.options.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: bottom - 15),
            child: AppButton(
              isExpanded: true,
              text: widget.doneLabel,
              onPressed: () => Navigator.pop(context, Set<T>.from(_selected)),
            ),
          ),
      ],
    );
  }
}
