import 'package:flutter/material.dart';

abstract class AppColors {
  // IMPORTANT:
  // 1) Add new project colors only in this file first.
  // 2) Then use AppColors tokens in UI instead of raw Color(0x...).

  // Brand
  static const Color brand = Color(0xffB7F5FE);
  static const Color primary = Color(0xFF8BC34A);

  // Base surfaces
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFAFAFA);
  static const Color surfaceSoft = Color(0xFFF7F7F8);
  static const Color surfaceSoftBlue = Color(0xFFF8FAFC);
  static const Color surfaceSoftGreen = Color(0xFFF8FAF5);

  // Gradients / hero backgrounds
  static const Color gradientTopSoftGreen = Color(0xFFF2F8ED);
  static const Color gradientBottomWhite = Color(0xFFFFFFFF);

  // Border / divider
  static const Color border = Color(0xFFEEEEEE);
  static const Color borderSoft = Color(0xFFE8E8E8);
  static const Color borderInput = Color(0xFFE0E0E0);
  static const Color borderCardGreen = Color(0xFFE0EBD2);
  static const Color borderCardBlue = Color(0xFFC8DDF5);
  static const Color divider = Color(0xFFEEEEEE);

  // Shadows (use with opacity)
  static const Color shadowDark = Color(0xFF000000);
  static const Color shadowPrimary = Color(0xFF8BC34A);

  // Bottom bar
  static const Color bottomBarColor = Color(0xFFFFFFFF);
  static const Color bottomBarActiveIcon = Color(0xFF8BC34A);
  static const Color bottomBarInactiveIcon = Color(0xFFA1AAB3);
  static Color bottomBarSegment = const Color(0xFF8BC34A).withValues(alpha: 0.12);
  static Color bottomBarShadow = const Color(0xFF8BC34A).withValues(alpha: 0.2);

  // Sheet / accents
  static const Color bgColor = Color(0xFF0D140A); // Темный фон с легким зеленым подтоном
  static const Color activeColor = Color(0xFFC5FEB7); // Мягкий салатовый (Apple/Lime)
  static const Color inactiveColor = Color(0xFF43573D); // Приглушенный серо-зеленый

  /// Пост — шаг «Редактирование»: светлая сцена (как [pageBackground] / [surface]).
  static const Color postEditorBackground = pageBackground;
  static const Color postEditorPanel = surface;
  static const Color postEditorCta = primary;
  static const Color postEditorOnSurface = textColor;
  static const Color postEditorOnSurfaceMuted = subTextColor;
  static const Color postEditorOnSurfaceDim = iconMuted;
  static const Color postEditorOnSurfaceHint = borderSoft;
  static Color get postEditorSliderOverlay => primary.withValues(alpha: 0.14);

  // Buttons
  static const Color btnBackground = Color(0xFF8BC34A); // Основной салатовый фон
  static const Color btnText = Color(0xFFFFFFFF); // Темный текст (тот же, что bgColor)
  static const Color btnDisabled = Color(0xFF1A2418); // Темно-зеленый выключенный фон
  static const Color btnDisabledText = Color(0xFF43573D); // Приглушенный текст выключенной кнопки

  // Text
  static const Color textColor = Color(0xFF1A1D1E); // Почти черный, но мягче
  static const Color subTextColor = Color(0xFF6A6A6A); // Глубокий серый (для описаний)
  static const Color iconMuted = Color(0xFF9E9E9E); // Плейсхолдер-иконки, вторичные метки
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status / semantic
  static const Color error = Color(0xFFE57373);
  static const Color destructive = Color(0xFFC62828);
  static const Color successSoft = Color(0xFFEFF8E7);
  static const Color infoSoft = Color(0xFFF0F7FF);

  // Inputs
  static const Color inputBackground = Color(0xFFF7F7F8);
  static const Color inputBorder = Color(0xFFE0E0E0);

  /// Пост: иконка «отправить / поделиться» в панели действий (отличается от лайка и бренда).
  static const Color postShareIcon = Color(0xFF039BE5);

  // Analytics / special cards
  static const Color analyticsCardBackground = Color(0xFFF5FAFF);
  static const Color analyticsCardBorder = Color(0xFFC8DDF5);
  static const Color hintCardBackground = Color(0xFFF9FAF9);
  static const Color hintCardBorder = Color(0xFFE8EDE5);
}
