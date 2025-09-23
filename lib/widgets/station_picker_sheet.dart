import 'package:flutter/material.dart';
import 'package:musice/models/station.dart';

class StationPickerSheet extends StatelessWidget {
  final List<Station> stations;
  final String? current;
  const StationPickerSheet({super.key, required this.stations, required this.current});

  @override
  Widget build(BuildContext context) {
    final sheetMaxHeight = MediaQuery.of(context).size.height * 0.6;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Select a station',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: sheetMaxHeight),
              child: ListView.separated(
                itemCount: stations.length,
                separatorBuilder: (_, i) => const Divider(height: 1, color: Colors.white12),
                itemBuilder: (context, index) {
                  final s = stations[index];
                  final selected = s.name == current;
                  return ListTile(
                    title: Text(s.name, style: const TextStyle(color: Colors.white)),
                    trailing: selected ? const Icon(Icons.check, color: Colors.white70) : null,
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
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

