import 'package:flutter/material.dart';

class AppAnimations {
  // Page transition animations
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Axis direction = Axis.horizontal,
  }) {
    Offset begin;
    Offset end = Offset.zero;

    switch (direction) {
      case Axis.horizontal:
        begin = const Offset(1.0, 0.0);
      case Axis.vertical:
        begin = const Offset(0.0, 1.0);
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  // Fade transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  // Scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }

  // Staggered animation for lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (entry.key * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: entry.value,
        );
      }).toList(),
    );
  }

  // Bounce animation for buttons
  static Widget bounceAnimation({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }

  // Shake animation for errors
  static Widget shakeAnimation({
    required Widget child,
    required bool shouldShake,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: shouldShake ? 1.0 : 0.0),
      builder: (context, value, child) {
        final shake = value * 10 * (1 - value);
        return Transform.translate(
          offset: Offset(shake * (value < 0.5 ? 1 : -1), 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Pulse animation for loading states
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  // Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value.dy * MediaQuery.of(context).size.height),
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from right animation
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value.dx * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Rotate animation
  static Widget rotateAnimation({
    required Widget child,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: end),
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159, // Full rotation
          child: child,
        );
      },
      child: child,
    );
  }

  // Custom page route with slide transition
  static PageRouteBuilder slideRoute({
    required Widget page,
    Axis direction = Axis.horizontal,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return slideTransition(
          child: child,
          animation: animation,
          direction: direction,
        );
      },
    );
  }

  // Custom page route with fade transition
  static PageRouteBuilder fadeRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return fadeTransition(
          child: child,
          animation: animation,
        );
      },
    );
  }
}
