import 'package:sizer/sizer.dart';

class AppDimensions {
  // ==========================================================
  // PADDINGS (Внутренние отступы / Отступы от краев)
  // ==========================================================
  static double get paddingJunior => 2.w; // ≈8px
  static double get paddingMiddle => 4.w; // ≈16px
  static double get paddingSenior => 6.w; // ≈24px

  // ==========================================================
  // SPACES (Пространство между элементами / SizedBox)
  // ==========================================================

  /// Маленький пробел (≈8px) - между текстом и полем
  static double get spaceJunior => 2.w;

  /// Средний пробел (≈16px) - между полями
  static double get spaceMiddle => 4.w;

  /// Большой пробел (≈24px) - между смысловыми блоками
  static double get spaceSenior => 6.w;

  /// Очень большой пробел (≈32px) - отступ сверху или перед кнопкой
  /// (Можно добавить, если Senior маловато)
  static double get spaceHuge => 8.w;

  // ==========================================================
  // ICONS (Размеры иконок)
  // ==========================================================
  static double get iconJunior => 4.w; // ≈16px
  static double get iconMiddle => 6.w; // ≈24px
  static double get iconSenior => 8.w; // ≈32px

  // ==========================================================
  // RADIUS
  // ==========================================================
  static const double rCircle = 1000.0;
}
