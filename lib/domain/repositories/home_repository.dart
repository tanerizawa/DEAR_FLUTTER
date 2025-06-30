import 'package:dear_flutter/domain/entities/home_feed_item.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';

abstract class HomeRepository {
  Future<List<HomeFeedItem>> getHomeFeed();
  Future<MotivationalQuote> getLatestQuote();
}
