// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:side_project/core/feature/city/cubit/city_cubit.dart';
// import 'package:side_project/core/feature/city/data/models/city.dart';
// import 'package:side_project/core/feature/shared/base_placeholder.dart';
// import 'package:side_project/core/resources/color_settings/app_colors.dart';
// import 'package:side_project/core/resources/color_settings/color_extension.dart';
// import 'package:side_project/core/resources/text_settings/app_text_style.dart';
// import 'package:side_project/core/shared/app_dropDown.dart';

// class CitySelector extends StatelessWidget {
//   final List<City> selectedCities;
//   final ValueChanged<List<City>> onChanged;
//   final String? countryCode;
//   final bool isMultiSelect;
//   final String? labelText;

//   const CitySelector({
//     super.key,
//     required this.selectedCities,
//     required this.onChanged,
//     this.countryCode,
//     this.isMultiSelect = false,
//     this.labelText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cubit = GetIt.I<CityCubit>();
//     final appColors = AppColors;

//     return BlocBuilder<CityCubit, CityState>(
//       bloc: cubit..loadCities(),
//       builder: (context, state) {
//         return state.maybeWhen(
//           success: (allCities) {
//             final filteredCities = countryCode == null
//                 ? allCities
//                 : allCities.where((city) => city.countryCode == countryCode).toList();

//             return AppDropdown<City>(
//               labelText: labelText ?? 'Выберите город',
//               hintText: countryCode == null ? 'Сначала выберите страну' : 'Выберите из списка',
//               items: filteredCities,
//               selectedItems: selectedCities,
//               isMultiSelect: isMultiSelect,
//               isSearchable: true,
//               itemLabelBuilder: (city) => city.code.toUpperCase(),
//               onChanged: onChanged,
//             );
//           },
//           loading: () => BaseLoadingPlaceholder(labelText: labelText ?? 'Выберите город'),
//           error: (msg) => Text('Ошибка: $msg', style: AppTextStyle.base(14).copyWith(color: appColors.error)),
//           orElse: () => BaseLoadingPlaceholder(labelText: labelText ?? 'Выберите город'),
//         );
//       },
//     );
//   }
// }
