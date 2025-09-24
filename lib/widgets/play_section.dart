import 'package:flutter/material.dart';
import 'package:musice/widgets/wave_pulse.dart';
import 'package:musice/constants/app_constants.dart';

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
            width: kLoaderSize,
            height: kLoaderSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: kIconColor),
          )
        : Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: kPlayIconSize,
            color: kIconColor,
          );

    return Center(
      child: SizedBox(
        height: kPlayOuterSize,
        width: kPlayOuterSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: WavePulse(
                active: isPlaying,
                waves: kWaveCount,
                color: kWaveColor,
                strokeWidth: kWaveStrokeWidth,
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
                  height: kPlayInnerSize,
                  width: kPlayInnerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPlayBorderColor, width: kPlayBorderWidth),
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
