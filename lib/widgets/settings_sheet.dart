import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/settings/settings_controller.dart';
import 'package:musice/locale/locale_controller.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: kSheetPadding.add(const EdgeInsets.symmetric(horizontal: kHeaderHPad)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: kSheetHandleWidth,
                  height: kSheetHandleHeight,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(kSheetHandleRadius),
                  ),
                ),
              ),
              const Padding(
                padding: kSheetTitlePadding,
                child: Divider(color: kSheetDividerColor),
              ),
              Padding(
                padding: kSheetTitlePadding.copyWith(top: 0),
                child: Text(l10n.settings, style: kSheetTitleTextStyle),
              ),
              const Divider(color: kSheetDividerColor),

              // Language section
              Padding(
                padding: kSheetTitlePadding.copyWith(top: 12, bottom: 8),
                child: Text(l10n.language, style: kSheetListTileTextStyle.copyWith(fontWeight: FontWeight.w500)),
              ),
              ValueListenableBuilder<Locale?>(
                valueListenable: LocaleController.instance.locale,
                builder: (context, currentLocale, _) {
                  final isSystem = currentLocale == null;
                  final isEn = currentLocale?.languageCode == 'en';
                  final isRu = currentLocale?.languageCode == 'ru';
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(l10n.systemDefault, style: kSheetListTileTextStyle),
                        trailing: isSystem ? const Icon(Icons.check, color: Colors.white70) : null,
                        onTap: () => LocaleController.instance.setLocale(null),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(l10n.languageEnglish, style: kSheetListTileTextStyle),
                        trailing: isEn ? const Icon(Icons.check, color: Colors.white70) : null,
                        onTap: () => LocaleController.instance.setLocale(const Locale('en')),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(l10n.languageRussian, style: kSheetListTileTextStyle),
                        trailing: isRu ? const Icon(Icons.check, color: Colors.white70) : null,
                        onTap: () => LocaleController.instance.setLocale(const Locale('ru')),
                      ),
                    ],
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Divider(color: kSheetDividerColor),
              ),

              // Toggles
              ValueListenableBuilder<bool>(
                valueListenable: SettingsController.instance.autoplayOnLaunch,
                builder: (context, value, _) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(l10n.autoplayOnLaunch, style: kSheetListTileTextStyle),
                  value: value,
                  onChanged: (v) => SettingsController.instance.setAutoplayOnLaunch(v),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: SettingsController.instance.rememberLastStation,
                builder: (context, value, _) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(l10n.rememberLastStation, style: kSheetListTileTextStyle),
                  value: value,
                  onChanged: (v) => SettingsController.instance.setRememberLastStation(v),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
