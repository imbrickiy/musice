// Platform-agnostic file system helpers for stations JSON
// Uses conditional import to pick IO or Web implementation.
import 'package:musice/services/fs/stations_fs_io.dart'
    if (dart.library.html) 'package:musice/services/fs/stations_fs_web.dart' as impl;

Future<bool> fsFileExists(String path) => impl.fsFileExists(path);
Future<String> fsReadAsString(String path) => impl.fsReadAsString(path);
Future<void> fsWriteString(String path, String contents) => impl.fsWriteString(path, contents);

bool fsIsDesktopPlatform() => impl.fsIsDesktopPlatform();
bool fsSupportsWatchPlatform() => impl.fsSupportsWatchPlatform();

// Emits an event when the file changes (desktop only). Returns null if unsupported.
Stream<void>? fsWatchFile(String path) => impl.fsWatchFile(path);
