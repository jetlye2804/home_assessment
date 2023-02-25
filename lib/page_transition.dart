import 'package:flutter/material.dart';

class PageTransition extends PageRouteBuilder {
  final Widget child;
  final RouteSettings settings;
  @override
  PageTransition({
    required this.child,
    required this.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 375),
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1, 0);
    const end = Offset.zero;

    var curve = animation.status == AnimationStatus.forward
        ? Curves.ease
        : Curves.easeIn;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }
}
