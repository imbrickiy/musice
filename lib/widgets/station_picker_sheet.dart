import 'package:flutter/material.dart';
import 'package:musice/models/station.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/icons/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:musice/providers/radio_provider.dart';

// Single place enum for station actions in the popup menu
enum _StationAction { edit, delete }

class StationPickerSheet extends StatelessWidget {
  const StationPickerSheet({super.key});

  bool _isEditable(Station s, List<Station> defaultStations) {
    // Встроенный список теперь загружается из JSON
    // Редактируемая, если станция не встроенная по имени или переопределяет встроенный URL
    for (final b in defaultStations) {
      if (b.name == s.name) {
        return b.url != s.url; // переопределение разрешено редактировать/удалять
      }
    }
    return true; // пользовательская
  }

  @override
  Widget build(BuildContext context) {
    final sheetMaxHeight = MediaQuery.of(context).size.height * 0.6;
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<RadioProvider>();
    final stations = provider.stations;
    final current = provider.selected?.name;
    // Получаем список встроенных станций из провайдера
    final defaultStations = provider.defaultStations;

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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l10n.selectStation, style: kSheetTitleTextStyle),
                    ),
                    Tooltip(
                      message: l10n.addStation,
                      child: IconButton(
                        icon: const Icon(AppIcons.add, color: kIconColor),
                        onPressed: () async {
                          await provider.manageAddStation(context);
                          // Do not close or auto-select; let user tap a station explicitly
                          // The list will refresh via provider.watch
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: sheetMaxHeight),
                child: ListView.separated(
                  itemCount: stations.length,
                  separatorBuilder: (_, i) => const Divider(height: 1, color: kSheetDividerColor),
                  itemBuilder: (context, index) {
                    final s = stations[index];
                    final selected = s.name == current;
                    final editable = _isEditable(s, defaultStations);
                    Widget? trailing;
                    if (editable) {
                      trailing = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected) const Icon(AppIcons.check, color: kIconColor),
                          if (selected) const SizedBox(width: 16),
                          PopupMenuButton<_StationAction>(
                            tooltip: l10n.edit,
                            icon: const Icon(AppIcons.edit, color: kIconColor),
                            onSelected: (action) async {
                              switch (action) {
                                case _StationAction.edit:
                                  await provider.manageEditStation(context, s);
                                  break;
                                case _StationAction.delete:
                                  await provider.manageDeleteStation(context, s);
                                  break;
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem<_StationAction>(
                                value: _StationAction.edit,
                                child: Text(l10n.edit),
                              ),
                              PopupMenuItem<_StationAction>(
                                value: _StationAction.delete,
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      trailing = selected ? const Icon(AppIcons.check, color: kIconColor) : null;
                    }

                    return ListTile(
                      title: Text(s.name, style: kSheetListTileTextStyle),
                      trailing: trailing,
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
