import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Service that searches YouTube and returns the first video id for a query.
@lazySingleton
class YoutubeSearchService {
  YoutubeSearchService(this._yt);

  final YoutubeExplode _yt;

  /// Returns the video id of the first search result for [query].
  Future<String> searchId(String query) async {
    final results = await _yt.search.search(query);
    final first = await results.first;
    return first.id.value;
  }

  /// Dispose the underlying [YoutubeExplode] client.
  void close() => _yt.close();
}
