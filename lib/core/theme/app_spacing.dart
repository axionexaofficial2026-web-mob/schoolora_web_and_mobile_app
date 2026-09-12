import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Insets
  static const EdgeInsets insetZero = EdgeInsets.zero;
  static const EdgeInsets insetAllXs = EdgeInsets.all(xs);
  static const EdgeInsets insetAllSm = EdgeInsets.all(sm);
  static const EdgeInsets insetAllMd = EdgeInsets.all(md);
  static const EdgeInsets insetAllLg = EdgeInsets.all(lg);
  static const EdgeInsets insetAllXl = EdgeInsets.all(xl);
  static const EdgeInsets insetAllXxl = EdgeInsets.all(xxl);

  static const EdgeInsets insetHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets insetHorizontalLg = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets insetHorizontalXl = EdgeInsets.symmetric(
    horizontal: xl,
  );

  static const EdgeInsets insetVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets insetVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets insetVerticalLg = EdgeInsets.symmetric(vertical: lg);
}
