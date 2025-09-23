import 'package:flutter/material.dart';
import 'package:musice/widgets/wave_pulse.dart';

class PlaySection extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final double volume;
  final double reactiveLevel;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  const PlaySection({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.volume,
    required this.reactiveLevel,
    required this.onPlay,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = isLoading
        ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          )
        : Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 64,
            color: Colors.white70,
          );

    return Center(
      child: SizedBox(
        height: 240,
        width: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: WavePulse(
                active: isPlaying,
                waves: 3,
                color: Colors.white,
                strokeWidth: 1.0,
                intensity: volume,
                reactiveLevel: reactiveLevel,
                glow: true,
              ),
            ),
            AbsorbPointer(
              absorbing: isLoading,
              child: GestureDetector(
                onTap: () => isPlaying ? onPause() : onPlay(),
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: iconWidget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
