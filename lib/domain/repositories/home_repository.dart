import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:dear_flutter/domain/entities/home_feed.dart';

abstract class HomeRepository {
  Future<HomeFeed> getHomeFeed();
  Future<MotivationalQuote> getLatestQuote();
  Future<AudioTrack?> getLatestMusic();
  Future<List<SongSuggestion>> getMusicSuggestions(String mood);
}
