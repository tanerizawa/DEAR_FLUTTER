import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';

@injectable
class HomeApiService {
  final Dio _dio;
  HomeApiService(this._dio);

  Future<MotivationalQuote> getLatestQuote() async {
    final response = await _dio.get('quotes/latest/');
    return MotivationalQuote.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<AudioTrack> getLatestMusic() async {
    final response = await _dio.get('music/latest/');
    return AudioTrack.fromJson(response.data as Map<String, dynamic>);
  }
}
