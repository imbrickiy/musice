import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/models/station.dart';
import 'package:musice/services/stations_repository.dart';

class StationsSettingsScreen extends StatefulWidget {
  final StationsRepository repo;
  final List<Station> initial;
  const StationsSettingsScreen({super.key, required this.repo, required this.initial});

  @override
  State<StationsSettingsScreen> createState() => _StationsSettingsScreenState();
}

class _EditableStation {
  String name;
  String url;
  _EditableStation(this.name, this.url);
}

class _StationsSettingsScreenState extends State<StationsSettingsScreen> {
  late List<_EditableStation> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.initial.map((s) => _EditableStation(s.name, s.url)).toList();
    if (_items.isEmpty) _items.add(_EditableStation('', ''));
  }

  List<Station> _toStations() => _items
      .where((e) => e.name.trim().isNotEmpty && e.url.trim().isNotEmpty)
      .map((e) => Station(e.name.trim(), e.url.trim()))
      .toList();

  void _addItem() {
    setState(() => _items.add(_EditableStation('', '')));
  }

  void _removeAt(int index) {
    setState(() => _items.removeAt(index));
  }

  void _applyAndClose() {
    Navigator.of(context).pop<List<Station>>(_toStations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stations', style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(onPressed: _applyAndClose, child: const Text('Apply')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white24, width: AppDimens.borderThin),
              borderRadius: AppRadii.brM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: item.name),
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) => item.name = v,
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: TextEditingController(text: item.url),
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'URL'),
                  onChanged: (v) => item.url = v,
                ),
                const SizedBox(height: AppSpacing.s),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _removeAt(index),
                    child: const Text('Remove'),
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add station',
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
