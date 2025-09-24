import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';

class RadioHeader extends StatelessWidget {
  final String title;
  final VoidCallback onStationsTap;
  final VoidCallback? onReload;
  final bool showReload;
  final VoidCallback? onSettings;
  final bool showSettings;
  const RadioHeader({
    super.key,
    required this.title,
    required this.onStationsTap,
    this.onReload,
    this.showReload = false,
    this.onSettings,
    this.showSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.l),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.title),
          Row(
            children: [
              if (showSettings)
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: const Key('settingsButton'),
                    customBorder: const CircleBorder(),
                    onTap: onSettings,
                    child: const SizedBox(
                      width: AppDimens.controlM,
                      height: AppDimens.controlM,
                      child: Center(child: Icon(Icons.settings, size: AppDimens.iconM)),
                    ),
                  ),
                ),
              if (showReload)
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: const Key('reloadButton'),
                    customBorder: const CircleBorder(),
                    onTap: onReload,
                    child: const SizedBox(
                      width: AppDimens.controlM,
                      height: AppDimens.controlM,
                      child: Center(child: Icon(Icons.refresh, size: AppDimens.iconM)),
                    ),
                  ),
                ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: const Key('stationsButton'),
                  customBorder: const CircleBorder(),
                  onTap: onStationsTap,
                  child: const SizedBox(
                    width: AppDimens.controlM,
                    height: AppDimens.controlM,
                    child: Center(
                      child: Icon(Icons.podcasts, size: AppDimens.iconM),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
