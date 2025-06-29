import 'package:freezed_annotation/freezed_annotation.dart';

import 'article.dart';
import 'audio_track.dart';
import 'motivational_quote.dart';

part 'home_feed_item.freezed.dart';

@freezed
class HomeFeedItem with _$HomeFeedItem {
  const factory HomeFeedItem.article({required Article data}) = HomeFeedArticle;
  const factory HomeFeedItem.audio({required AudioTrack data}) = HomeFeedAudio;
  const factory HomeFeedItem.quote({required MotivationalQuote data}) =
      HomeFeedQuote;

  factory HomeFeedItem.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'article':
        return HomeFeedItem.article(
            data: Article.fromJson(json['data'] as Map<String, dynamic>));
      case 'audio':
        return HomeFeedItem.audio(
            data: AudioTrack.fromJson(json['data'] as Map<String, dynamic>));
      case 'quote':
        return HomeFeedItem.quote(
            data:
                MotivationalQuote.fromJson(json['data'] as Map<String, dynamic>));
      default:
        throw UnsupportedError('Unknown type: ${json['type']}');
    }
  }
}
