import 'package:dear_flutter/domain/entities/home_feed_item.dart';

abstract class HomeRepository {
  Future<List<HomeFeedItem>> getHomeFeed();
}
