import 'package:flutter/material.dart';
import 'package:musice/models/station.dart';
import 'package:musice/constants/app_constants.dart';

class StationPickerSheet extends StatelessWidget {
  final List<Station> stations;
  final String? current;
  const StationPickerSheet({super.key, required this.stations, required this.current});

  @override
  Widget build(BuildContext context) {
    final sheetMaxHeight = MediaQuery.of(context).size.height * 0.6;
    return SafeArea(
      child: Padding(
        padding: kSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: kSheetHandleWidth,
              height: kSheetHandleHeight,
              decoration: BoxDecoration(
                color: kDividerColor,
                borderRadius: BorderRadius.circular(kSheetHandleRadius),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: kSheetTitlePadding,
              child: Text(
                'Select a station',
                style: kSheetTitleTextStyle,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: sheetMaxHeight),
              child: ListView.separated(
                itemCount: stations.length,
                separatorBuilder: (_, i) => const Divider(height: 1, color: kSheetDividerColor),
                itemBuilder: (context, index) {
                  final s = stations[index];
                  final selected = s.name == current;
                  return ListTile(
                    title: Text(s.name, style: kSheetListTileTextStyle),
                    trailing: selected ? const Icon(Icons.check, color: kIconColor) : null,
                    onTap: () => Navigator.of(context).pop(s),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      _controller.stop();
      _animation = Tween<double>(begin: _current, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _animation.addListener(() {
        setState(() {
          _current = _animation.value;
        });
        if (widget.onAnimated != null) {
          widget.onAnimated!(_current);
        }
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _current,
      onChanged: widget.onChanged,
      min: 0,
      max: 1,
    );
  }
}
