import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';

class AnimatedSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onAnimated; // called on each animation tick
  const AnimatedSlider({super.key, required this.value, required this.onChanged, this.onAnimated});

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<AnimatedSlider> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _current;
  VoidCallback? _onTick;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
    _controller = AnimationController(vsync: this, duration: kAnimationDuration);
    _animation = AlwaysStoppedAnimation<double>(_current);
  }

  @override
  void didUpdateWidget(covariant AnimatedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Stop any in-flight animation and detach previous listener, if any.
      _controller.stop();
      if (_onTick != null) {
        _animation.removeListener(_onTick!);
      }

      // Animate smoothly from current visual value to the new target value.
      _animation = Tween<double>(begin: _current, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _onTick = () {
        setState(() {
          _current = _animation.value;
        });
        if (widget.onAnimated != null) {
          widget.onAnimated!(_current);
        }
      };
      _animation.addListener(_onTick!);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    if (_onTick != null) {
      _animation.removeListener(_onTick!);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _current,
      onChanged: (v) {
        // Immediately reflect drag position for responsive feel
        setState(() {
          _current = v;
        });
        widget.onChanged(v);
      },
      min: 0,
      max: 1,
    );
  }
}
