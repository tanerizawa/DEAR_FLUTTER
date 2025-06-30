import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

abstract class HomeRepository {
  Future<MotivationalQuote> getLatestQuote();
  Future<AudioTrack> getLatestMusic();
}
