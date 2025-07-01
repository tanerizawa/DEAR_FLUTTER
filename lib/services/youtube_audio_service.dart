import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Service to obtain playable audio streams from YouTube videos.
@LazySingleton()
class AudioInfo {
  final int bitrate;
  final Uri url;
  AudioInfo(this.bitrate, this.url);
}

typedef _AudioFetcher = Future<List<AudioInfo>> Function(String id);

Future<List<AudioInfo>> _parseManifest(String id) async {
  final yt = YoutubeExplode();
  try {
    final manifest = await yt.videos.streamsClient.getManifest(id);
    return manifest.audioOnly
        .map((e) => AudioInfo(e.bitrate.kiloBitsPerSecond.toInt(), e.url))
        .toList();
  } finally {
    yt.close();
  }
}

class YoutubeAudioService {
  YoutubeAudioService({YoutubeExplode? client, _AudioFetcher? fetcher})
      : _yt = client ?? YoutubeExplode(),
        _fetcher = fetcher;
  final YoutubeExplode _yt;
  final _AudioFetcher? _fetcher;

  /// Returns the direct audio stream URL for the given YouTube [videoIdOrUrl].
  Future<String> getAudioUrl(String videoIdOrUrl) async {
    final infos = _fetcher != null
        ? await _fetcher!(videoIdOrUrl)
        : await compute(_parseManifest, videoIdOrUrl);
    infos.sort((a, b) => a.bitrate.compareTo(b.bitrate));
    return infos.last.url.toString();
  }

  /// Dispose the underlying [YoutubeExplode] client.
  void close() => _yt.close();
}
