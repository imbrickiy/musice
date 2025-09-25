import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Sets the player's source using a manual cache for supported URL types.
/// - HLS/playlist streams (e.g., .m3u8, .m3u, .pls) skip caching and use setUrl.
/// - Finite file-like URLs (.mp3, .aac, .m4a, .wav, .ogg, .opus, .flac) are downloaded
///   via DefaultCacheManager and then played from the cached file path.
/// - On any failure, falls back to setUrl.
Future<void> setUrlWithCache(AudioPlayer player, String url) async {
  final lower = url.toLowerCase();
  final isPlaylist = lower.endsWith('.m3u8') || lower.endsWith('.m3u') || lower.endsWith('.pls');
  final isFileLike = _hasAny(lower, const ['.mp3', '.aac', '.m4a', '.wav', '.ogg', '.opus', '.flac']);

  try {
    if (!isPlaylist && isFileLike && await _isFiniteAudioFile(url)) {
      // Download to cache (if present, returns from cache)
      final file = await DefaultCacheManager().getSingleFile(url);
      await player.setFilePath(file.path);
    } else {
      // For live/HLS/playlist streams or unknown file sizes, use URL directly
      await player.setUrl(url);
    }
  } catch (_) {
    // Fallback to direct URL if caching or file handling fails
    await player.setUrl(url);
  }
}

Future<bool> _isFiniteAudioFile(String url) async {
  try {
    final uri = Uri.parse(url);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    final req = await client.openUrl('HEAD', uri);
    req.followRedirects = true;
    final resp = await req.close();
    client.close(force: true);

    final contentType = resp.headers.value(HttpHeaders.contentTypeHeader) ?? '';
    final lengthStr = resp.headers.value(HttpHeaders.contentLengthHeader);
    final length = lengthStr == null ? null : int.tryParse(lengthStr);

    // Reject HLS playlists and non-audio types
    if (contentType.contains('application/vnd.apple.mpegurl') || !contentType.startsWith('audio/')) {
      return false;
    }
    // Require a finite content length and cap very large files to avoid long prefetch
    if (length == null) return false;
    if (length > 200 * 1024 * 1024) return false; // >200MB: treat as stream, don't cache

    return true;
  } catch (_) {
    return false;
  }
}

bool _hasAny(String s, List<String> suffixes) {
  for (final suf in suffixes) {
    if (s.contains(suf)) return true;
  }
  return false;
}
