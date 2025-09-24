import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/icons/app_icons.dart';

class RadioHeader extends StatelessWidget {
  final VoidCallback onStationsTap;
  final VoidCallback? onLanguageTap;
  const RadioHeader({super.key, required this.onStationsTap, this.onLanguageTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          if (onLanguageTap != null)
            Material(
              type: MaterialType.transparency,
              child: Tooltip(
                message: l10n.language,
                child: Semantics(
                  button: true,
                  label: l10n.language,
                  child: InkWell(
                    key: const Key('languageButton'),
                    customBorder: const CircleBorder(),
                    onTap: onLanguageTap,
                    child: const SizedBox(
                      width: kHeaderButtonSize,
                      height: kHeaderButtonSize,
                      child: Center(
                        child: Icon(AppIcons.language, size: kHeaderIconSize, color: kIconColor),
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
