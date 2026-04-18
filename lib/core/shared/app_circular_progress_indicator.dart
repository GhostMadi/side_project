import 'package:flutter/material.dart';
import 'package:side_project/core/resources/color_settings/app_colors.dart';

/// Обёртка над [CircularProgressIndicator] с акцентным цветом приложения ([AppColors.primary]).
///
/// Опционально задаётся квадрат [dimension] — удобно для кнопок и плотных layout.
class AppCircularProgressIndicator extends StatelessWidget {
  const AppCircularProgressIndicator({
    super.key,
    this.strokeWidth = 2.5,
    this.color,
    this.dimension,
    this.semanticsLabel,
  });

  final double strokeWidth;

  /// По умолчанию — основной брендовый акцент (салатовый).
  final Color? color;

  /// Если задан — индикатор кладётся в [SizedBox] шириной/высотой [dimension].
  final double? dimension;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;
    final indicator = CircularProgressIndicator.adaptive(
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
      semanticsLabel: semanticsLabel,
    );
    final d = dimension;
    if (d != null) {
      return SizedBox(width: d, height: d, child: indicator);
    }
    return indicator;
  }
}
