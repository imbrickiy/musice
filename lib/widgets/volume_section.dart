import 'package:flutter/material.dart';
// Removed animated slider to avoid compilation issues
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';

class VolumeSection extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onAnimated;
  const VolumeSection({super.key, required this.value, required this.onChanged, this.onAnimated});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                child: Slider(
                  value: value,
                  onChanged: (v) {
                    onChanged(v);
                    if (onAnimated != null) onAnimated!(v);
                  },
                  min: 0,
                  max: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.volumeLabel,
            style: const TextStyle(
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
