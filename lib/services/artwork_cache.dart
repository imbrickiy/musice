import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class ArtworkCache {
  ArtworkCache._();
  static final ArtworkCache instance = ArtworkCache._();

  Uri? _defaultArtUri;

  /// Returns a file:// URI to a cached copy of the default artwork image.
  /// This avoids asset:// resolution issues in background/lock screen contexts.
  Future<Uri> getDefaultArtworkUri() async {
    if (_defaultArtUri != null) return _defaultArtUri!;
    // Load asset bytes
    final ByteData data = await rootBundle.load('lib/assets/splash.png');
    final Uint8List bytes = data.buffer.asUint8List();
    // Write to temp file
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/default_art.png');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsBytes(bytes, flush: true);
    _defaultArtUri = Uri.file(file.path);
    return _defaultArtUri!;
  }
}

