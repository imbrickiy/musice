import 'package:flutter/material.dart';
import 'package:musice/widgets/animated_slider.dart';
import 'package:musice/constants/app_constants.dart';

class VolumeSection extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onAnimated;
  const VolumeSection({super.key, required this.value, required this.onChanged, this.onAnimated});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kVolumeSectionBottomPadding),
      child: Column(
        children: [
          SizedBox(
            height: kVolumeControlHeight,
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: kSliderTrackHeight,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                  activeTrackColor: kSliderActiveTrackColor,
                  inactiveTrackColor: kSliderInactiveTrackColor,
                  thumbColor: kSliderThumbColor,
                  overlayColor: kSliderOverlayColor,
                ),
                child: AnimatedSlider(
                  value: value,
                  onChanged: onChanged,
                  onAnimated: onAnimated,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "VOLUME",
            style: TextStyle(
              color: kIconColor,
              fontSize: kVolumeLabelFontSize,
              letterSpacing: kVolumeLabelLetterSpacing,
              fontWeight: kVolumeLabelFontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
