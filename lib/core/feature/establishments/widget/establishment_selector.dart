// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:side_project/core/feature/establishments/cubit/establishment_types_cubit.dart';
// import 'package:side_project/core/feature/establishments/data/models/establishment_type.dart';
// import 'package:side_project/core/shared/app_dropDown.dart';

// class EstablishmentTypeSelector extends StatelessWidget {
//   /// Текущий выбор (список)
//   final List<EstablishmentType> selectedTypes;

//   /// Колбэк при изменении
//   final ValueChanged<List<EstablishmentType>> onChanged;

//   /// Множественный выбор или одиночный?
//   final bool isMultiSelect;

//   /// Кастомный лейбл (если не передан, будет "Тип заведения")
//   final String? labelText;

//   const EstablishmentTypeSelector({
//     super.key,
//     required this.selectedTypes,
//     required this.onChanged,
//     this.isMultiSelect = false,
//     this.labelText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Используем GetIt для доступа к синглтону кубита
//     final cubit = GetIt.I<EstablishmentTypesCubit>();

//     return BlocBuilder<EstablishmentTypesCubit, EstablishmentTypesState>(
//       bloc: cubit
//         ..loadTypes(), // Cascade operator: гарантируем, что данные загружены
//       builder: (context, state) {
//         return state.map(
//           // 1. INITIAL / LOADING
//           // Показываем "заглушку" в виде закрытого дропдауна с лоадером
//           initial: (_) => _buildLoadingState(),
//           loading: (_) => _buildLoadingState(),

//           // 2. ERROR
//           // Можно показать текст ошибки или кнопку "Повторить"
//           error: (state) => Text(
//             'Ошибка справочника: ${state.message}',
//             style: const TextStyle(color: Colors.red),
//           ),

//           // 3. SUCCESS
//           // Рендерим наш универсальный AppDropdown
//           success: (state) {
//             return AppDropdown<EstablishmentType>(
//               labelText:
//                   labelText ??
//                   (isMultiSelect ? 'Типы заведений' : 'Тип заведения'),
//               hintText: 'Выберите из списка',

//               // Данные из Кубита
//               items: state.types,
//               selectedItems: selectedTypes,

//               // Настройка режима
//               isMultiSelect: isMultiSelect,
//               isSearchable: true,

//               // Логика отображения (берем имя из Enum code)
//               // Можно добавить .toUpperCase() или локализацию
//               itemLabelBuilder: (type) => type.code.name,

//               // Пробрасываем выбор наверх
//               onChanged: onChanged,
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Виджет-заглушка, пока данные грузятся (хотя у нас это 1мс)
//   Widget _buildLoadingState() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (labelText != null) ...[
//           Text(labelText!, style: const TextStyle(fontWeight: FontWeight.w500)),
//           const SizedBox(height: 8),
//         ],
//         Container(
//           height: 50,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.grey.shade100,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           alignment: Alignment.centerLeft,
//           child: const SizedBox(
//             height: 20,
//             width: 20,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//         ),
//       ],
//     );
//   }
// }
