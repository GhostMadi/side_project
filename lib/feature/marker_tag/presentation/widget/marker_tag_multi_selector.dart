import 'package:flutter/material.dart';
import 'package:side_project/core/shared/app_multi_select.dart';
import 'package:side_project/core/shared/app_single_select.dart';
import 'package:side_project/feature/marker_tag/domain/marker_tag_dictionary.dart';

/// [AppSingleSelectOption] / [AppMultiSelector] по локальному справочнику [MarkerTagKey] (бэк не нужен).
List<AppSingleSelectOption<MarkerTagKey>> allMarkerTagSelectOptions() {
  final out = <AppSingleSelectOption<MarkerTagKey>>[];
  for (final g in MarkerTagGroupKey.values) {
    for (final k in MarkerTagKey.values.where((t) => t.group == g)) {
      out.add(AppSingleSelectOption(value: k, label: k.titleRu));
    }
  }
  return out;
}

/// Множественный выбор тегов маркера: поиск, чекбоксы, «Готово».
///
/// [selected] пустой — на карте **без** фильтра по тегам (показать по остальным критериям).
class MarkerTagMultiSelector extends StatelessWidget {
  const MarkerTagMultiSelector({
    super.key,
    this.label = 'Теги',
    required this.selected,
    required this.onChanged,
    this.hint = 'Любые теги (не сужать)',
  });

  final String? label;
  final String hint;
  final Set<MarkerTagKey> selected;
  final ValueChanged<Set<MarkerTagKey>> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppMultiSelector<MarkerTagKey>(
      label: label,
      hint: hint,
      options: allMarkerTagSelectOptions(),
      selected: selected,
      onChanged: onChanged,
      sheetTitle: 'Теги',
      searchHint: 'Поиск тега',
    );
  }
}
