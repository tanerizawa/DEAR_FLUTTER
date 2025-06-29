import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';

@injectable
class HomeApiService {
  final Dio _dio;
  HomeApiService(this._dio);

  Future<List<HomeFeedItem>> getHomeFeed() async {
    final response = await _dio.get('home-feed');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => HomeFeedItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
