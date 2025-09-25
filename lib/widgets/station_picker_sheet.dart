import 'package:flutter/material.dart';
import 'package:musice/models/station.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/icons/app_icons.dart';

class StationPickerSheet extends StatelessWidget {
  final List<Station> stations;
  final String? current;
  const StationPickerSheet({
    super.key,
    required this.stations,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final sheetMaxHeight = MediaQuery.of(context).size.height * 0.6;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: kSheetContainerDecoration,
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
                child: Text(l10n.selectStation, style: kSheetTitleTextStyle),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: sheetMaxHeight),
                child: ListView.separated(
                  itemCount: stations.length,
                  separatorBuilder: (_, i) =>
                      const Divider(height: 1, color: kSheetDividerColor),
                  itemBuilder: (context, index) {
                    final s = stations[index];
                    final selected = s.name == current;
                    return ListTile(
                      title: Text(s.name, style: kSheetListTileTextStyle),
                      trailing: selected
                          ? const Icon(AppIcons.check, color: kIconColor)
                          : null,
                      onTap: () => Navigator.of(context).pop(s),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
