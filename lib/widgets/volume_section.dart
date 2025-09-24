// Description: Volume control section with a vertical slider and label.
import 'package:flutter/material.dart';
import 'package:musice/widgets/station_picker_sheet.dart';
import 'package:musice/constants/app_constants.dart';

class VolumeSection extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onAnimated;
  const VolumeSection({super.key, required this.value, required this.onChanged, this.onAnimated});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        children: [
          SizedBox(
            height: AppDimens.controlL,
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: AppDimens.trackHeight,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                  activeTrackColor: AppColors.white,
                  inactiveTrackColor: AppColors.white54,
                  thumbColor: AppColors.transparent,
                  overlayColor: AppColors.white24,
                ),
                child: AnimatedSlider(
                  value: value,
                  onChanged: onChanged,
                  onAnimated: onAnimated,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            "VOLUME",
            style: AppTextStyles.labelCaps,
          ),
        ],
      ),
    );
  }
}
