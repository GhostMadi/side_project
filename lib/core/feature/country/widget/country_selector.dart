// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:side_project/core/feature/country/cubit/country_cubit.dart';
// import 'package:side_project/core/feature/country/data/models/country.dart';
// import 'package:side_project/core/feature/shared/base_placeholder.dart';
// import 'package:side_project/core/resources/color_settings/color_extension.dart';
// import 'package:side_project/core/resources/text_settings/app_text_style.dart';


// import '../../../resources/color_settings/app_colors.dart';

// class CountrySelector extends StatelessWidget {
//   final List<Country> selectedCountries;
//   final ValueChanged<List<Country>> onChanged;
//   final bool isMultiSelect;
//   final String? labelText;

//   const CountrySelector({
//     super.key,
//     required this.selectedCountries,
//     required this.onChanged,
//     this.isMultiSelect = false,
//     this.labelText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cubit = GetIt.I<CountryCubit>();
//     final appColors = AppColors;

//     return BlocBuilder<CountryCubit, CountryState>(
//       bloc: cubit..loadCountries(),
//       builder: (context, state) {
//         return state.maybeWhen(
//           success: (countries) => AppDropdown<Country>(
//             labelText: labelText ?? 'Выберите страну',
//             hintText: 'Выберите из списка',
//             items: countries,
//             selectedItems: selectedCountries,
//             isMultiSelect: isMultiSelect,
//             isSearchable: true,
//             itemLabelBuilder: (country) => country.code.toUpperCase(),
//             onChanged: onChanged,
//           ),
//           loading: () => BaseLoadingPlaceholder(labelText: labelText ?? 'Выберите страну'),
//           error: (msg) => Text('Ошибка: $msg', style: AppTextStyle.base(14).copyWith(color: appColors.error)),
//           orElse: () => BaseLoadingPlaceholder(labelText: labelText ?? 'Выберите страну'),
//         );
//       },
//     );
//   }
// }
