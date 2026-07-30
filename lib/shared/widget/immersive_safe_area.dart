import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Immersive / sticky system UI zeroes [MediaQuery.padding], so notch/camera
/// insets must come from the physical view or [MediaQuery.viewPadding].
double immersiveSafeTopInset(BuildContext context) {
  final view = View.of(context);
  final physicalTop = view.padding.top / view.devicePixelRatio;
  final viewPaddingTop = MediaQuery.viewPaddingOf(context).top;
  final paddingTop = MediaQuery.paddingOf(context).top;
  final resolved = math.max(
    physicalTop,
    math.max(viewPaddingTop, paddingTop),
  );
  return resolved > 0 ? resolved : 36.0;
}

MediaQueryData withImmersiveSafePadding(BuildContext context) {
  final mq = MediaQuery.of(context);
  final top = immersiveSafeTopInset(context);
  final bottom = math.max(mq.padding.bottom, mq.viewPadding.bottom);
  return mq.copyWith(
    padding: mq.padding.copyWith(top: top, bottom: bottom),
  );
}

/// SafeArea that still works when the app uses immersive system UI.
class ImmersiveSafeArea extends StatelessWidget {
  const ImmersiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: withImmersiveSafePadding(context),
      child: SafeArea(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: child,
      ),
    );
  }
}
