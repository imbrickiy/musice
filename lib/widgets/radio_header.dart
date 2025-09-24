import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';

class RadioHeader extends StatelessWidget {
  final String title;
  final VoidCallback onStationsTap;
  const RadioHeader({super.key, required this.title, required this.onStationsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHeaderHPad, vertical: kHeaderVPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: kHeaderTitleFontSize,
              fontWeight: kHeaderTitleFontWeight,
            ),
          ),
          Material(
            type: MaterialType.transparency,
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
        ],
      ),
    );
  }
}
