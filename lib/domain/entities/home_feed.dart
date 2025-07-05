import 'motivational_quote.dart';
import 'audio_track.dart';

class HomeFeed {
  final MotivationalQuote? quote;
  final AudioTrack? music;
  final List<AudioTrack> playlist;
  final String musicStatus;

  HomeFeed({this.quote, this.music, this.playlist = const [], this.musicStatus = "done"});

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    return HomeFeed(
      quote: json['quote'] != null
          ? MotivationalQuote.fromJson(json['quote'] as Map<String, dynamic>)
          : null,
      music: json['music'] != null
          ? AudioTrack.fromJson(json['music'] as Map<String, dynamic>)
          : null,
      playlist: json['playlist'] != null
          ? (json['playlist'] as List)
              .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      musicStatus: json['music_status'] ?? "done",
    );
  }
}
