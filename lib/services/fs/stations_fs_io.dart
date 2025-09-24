import 'dart:async';
import 'dart:io';

Future<bool> fsFileExists(String path) async => File(path).exists();
Future<String> fsReadAsString(String path) async => File(path).readAsString();
Future<void> fsWriteString(String path, String contents) async => File(path).writeAsString(contents);

bool fsIsDesktopPlatform() => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
bool fsSupportsWatchPlatform() => fsIsDesktopPlatform();

Stream<void>? fsWatchFile(String path) {
  if (!fsSupportsWatchPlatform()) return null;
  final file = File(path);
  try {
    // Map file modification events to void without returning null explicitly.
    return file.watch(events: FileSystemEvent.modify).map((_) {});
  } catch (_) {
    return null;
  }
}
