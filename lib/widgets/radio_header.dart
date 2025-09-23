import 'package:flutter/material.dart';

class RadioHeader extends StatelessWidget {
  final String title;
  final VoidCallback onStationsTap;
  const RadioHeader({super.key, required this.title, required this.onStationsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const Key('stationsButton'),
              customBorder: const CircleBorder(),
              onTap: onStationsTap,
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: Icon(Icons.podcasts, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
