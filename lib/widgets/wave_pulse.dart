// A widget that displays animated pulsing waves, optionally reactive to audio input.
import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';

class WavePulse extends StatefulWidget {
  final bool active;
  final int waves;
  final Color color;
  final double strokeWidth;
  final double intensity; // 0..1, maps volume to visual amplitude
  final double? reactiveLevel; // 0..1, optional audio-reactive input
  final bool glow;
  const WavePulse({
    super.key,
    required this.active,
    this.waves = 3,
    this.color = AppColors.white,
    this.strokeWidth = 1.0,
    this.intensity = 0.5,
    this.reactiveLevel,
    this.glow = true,
  });

  @override
  State<WavePulse> createState() => _WavePulseState();
}

class _WavePulseState extends State<WavePulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kWaveAnimDuration);
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant WavePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: _WavePulsePainter(
              progress: _controller.value,
              waves: widget.waves,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              intensity: widget.intensity,
              reactive: widget.reactiveLevel ?? 0.0,
              glow: widget.glow,
            ),
          ),
        );
      },
    );
  }
}

class _WavePulsePainter extends CustomPainter {
  final double progress; // 0..1
  final int waves;
  final Color color;
  final double strokeWidth;
  final double intensity; // 0..1
  final double reactive; // 0..1
  final bool glow;

  _WavePulsePainter({
    required this.progress,
    required this.waves,
    required this.color,
    required this.strokeWidth,
    required this.intensity,
    required this.reactive,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final double maxRadius = size.shortestSide / 2;
    final double baseMin = maxRadius * 0.58;
    final double baseMax = maxRadius;

    final double amp = (intensity * 0.6 + reactive * 0.4).clamp(0.0, 1.0);
    final double minRadius = baseMin * (1 - 0.06 * amp);
    final double maxR = baseMax * (1 + 0.08 * amp);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..maskFilter = glow ? MaskFilter.blur(BlurStyle.normal, 4 + 6 * amp) : null;

    for (int i = 0; i < waves; i++) {
      final double phase = (progress + i / waves) % 1.0;
      final double r = minRadius + (maxR - minRadius) * phase;
      final double fade = (1.0 - phase).clamp(0.0, 1.0);
      final double alpha = 0.45 * fade * (0.5 + 0.5 * amp);
      glowPaint.color = color.withValues(alpha: alpha * 0.6);
      strokePaint.color = color.withValues(alpha: alpha);

      if (glow) canvas.drawCircle(center, r, glowPaint);
      canvas.drawCircle(center, r, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
