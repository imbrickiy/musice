import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';

class RadioHeader extends StatelessWidget {
  final VoidCallback onStationsTap;
  const RadioHeader({super.key, required this.onStationsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHeaderHPad, vertical: kHeaderVPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            type: MaterialType.transparency,
            child: Tooltip(
              message: 'Stations',
              child: Semantics(
                button: true,
                label: 'Open stations',
                child: InkWell(
                  key: const Key('stationsButton'),
                  customBorder: const CircleBorder(),
                  onTap: onStationsTap,
                  child: const SizedBox(
                    width: kHeaderButtonSize,
                    height: kHeaderButtonSize,
                    child: Center(
                      child: Icon(Icons.podcasts, size: kHeaderIconSize, color: kIconColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
