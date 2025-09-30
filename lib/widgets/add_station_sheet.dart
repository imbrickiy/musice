import 'package:flutter/material.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/models/station.dart';

class AddStationSheet extends StatefulWidget {
  const AddStationSheet({super.key, this.initial});

  final Station? initial;

  @override
  State<AddStationSheet> createState() => _AddStationSheetState();
}

class _AddStationSheetState extends State<AddStationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final FocusNode _urlFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _nameCtrl.text = s.name;
      _urlCtrl.text = s.url;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  String? _validateRequired(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return l10n.requiredField;
    return null;
  }

  String? _validateUrl(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return l10n.requiredField;
    final s = v.trim();
    Uri? uri;
    try {
      uri = Uri.parse(s);
    } catch (_) {}
    if (uri == null || !(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      return l10n.invalidUrl;
    }
    return null;
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    Navigator.of(context).pop(Station(name, url));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final sheetMaxHeight = media.size.height * 0.7;
    final bottomInset = media.viewInsets.bottom;
    final isEdit = widget.initial != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: kSheetContainerDecoration,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: sheetMaxHeight),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                      child: Text(isEdit ? l10n.editStation : l10n.addStation, style: kSheetTitleTextStyle),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _urlFocus.requestFocus(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: l10n.stationName,
                              labelStyle: const TextStyle(color: Colors.white70),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: kBorderColor),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: kBorderColor),
                              ),
                              errorStyle: const TextStyle(color: Colors.redAccent),
                            ),
                            validator: _validateRequired,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _urlCtrl,
                            focusNode: _urlFocus,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onSave(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: l10n.stationUrl,
                              labelStyle: const TextStyle(color: Colors.white70),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: kBorderColor),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: kBorderColor),
                              ),
                              errorStyle: const TextStyle(color: Colors.redAccent),
                            ),
                            keyboardType: TextInputType.url,
                            validator: _validateUrl,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(l10n.cancel),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: _onSave,
                                child: Text(l10n.save),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
