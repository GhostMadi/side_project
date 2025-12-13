import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  Size get size => MediaQuery.sizeOf(this);
  double get width => size.width;
  double get height => size.height;

  MediaQueryData get media => MediaQuery.of(this);
  EdgeInsets get viewInsets => media.viewInsets;
  EdgeInsets get padding => media.padding;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}
