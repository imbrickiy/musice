import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/icons/app_icons.dart';

class LanguagePickerSheet extends StatelessWidget {
  final Locale? current;
  const LanguagePickerSheet({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <_LangOption>[
      _LangOption(null, l10n.systemDefault),
      _LangOption(const Locale('en'), l10n.languageEnglish),
      _LangOption(const Locale('ru'), l10n.languageRussian),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(kDefaultRadius)),
            border: Border.all(color: kBorderColor, width: 1),
          ),
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
              Padding(
                padding: kSheetTitlePadding,
                child: Text(
                  l10n.language,
                  style: kSheetTitleTextStyle,
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, i) => const Divider(height: 1, color: kSheetDividerColor),
                itemBuilder: (context, index) {
                  final opt = options[index];
                  final selected = (opt.locale == null && current == null) || (opt.locale?.languageCode == current?.languageCode);
                  return ListTile(
                    title: Text(opt.label, style: kSheetListTileTextStyle),
                    trailing: selected ? const Icon(AppIcons.check, color: kIconColor) : null,
                    onTap: () => Navigator.of(context).pop(opt.locale),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangOption {
  final Locale? locale;
  final String label;
  const _LangOption(this.locale, this.label);
}
