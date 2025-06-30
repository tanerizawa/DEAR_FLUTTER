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
        : (await _yt.videos.streamsClient
                .getManifest(videoIdOrUrl))
            .audioOnly
            .map((e) => AudioInfo(e.bitrate.kiloBitsPerSecond.toInt(), e.url))
            .toList();
    infos.sort((a, b) => a.bitrate.compareTo(b.bitrate));
    return infos.last.url.toString();
  }

  /// Dispose the underlying [YoutubeExplode] client.
  void close() => _yt.close();
}
