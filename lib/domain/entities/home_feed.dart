import 'motivational_quote.dart';
import 'audio_track.dart';

class HomeFeed {
  final MotivationalQuote? quote;
  final AudioTrack? music;

  HomeFeed({this.quote, this.music});

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    return HomeFeed(
      quote: json['quote'] != null
          ? MotivationalQuote.fromJson(json['quote'] as Map<String, dynamic>)
          : null,
      music: json['music'] != null
          ? AudioTrack.fromJson(json['music'] as Map<String, dynamic>)
          : null,
    );
  }
}
