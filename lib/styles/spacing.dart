import 'package:flutter/material.dart';

class AppSpacing {
  static const double tiny = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double huge = 32;

  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 18;
  static const double radiusXl = 28;
  static const double radiusPill = 999;

  static const double appBarIcon = 30;
  static const double buttonSize = 64;
  static const double deleteButtonWidth = 220;
  static const double iconSm = 16;
  static const double iconMd = 28;
  static const double iconLg = 32;
  static const double iconXl = 36;
  static const double flagSize = 26;
  static const double flagChipSpacing = 12;
  static const double flagChipWidth = 64;
  static const double flagChipHeight = 52;
  static const double modalCloseIcon = 24;
  static const double modalCloseButton = 44;
  static const double modalCloseInset = 12;
  static const double closeButtonSize = 26;

  static const double cardShadowBlur = 28;
  static const double cardShadowYOffset = 16;
  static const double overlayBorder = 3;
  static const double poofLift = 18;
  static const double poofBlur = 8;
  static const double poofBlurHeavy = 12;
  static const double poofBlurHaze = 18;
  static const double stackCardOffset = 28;
  static const double maxCardWidth = 420;
  static const double actionIconOffset = 0.8;
  static const double actionButtonPadding = 14;
  static const double stackSlideFactor = 0.18;

  static const EdgeInsets insetAllSm = EdgeInsets.all(sm);
  static const EdgeInsets insetAllMd = EdgeInsets.all(md);
  static const EdgeInsets insetAllLg = EdgeInsets.all(lg);
  static const EdgeInsets insetAllXl = EdgeInsets.all(xxl);
  static const EdgeInsets insetNone = EdgeInsets.zero;

  static const EdgeInsets insetMenu = EdgeInsets.all(xxl);
  static const EdgeInsets insetModal = EdgeInsets.all(xxl);

  static const EdgeInsets insetButton = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: md,
  );
  static const EdgeInsets insetBadge = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );
  static const EdgeInsets insetRow = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );
  static const EdgeInsets insetScreen = EdgeInsets.fromLTRB(xl, md, xl, xxl);
  static const EdgeInsets insetSheet = EdgeInsets.fromLTRB(lg, sm, lg, md);
  static const EdgeInsets insetSheetFooter = EdgeInsets.fromLTRB(lg, 0, lg, lg);
}
