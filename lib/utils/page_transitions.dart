import 'package:flutter/material.dart';

PageRoute<T> smoothFadeSlideRoute<T>(
  WidgetBuilder builder, {
  Offset beginOffset = const Offset(0, 0.08),
  Duration duration = const Duration(milliseconds: 260),
  Duration reverseDuration = const Duration(milliseconds: 230),
  Curve curve = Curves.easeOutCubic,
  Curve reverseCurve = Curves.easeInCubic,
  bool fullscreenDialog = false,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: curve, reverseCurve: reverseCurve);
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

PageRoute<T> smoothFadeScaleRoute<T>(
  WidgetBuilder builder, {
  double beginScale = 0.99,
  Duration duration = const Duration(milliseconds: 360),
  Duration reverseDuration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeOutCubic,
  Curve reverseCurve = Curves.easeInCubic,
  double contentFadeInStart = 0.0,
  bool fullscreenDialog = false,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final start = contentFadeInStart.clamp(0.0, 0.95);
      final isReversing = animation.status == AnimationStatus.reverse;

      // When pushing, delay the new page fade/scale so the Hero flight reads cleanly.
      // When popping, fade out normally (no delay) to keep back navigation responsive.
      final contentCurve = isReversing
          ? CurvedAnimation(parent: animation, curve: reverseCurve)
          : CurvedAnimation(parent: animation, curve: Interval(start, 1.0, curve: curve));

      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(contentCurve),
        child: ScaleTransition(
          scale: Tween<double>(begin: beginScale, end: 1.0).animate(contentCurve),
          child: child,
        ),
      );
    },
  );
}

PageRoute<T> colorfulScanRoute<T>(
  WidgetBuilder builder, {
  Duration duration = const Duration(milliseconds: 380),
  Duration reverseDuration = const Duration(milliseconds: 320),
  Curve curve = Curves.easeOutCubic,
  Curve reverseCurve = Curves.easeInCubic,
  bool fullscreenDialog = true,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isReversing = animation.status == AnimationStatus.reverse;

      final curved = CurvedAnimation(parent: animation, curve: curve, reverseCurve: reverseCurve);

      // Delay page visibility slightly so the splash + Hero flight reads cleanly (push only).
      final pageCurve = isReversing
          ? CurvedAnimation(parent: animation, curve: reverseCurve)
          : CurvedAnimation(
              parent: animation,
              curve: const Interval(0.10, 1.0, curve: Curves.easeOutCubic),
            );

      final pageFade = Tween<double>(begin: 0.0, end: 1.0).animate(pageCurve);
      final pageScale = Tween<double>(begin: 0.995, end: 1.0).animate(pageCurve);

      // Color “splash” should ONLY play when opening (push), not when closing (pop).
      final Animation<double> splashOpacity = isReversing
          ? const AlwaysStoppedAnimation<double>(0.0)
          : Tween<double>(begin: 1.0, end: 0.0).animate(curved);
      final Animation<double> splashScale = isReversing
          ? const AlwaysStoppedAnimation<double>(1.0)
          : Tween<double>(begin: 0.92, end: 1.08).animate(curved);

      return Stack(
        children: [
          // Put the splash behind so it doesn't hide the Hero flight.
          IgnorePointer(
            child: FadeTransition(
              opacity: splashOpacity,
              child: ScaleTransition(
                scale: splashScale,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF00E5FF),
                        Color(0xFF7C4DFF),
                        Color(0xFFFFD54F),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: pageFade,
            child: ScaleTransition(
              scale: pageScale,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}
