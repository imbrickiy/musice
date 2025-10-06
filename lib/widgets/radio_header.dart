import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/icons/app_icons.dart';

class RadioHeader extends StatelessWidget {
  final VoidCallback onStationsTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNextTap;
  final bool? isNextEnabled;
  const RadioHeader({
    super.key,
    required this.onStationsTap,
    this.onSettingsTap,
    this.onNextTap,
    this.isNextEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nextEnabled = (isNextEnabled ?? true) && onNextTap != null;
    final nextColor = nextEnabled ? kIconColor : kIconColor.withOpacity(0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHeaderHPad, vertical: kHeaderVPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            type: MaterialType.transparency,
            child: Tooltip(
              message: l10n.stationsTooltip,
              child: Semantics(
                button: true,
                label: l10n.stationsSemantics,
                child: InkWell(
                  key: const Key('stationsButton'),
                  customBorder: const CircleBorder(),
                  onTap: onStationsTap,
                  child: const SizedBox(
                    width: kHeaderButtonSize,
                    height: kHeaderButtonSize,
                    child: Center(
                      child: Icon(AppIcons.podcasts, size: kHeaderIconSize, color: kIconColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              if (onNextTap != null)
                Material(
                  type: MaterialType.transparency,
                  child: Tooltip(
                    message: l10n.nextStationTooltip,
                    child: Semantics(
                      button: true,
                      enabled: nextEnabled,
                      label: l10n.nextStationSemantics,
                      child: InkWell(
                        key: const Key('nextButton'),
                        customBorder: const CircleBorder(),
                        onTap: nextEnabled ? onNextTap : null,
                        child: SizedBox(
                          width: kHeaderButtonSize,
                          height: kHeaderButtonSize,
                          child: Center(
                            child: Icon(AppIcons.next, size: kHeaderIconSize, color: nextColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (onSettingsTap != null)
                Material(
                  type: MaterialType.transparency,
                  child: Tooltip(
                    message: l10n.settings,
                    child: Semantics(
                      button: true,
                      label: l10n.settings,
                      child: InkWell(
                        key: const Key('settingsButton'),
                        customBorder: const CircleBorder(),
                        onTap: onSettingsTap,
                        child: const SizedBox(
                          width: kHeaderButtonSize,
                          height: kHeaderButtonSize,
                          child: Center(
                            child: Icon(AppIcons.settings, size: kHeaderIconSize, color: kIconColor),
                          ),
                        ),
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
