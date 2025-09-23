import 'package:flutter/material.dart';
import 'package:musice/widgets/station_picker_sheet.dart';

class VolumeSection extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onAnimated;
  const VolumeSection({super.key, required this.value, required this.onChanged, this.onAnimated});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white54,
                  thumbColor: Colors.transparent,
                  overlayColor: Colors.white24,
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
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
