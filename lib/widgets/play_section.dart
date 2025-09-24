// Play button with wave pulse animation
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
            width: AppDimens.iconM,
            height: AppDimens.iconM,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white70),
          )
        : const Icon(
            Icons.pause, // will be overridden below based on isPlaying
            size: AppDimens.iconXL,
            color: AppColors.white70,
          );

    final Widget playIcon = Icon(
      isPlaying ? Icons.pause : Icons.play_arrow,
      size: AppDimens.iconXL,
      color: AppColors.white70,
    );

    return Center(
      child: SizedBox(
        height: AppDimens.playArea,
        width: AppDimens.playArea,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: WavePulse(
                active: isPlaying,
                waves: 3,
                color: AppColors.white,
                strokeWidth: AppDimens.borderThin,
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
                  height: AppDimens.controlL,
                  width: AppDimens.controlL,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white24, width: AppDimens.borderThin),
                  ),
                  alignment: Alignment.center,
                  child: isLoading ? iconWidget : playIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
