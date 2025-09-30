import 'package:just_audio/just_audio.dart';

/// Streams audio directly from a URL.
///
/// This app does not provide any audio/video downloading, saving, or
/// offline caching functionality. All playback occurs via network
/// streaming consistent with App Store Review Guideline 5.2.3.
Future<void> setUrlWithCache(AudioPlayer player, String url) async {
  // Always stream from the URL; no caching/downloading.
  await player.setUrl(url);
}
