import 'package:dear_flutter/data/datasources/remote/home_api_service.dart';
import 'package:dear_flutter/data/repositories/home_repository_impl.dart';
import 'package:dear_flutter/domain/entities/article.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == 'home-feed/') {
      handler.resolve(
        Response(requestOptions: options, data: [
          {
            'type': 'article',
            'data': {'id': 1, 'title': 'a', 'url': 'u'}
          },
          {
            'type': 'audio',
            'data': {'id': 2, 'title': 't', 'url': 'm'}
          },
          {
            'type': 'quote',
            'data': {'id': 3, 'text': 'q', 'author': 'au'}
          },
        ]),
      );
    } else {
      handler.reject(DioException(requestOptions: options, error: 'unexpected'));
    }
  }
}

void main() {
  test('HomeRepositoryImpl parses feed items', () async {
    final dio = Dio();
    dio.interceptors.add(_FakeInterceptor());
    final service = HomeApiService(dio);
    final repo = HomeRepositoryImpl(service);

    final items = await repo.getHomeFeed();

    expect(items.length, 3);
    expect(items[0], const HomeFeedItem.article(data: Article(id: 1, title: 'a', url: 'u')));
    expect(items[1], const HomeFeedItem.audio(data: AudioTrack(id: 2, title: 't', url: 'm')));
    expect(items[2], const HomeFeedItem.quote(data: MotivationalQuote(id: 3, text: 'q', author: 'au')));
  });
}
