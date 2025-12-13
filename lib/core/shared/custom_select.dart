// import 'package:flutter/material.dart';
// import 'package:side_project/core/extensions/context_extension.dart';
// import 'package:side_project/core/shared/app_bottom_sheet.dart';
// import 'package:side_project/core/shared/app_list_item.dart';
// import 'package:side_project/core/shared/app_text_field.dart';
// enum AppSelectMode { single, multi }

// class AppCustomSelect<T> extends StatefulWidget {
//   final AppListTileVariant variant;
//   final String label;

//   /// Список данных
//   final List<T> items;

//   /// Как получить title
//   final String Function(T item) titleOf;

//   /// Как получить subtitle (опционально)
//   final String Function(T item)? subtitleOf;

//   /// Что вернуть наружу
//   final void Function(T item)? onChanged;

//   const AppCustomSelect({
//     super.key,
//     required this.items,
//     required this.titleOf,
//     this.subtitleOf,
//     this.onChanged,
//     required this.label,
//     this.variant = AppListTileVariant.outlined,
//   });

//   @override
//   State<AppCustomSelect<T>> createState() => _AppCustomSelectState<T>();
// }

// class _AppCustomSelectState<T> extends State<AppCustomSelect<T>> {
//   T? _selected;

//   @override
//   Widget build(BuildContext context) {
//     return AppListTile<T>(
//       item: _selected ?? widget.label as T,
//       variant: widget.variant,
//       title: (v) =>
//           _selected == null ? widget.label : widget.titleOf(_selected as T),
//       onTap: () {
//         showAppBottomSheet(
//           context: context,
//           title: widget.label,
//           child: _AppSelect<T>(
//             items: widget.items,
//             titleOf: widget.titleOf,
//             subtitleOf: widget.subtitleOf,
//             onSelected: (value) {
//               setState(() => _selected = value);
//               widget.onChanged?.call(value);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _AppSelect<T> extends StatefulWidget {
//   final List<T> items;
//   final String Function(T item) titleOf;
//   final String Function(T item)? subtitleOf;
//   final void Function(T selected) onSelected;

//   const _AppSelect({
//     super.key,
//     required this.items,
//     required this.titleOf,
//     this.subtitleOf,
//     required this.onSelected,
//   });

//   @override
//   State<_AppSelect<T>> createState() => _AppSelectState<T>();
// }

// class _AppSelectState<T> extends State<_AppSelect<T>> {
//   final TextEditingController _controller = TextEditingController();

//   late List<T> _filtered;

//   @override
//   void initState() {
//     super.initState();
//     _filtered = widget.items;

//     _controller.addListener(_runFilter);
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_runFilter);
//     _controller.dispose();
//     super.dispose();
//   }

//   void _runFilter() {
//     final query = _controller.text.trim().toLowerCase();

//     if (query.isEmpty) {
//       setState(() => _filtered = widget.items);
//       return;
//     }

//     setState(() {
//       _filtered = widget.items.where((item) => _match(item, query)).toList();
//     });
//   }

//   bool _match(T item, String query) {
//     final title = widget.titleOf(item).toLowerCase();
//     if (title.contains(query)) return true;

//     if (widget.subtitleOf != null) {
//       final sub = widget.subtitleOf!(item).toLowerCase();
//       if (sub.contains(query)) return true;
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: context.height * 0.5,
//       child: Column(
//         children: [
//           AppTextField(controller: _controller),

//           const SizedBox(height: 12),

//           Expanded(
//             child: _filtered.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'Ничего не найдено',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: _filtered.length,
//                     itemBuilder: (context, index) {
//                       final item = _filtered[index];

//                       return AppListTile<T>(
//                         item: item,
//                         title: widget.titleOf,
//                         subtitle: widget.subtitleOf,
//                         variant: AppListTileVariant.underline,
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           widget.onSelected(item);
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
