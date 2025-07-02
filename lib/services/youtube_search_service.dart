import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Service that searches YouTube and returns the first result.
@lazySingleton
class YoutubeSearchService {
  YoutubeSearchService(this._yt);

  final YoutubeExplode _yt;

  /// Returns the first result for [query] including id and thumbnail.
  Future<YoutubeSearchResult> search(String query) async {
    final results = await _yt.search.search(query);
    final first = await results.first;
    return YoutubeSearchResult(first.id.value, first.thumbnails.highResUrl);
  }

  /// Dispose the underlying [YoutubeExplode] client.
  void close() => _yt.close();
}

/// Simple data holder for a YouTube search result.
class YoutubeSearchResult {
  YoutubeSearchResult(this.id, this.thumbnailUrl);

  final String id;
  final String thumbnailUrl;
}
