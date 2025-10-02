// lib/services/ui_overlays.dart
import 'dart:async';
import 'package:flutter/material.dart';

const Duration kAutoDismissDuration = Duration(seconds: 9999);

Future<T?> showAutoDismissBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Duration duration = kAutoDismissDuration,
  Color? backgroundColor,
  ShapeBorder? shape,
  Clip? clipBehavior,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool enableDrag = true,
  double? elevation,
  AnimationController? transitionAnimationController,
  bool? showDragHandle,
  RouteSettings? routeSettings,
  BoxConstraints? constraints,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: backgroundColor,
    shape: shape,
    clipBehavior: clipBehavior,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    enableDrag: enableDrag,
    elevation: elevation,
    transitionAnimationController: transitionAnimationController,
    showDragHandle: showDragHandle,
    routeSettings: routeSettings,
    constraints: constraints,
    builder: (ctx) => _AutoDismiss(
      duration: duration,
      child: Builder(builder: builder),
    ),
  );
}

Future<T?> showAutoDismissDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Duration duration = kAutoDismissDuration,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior: traversalEdgeBehavior,
    builder: (ctx) => _AutoDismiss(
      duration: duration,
      child: Builder(builder: builder),
    ),
  );
}

class _AutoDismiss extends StatefulWidget {
  final Duration duration;
  final Widget child;
  const _AutoDismiss({required this.duration, required this.child});

  @override
  State<_AutoDismiss> createState() => _AutoDismissState();
}

class _AutoDismissState extends State<_AutoDismiss> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      final nav = Navigator.of(context);
      if (nav.canPop()) nav.maybePop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
