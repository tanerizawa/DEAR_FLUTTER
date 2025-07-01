import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioInfo {
  final int bitrate;
  final Uri url;
  AudioInfo(this.bitrate, this.url);
}

typedef AudioFetcher = Future<List<AudioInfo>> Function(String id);

@injectable
class YoutubeAudioService {
  final YoutubeExplode yt;
  final AudioFetcher? fetcher;

  YoutubeAudioService(this.yt, {@factoryParam this.fetcher});

  Future<String> getAudioUrl(String videoIdOrUrl) async {
    final infos =
        fetcher != null ? await fetcher!(videoIdOrUrl) : await _fetch(id: videoIdOrUrl);
    infos.sort((a, b) => a.bitrate.compareTo(b.bitrate));
    return infos.last.url.toString();
  }

  Future<List<AudioInfo>> _fetch({required String id}) async {
    final manifest = await yt.videos.streamsClient.getManifest(id);
    return manifest.audioOnly
        .map((e) => AudioInfo(e.bitrate.kiloBitsPerSecond.toInt(), e.url))
        .toList();
  }

  void close() => yt.close();
}
