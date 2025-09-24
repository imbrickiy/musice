import 'dart:async';

Future<bool> fsFileExists(String path) async => false;
Future<String> fsReadAsString(String path) async => Future.error('File I/O not supported on web');
Future<void> fsWriteString(String path, String contents) async => Future.error('File I/O not supported on web');

bool fsIsDesktopPlatform() => false;
bool fsSupportsWatchPlatform() => false;

Stream<void>? fsWatchFile(String path) => null;

