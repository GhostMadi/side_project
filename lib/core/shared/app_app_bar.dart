// import 'package:flutter/material.dart';

// class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const AppAppBar({
//     super.key,
//     this.title,
//     this.titleWidget,
//     this.leading,
//     this.actions,
//     this.centerTitle = true,
//     this.height = kToolbarHeight,
//     this.elevation = 0,
//     this.onBack,
//     this.showBackIfCanPop = true,
//     this.bottom,
//     this.padding = const EdgeInsets.symmetric(horizontal: 12),
//     this.borderRadius = const BorderRadius.only(
//       bottomLeft: Radius.circular(16),
//       bottomRight: Radius.circular(16),
//     ),

//     this.backgroundColor, // например Colors.white
//     this.gradient, // например LinearGradient(...)
//     this.shadow, // например [BoxShadow(...)]
//     this.border, // например Border.all(...)
//   });

//   final String? title;
//   final Widget? titleWidget;

//   final Widget? leading;
//   final List<Widget>? actions;

//   final bool centerTitle;
//   final double height;
//   final double elevation;

//   final VoidCallback? onBack;
//   final bool showBackIfCanPop;

//   final PreferredSizeWidget? bottom;

//   final EdgeInsets padding;
//   final BorderRadius borderRadius;

//   final Color? backgroundColor;
//   final Gradient? gradient;
//   final List<BoxShadow>? shadow;
//   final BoxBorder? border;

//   @override
//   Size get preferredSize =>
//       Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

//   @override
//   Widget build(BuildContext context) {
//     final canPop = Navigator.of(context).canPop();

//     final Widget? leadingWidget =
//         leading ??
//         (showBackIfCanPop && canPop
//             ? IconButton(
//                 onPressed: onBack ?? () => Navigator.of(context).maybePop(),
//                 icon: const Icon(Icons.arrow_back_ios_new_rounded),
//               )
//             : null);

//     final Widget titleFinal =
//         titleWidget ??
//         Text(
//           title ?? '',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: Theme.of(context).textTheme.titleMedium,
//         );

//     return Material(
//       color: Colors.transparent,
//       elevation: elevation,
//       child: SafeArea(
//         bottom: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: height,
//               padding: padding,
//               decoration: BoxDecoration(
//                 // TODO: поставишь сам
//                 color: backgroundColor, // null -> прозрачный
//                 gradient: gradient,
//                 borderRadius: borderRadius,
//                 boxShadow: shadow,
//                 border: border,
//               ),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 48,
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: leadingWidget,
//                     ),
//                   ),

//                   Expanded(
//                     child: Align(
//                       alignment: centerTitle
//                           ? Alignment.center
//                           : Alignment.centerLeft,
//                       child: titleFinal,
//                     ),
//                   ),

//                   SizedBox(
//                     width: 48 + ((actions?.length ?? 0) * 40.0),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: actions ?? const [],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (bottom != null) bottom!,
//           ],
//         ),
//       ),
//     );
//   }
// }
