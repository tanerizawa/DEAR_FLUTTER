// lib/core/di/register_module.dart

import 'package:dear_flutter/core/api/auth_interceptor.dart';
import 'package:dear_flutter/core/api/logging_interceptor.dart';
import 'package:dear_flutter/core/config/app_config.dart';
import 'package:dear_flutter/data/datasources/local/app_database.dart';
import 'package:dear_flutter/data/datasources/local/chat_message_dao.dart';
import 'package:dear_flutter/data/datasources/local/journal_dao.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

@module
abstract class RegisterModule {
  // --- NETWORK ---
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
      ),
    );

    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(loggingInterceptor);

    return dio;
  }

  // --- DATABASE ---
  @singleton
  AppDatabase get database => AppDatabase();

  @lazySingleton
  JournalDao journalDao(AppDatabase db) => db.journalDao;

  @lazySingleton
  ChatMessageDao chatMessageDao(AppDatabase db) => db.chatMessageDao;

  // --- PREFERENCES ---
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @Named('songBox')
  @preResolve
  @lazySingleton
  Future<Box<Map>> get songBox => Hive.openBox<Map>('song_history');

  @Named('suggestionBox')
  @preResolve
  @lazySingleton
  Future<Box<Map>> get suggestionBox =>
      Hive.openBox<Map>('song_suggestions');

  @Named('quoteBox')
  @preResolve
  @lazySingleton
  Future<Box<Map>> get quoteBox => Hive.openBox<Map>('motivational_quotes');

  @Named('latestMusicBox')
  @preResolve
  @lazySingleton
  Future<Box<Map>> get latestMusicBox =>
      Hive.openBox<Map>('latest_music');

  // --- AUDIO ---
  @lazySingleton
  YoutubeExplode youtubeExplode() => YoutubeExplode();

  @lazySingleton
  AudioLoadConfiguration audioLoadConfiguration() =>
      const AudioLoadConfiguration();

  @lazySingleton
  AudioPlayer audioPlayer(AudioLoadConfiguration config) =>
      AudioPlayer(audioLoadConfiguration: config);
}
