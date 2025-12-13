import 'package:flutter/material.dart';
import 'package:side_project/core/extensions/context_extension.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  String? title,
  required Widget child,
  List<Widget>? actions,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  bool showClose = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return AppBottomSheet(
        title: title,
        actions: actions,
        showClose: showClose,
        child: child,
      );
    },
  );
}

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.child,
    this.actions,
    this.showClose = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String? title;
  final Widget? child;
  final List<Widget>? actions;
  final bool showClose;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: context.viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // маленький "хэндл" сверху
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            if (title != null || showClose)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (showClose)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ),
            if (title != null || showClose) const SizedBox(height: 4),
            Padding(padding: padding, child: child ?? const SizedBox.shrink()),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      Expanded(child: actions![i]),
                      if (i != actions!.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
