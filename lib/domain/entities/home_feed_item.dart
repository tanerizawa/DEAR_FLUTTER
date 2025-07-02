import 'package:freezed_annotation/freezed_annotation.dart';

import 'article.dart';
import 'audio_track.dart';
import 'motivational_quote.dart';

part 'home_feed_item.freezed.dart';
part 'home_feed_item.g.dart';

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
sealed class HomeFeedItem with _$HomeFeedItem {
  const factory HomeFeedItem.article({required Article data}) = HomeFeedArticle;
  const factory HomeFeedItem.audio({required AudioTrack data}) = HomeFeedAudio;
  const factory HomeFeedItem.quote({required MotivationalQuote data}) = HomeFeedQuote;

  factory HomeFeedItem.fromJson(Map<String, dynamic> json) => _$HomeFeedItemFromJson(json);
}
