import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Simple data holder representing an audio stream option from YouTube.
///
/// The [bitrate] is expressed in kbps and the [url] points to the audio
/// content that can be streamed or downloaded.
class AudioInfo {
  /// Bitrate in kilobits per second of the audio stream.
  final int bitrate;

  /// Direct URL to the audio file.
  final Uri url;

  /// Creates an instance of [AudioInfo] with a given [bitrate] and [url].
  AudioInfo(this.bitrate, this.url);
}

/// Signature for a function that retrieves audio info for a YouTube video.
///
/// Implementations should return a list of available [AudioInfo] for the given
/// video identifier.
typedef AudioFetcher = Future<List<AudioInfo>> Function(String id);

@injectable
/// A small wrapper around [YoutubeExplode] to obtain audio-only streams.
class YoutubeAudioService {
  /// Maximum bitrate (in kbps) allowed for playback.
  static const int maxBitrateKbps = 160;
  /// Client used to communicate with the YouTube API.
  final YoutubeExplode yt;

  /// Optional custom fetcher used mainly for testing.
  final AudioFetcher? fetcher;

  /// Creates an instance with an optional [fetcher] for dependency injection.
  YoutubeAudioService(this.yt, {@factoryParam this.fetcher});

  /// Returns the URL to the best available audio-only stream that does not
  /// exceed [maxBitrateKbps].
  ///
  /// [videoIdOrUrl] can be either the ID of a YouTube video or a full URL. The
  /// function resolves available audio streams and picks the highest bitrate
  /// within the allowed range.
  Future<String> getAudioUrl(String videoIdOrUrl) async {
    var infos = fetcher != null
        ? await fetcher!(videoIdOrUrl)
        : await _fetch(id: videoIdOrUrl);
    if (infos.isEmpty) {
      throw StateError('No audio streams found for $videoIdOrUrl');
    }
    infos = infos
        .where((e) => e.bitrate <= maxBitrateKbps)
        .toList();
    if (infos.isEmpty) {
      throw StateError('No audio streams below $maxBitrateKbps kbps');
    }
    infos.sort((a, b) => a.bitrate.compareTo(b.bitrate));
    return infos.last.url.toString();
  }

  Future<List<AudioInfo>> _fetch({required String id}) async {
    final manifest = await yt.videos.streamsClient.getManifest(id);
    final audios = manifest.audioOnly;
    if (audios.isEmpty) {
      return [];
    }
    return audios
        .where((e) => e.bitrate.kiloBitsPerSecond <= maxBitrateKbps)
        .map((e) => AudioInfo(e.bitrate.kiloBitsPerSecond.toInt(), e.url))
        .toList();
  }

  /// Closes the underlying [YoutubeExplode] client and frees resources.
  void close() => yt.close();
}
