// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dear_flutter/core/api/auth_interceptor.dart' as _i498;
import 'package:dear_flutter/core/api/logging_interceptor.dart' as _i989;
import 'package:dear_flutter/core/di/register_module.dart' as _i955;
import 'package:dear_flutter/data/datasources/local/app_database.dart' as _i402;
import 'package:dear_flutter/data/datasources/local/chat_message_dao.dart'
    as _i596;
import 'package:dear_flutter/data/datasources/local/journal_dao.dart' as _i1044;
import 'package:dear_flutter/data/datasources/local/user_preferences_repository.dart'
    as _i1030;
import 'package:dear_flutter/data/datasources/remote/auth_api_service.dart'
    as _i281;
import 'package:dear_flutter/data/datasources/remote/chat_api_service.dart'
    as _i1065;
import 'package:dear_flutter/data/datasources/remote/home_api_service.dart'
    as _i104;
import 'package:dear_flutter/data/datasources/remote/journal_api_service.dart'
    as _i416;
import 'package:dear_flutter/data/datasources/remote/user_api_service.dart'
    as _i922;
import 'package:dear_flutter/data/repositories/auth_repository_impl.dart'
    as _i975;
import 'package:dear_flutter/data/repositories/chat_repository_impl.dart'
    as _i41;
import 'package:dear_flutter/data/repositories/home_repository_impl.dart'
    as _i405;
import 'package:dear_flutter/data/repositories/journal_repository_impl.dart'
    as _i485;
import 'package:dear_flutter/data/repositories/quote_cache_repository_impl.dart'
    as _i658;
import 'package:dear_flutter/data/repositories/latest_music_cache_repository_impl.dart'
    as _i710;
import 'package:dear_flutter/data/repositories/song_history_repository_impl.dart'
    as _i227;
import 'package:dear_flutter/data/repositories/song_suggestion_cache_repository_impl.dart'
    as _i14;
import 'package:dear_flutter/domain/repositories/auth_repository.dart' as _i528;
import 'package:dear_flutter/domain/repositories/chat_repository.dart' as _i374;
import 'package:dear_flutter/domain/repositories/home_repository.dart' as _i34;
import 'package:dear_flutter/domain/repositories/journal_repository.dart'
    as _i614;
import 'package:dear_flutter/domain/repositories/quote_cache_repository.dart'
    as _i139;
import 'package:dear_flutter/domain/repositories/latest_music_cache_repository.dart'
    as _i709;
import 'package:dear_flutter/domain/repositories/song_history_repository.dart'
    as _i448;
import 'package:dear_flutter/domain/repositories/song_suggestion_cache_repository.dart'
    as _i176;
import 'package:dear_flutter/domain/usecases/delete_account_usecase.dart'
    as _i945;
import 'package:dear_flutter/domain/usecases/get_auth_status_usecase.dart'
    as _i294;
import 'package:dear_flutter/domain/usecases/get_chat_history_usecase.dart'
    as _i819;
import 'package:dear_flutter/domain/usecases/get_journals_usecase.dart'
    as _i300;
import 'package:dear_flutter/domain/usecases/get_latest_music_usecase.dart'
    as _i763;
import 'package:dear_flutter/domain/usecases/get_latest_quote_usecase.dart'
    as _i345;
import 'package:dear_flutter/domain/usecases/get_music_suggestions_usecase.dart'
    as _i183;
import 'package:dear_flutter/domain/usecases/get_user_profile_usecase.dart'
    as _i222;
import 'package:dear_flutter/domain/usecases/login_usecase.dart' as _i85;
import 'package:dear_flutter/domain/usecases/logout_usecase.dart' as _i593;
import 'package:dear_flutter/domain/usecases/register_usecase.dart' as _i602;
import 'package:dear_flutter/domain/usecases/save_journal_usecase.dart'
    as _i971;
import 'package:dear_flutter/domain/usecases/send_message_usecase.dart'
    as _i696;
import 'package:dear_flutter/domain/usecases/sync_journals_usecase.dart'
    as _i677;
import 'package:dear_flutter/presentation/auth/cubit/login_cubit.dart' as _i561;
import 'package:dear_flutter/presentation/auth/cubit/register_cubit.dart'
    as _i279;
import 'package:dear_flutter/presentation/chat/cubit/chat_cubit.dart' as _i195;
import 'package:dear_flutter/presentation/home/cubit/home_cubit.dart' as _i941;
import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart'
    as _i119;
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart'
    as _i568;
import 'package:dear_flutter/presentation/journal/cubit/journal_editor_cubit.dart'
    as _i114;
import 'package:dear_flutter/presentation/profile/cubit/profile_cubit.dart'
    as _i776;
import 'package:dear_flutter/services/audio_player_handler.dart' as _i133;
import 'package:dear_flutter/services/music_update_service.dart' as _i434;
import 'package:dear_flutter/services/notification_service.dart' as _i448;
import 'package:dear_flutter/services/quote_update_service.dart' as _i500;
import 'package:dear_flutter/services/youtube_audio_service.dart' as _i288;
import 'package:dear_flutter/services/youtube_search_service.dart' as _i510;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;
import 'package:just_audio/just_audio.dart' as _i501;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as _i578;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i402.AppDatabase>(() => registerModule.database);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i578.YoutubeExplode>(
      () => registerModule.youtubeExplode(),
    );
    gh.lazySingleton<_i501.AudioPlayer>(() => registerModule.audioPlayer());
    gh.lazySingleton<_i501.AudioLoadConfiguration>(
      () => registerModule.audioLoadConfiguration(),
    );
    gh.lazySingleton<_i989.LoggingInterceptor>(
      () => _i989.LoggingInterceptor(),
    );
    gh.lazySingleton<_i448.NotificationService>(
      () => _i448.NotificationService(),
    );
    gh.lazySingleton<_i1030.UserPreferencesRepository>(
      () => _i1030.UserPreferencesRepository(gh<_i460.SharedPreferences>()),
    );
    await gh.lazySingletonAsync<_i979.Box<Map<dynamic, dynamic>>>(
      () => registerModule.songBox,
      instanceName: 'songBox',
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i979.Box<Map<dynamic, dynamic>>>(
      () => registerModule.suggestionBox,
      instanceName: 'suggestionBox',
      preResolve: true,
    );
    gh.lazySingleton<_i448.SongHistoryRepository>(
      () => _i227.SongHistoryRepositoryImpl(
        gh<_i979.Box<Map<dynamic, dynamic>>>(instanceName: 'songBox'),
      ),
    );
    gh.lazySingleton<_i1044.JournalDao>(
      () => registerModule.journalDao(gh<_i402.AppDatabase>()),
    );
    gh.lazySingleton<_i596.ChatMessageDao>(
      () => registerModule.chatMessageDao(gh<_i402.AppDatabase>()),
    );
    gh.factoryParam<_i288.YoutubeAudioService, _i288.AudioFetcher?, dynamic>(
      (fetcher, _) => _i288.YoutubeAudioService(
        gh<_i578.YoutubeExplode>(),
        fetcher: fetcher,
      ),
    );
    await gh.lazySingletonAsync<_i979.Box<Map<dynamic, dynamic>>>(
      () => registerModule.quoteBox,
      instanceName: 'quoteBox',
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i979.Box<Map<dynamic, dynamic>>>(
      () => registerModule.latestMusicBox,
      instanceName: 'latestMusicBox',
      preResolve: true,
    );
    gh.lazySingleton<_i176.SongSuggestionCacheRepository>(
      () => _i14.SongSuggestionCacheRepositoryImpl(
        gh<_i979.Box<Map<dynamic, dynamic>>>(instanceName: 'suggestionBox'),
      ),
    );
    gh.lazySingleton<_i510.YoutubeSearchService>(
      () => _i510.YoutubeSearchService(gh<_i578.YoutubeExplode>()),
    );
    gh.lazySingleton<_i139.QuoteCacheRepository>(
      () => _i658.QuoteCacheRepositoryImpl(
        gh<_i979.Box<Map<dynamic, dynamic>>>(instanceName: 'quoteBox'),
      ),
    );
    gh.lazySingleton<_i709.LatestMusicCacheRepository>(
      () => _i710.LatestMusicCacheRepositoryImpl(
        gh<_i979.Box<Map<dynamic, dynamic>>>(instanceName: 'latestMusicBox'),
      ),
    );
    gh.factory<_i498.AuthInterceptor>(
      () => _i498.AuthInterceptor(gh<_i1030.UserPreferencesRepository>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i498.AuthInterceptor>(),
        gh<_i989.LoggingInterceptor>(),
      ),
    );
    gh.lazySingleton<_i133.AudioPlayerHandler>(
      () => _i133.AudioPlayerHandler(
        gh<_i288.YoutubeAudioService>(),
        player: gh<_i501.AudioPlayer>(),
        loadConfiguration: gh<_i501.AudioLoadConfiguration>(),
      ),
    );
    gh.factory<_i104.HomeApiService>(
      () => _i104.HomeApiService(gh<_i361.Dio>()),
    );
    gh.factory<_i416.JournalApiService>(
      () => _i416.JournalApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i922.UserApiService>(
      () => _i922.UserApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1065.ChatApiService>(
      () => _i1065.ChatApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i281.AuthApiService>(
      () => _i281.AuthApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i34.HomeRepository>(
      () => _i405.HomeRepositoryImpl(gh<_i104.HomeApiService>()),
    );
    gh.lazySingleton<_i500.QuoteUpdateService>(
      () => _i500.QuoteUpdateService(
        gh<_i104.HomeApiService>(),
        gh<_i448.NotificationService>(),
        gh<_i139.QuoteCacheRepository>(),
      ),
    );
    gh.factory<_i345.GetLatestQuoteUseCase>(
      () => _i345.GetLatestQuoteUseCase(gh<_i34.HomeRepository>()),
    );
    gh.factory<_i763.GetLatestMusicUseCase>(
      () => _i763.GetLatestMusicUseCase(gh<_i34.HomeRepository>()),
    );
    gh.factory<_i183.GetMusicSuggestionsUseCase>(
      () => _i183.GetMusicSuggestionsUseCase(gh<_i34.HomeRepository>()),
    );
    gh.lazySingleton<_i374.ChatRepository>(
      () => _i41.ChatRepositoryImpl(
        gh<_i1065.ChatApiService>(),
        gh<_i596.ChatMessageDao>(),
      ),
    );
    gh.factory<_i819.GetChatHistoryUseCase>(
      () => _i819.GetChatHistoryUseCase(gh<_i374.ChatRepository>()),
    );
    gh.factory<_i696.SendMessageUseCase>(
      () => _i696.SendMessageUseCase(gh<_i374.ChatRepository>()),
    );
    gh.lazySingleton<_i614.JournalRepository>(
      () => _i485.JournalRepositoryImpl(
        gh<_i416.JournalApiService>(),
        gh<_i1044.JournalDao>(),
      ),
    );
    gh.lazySingleton<_i528.AuthRepository>(
      () => _i975.AuthRepositoryImpl(
        gh<_i281.AuthApiService>(),
        gh<_i922.UserApiService>(),
        gh<_i1030.UserPreferencesRepository>(),
      ),
    );
    gh.factory<_i195.ChatCubit>(
      () => _i195.ChatCubit(
        gh<_i819.GetChatHistoryUseCase>(),
        gh<_i696.SendMessageUseCase>(),
      ),
    );
    gh.lazySingleton<_i434.MusicUpdateService>(
      () => _i434.MusicUpdateService(
        gh<_i104.HomeApiService>(),
        gh<_i709.LatestMusicCacheRepository>(),
      ),
    );
    gh.factory<_i568.LatestQuoteCubit>(
      () => _i568.LatestQuoteCubit(gh<_i500.QuoteUpdateService>()),
    );
    gh.factory<_i222.GetUserProfileUseCase>(
      () => _i222.GetUserProfileUseCase(gh<_i528.AuthRepository>()),
    );
    gh.factory<_i602.RegisterUseCase>(
      () => _i602.RegisterUseCase(gh<_i528.AuthRepository>()),
    );
    gh.factory<_i85.LoginUseCase>(
      () => _i85.LoginUseCase(gh<_i528.AuthRepository>()),
    );
    gh.factory<_i593.LogoutUseCase>(
      () => _i593.LogoutUseCase(gh<_i528.AuthRepository>()),
    );
    gh.factory<_i294.GetAuthStatusUseCase>(
      () => _i294.GetAuthStatusUseCase(gh<_i528.AuthRepository>()),
    );
    gh.factory<_i945.DeleteAccountUseCase>(
      () => _i945.DeleteAccountUseCase(gh<_i528.AuthRepository>()),
    );
    gh.factory<_i971.SaveJournalUseCase>(
      () => _i971.SaveJournalUseCase(gh<_i614.JournalRepository>()),
    );
    gh.factory<_i300.GetJournalsUseCase>(
      () => _i300.GetJournalsUseCase(gh<_i614.JournalRepository>()),
    );
    gh.factory<_i677.SyncJournalsUseCase>(
      () => _i677.SyncJournalsUseCase(gh<_i614.JournalRepository>()),
    );
    gh.factory<_i114.JournalEditorCubit>(
      () => _i114.JournalEditorCubit(gh<_i971.SaveJournalUseCase>()),
    );
    gh.factory<_i941.HomeCubit>(
      () => _i941.HomeCubit(
        gh<_i300.GetJournalsUseCase>(),
        gh<_i677.SyncJournalsUseCase>(),
      ),
    );
    gh.factory<_i119.LatestMusicCubit>(
      () => _i119.LatestMusicCubit(gh<_i434.MusicUpdateService>()),
    );
    gh.factory<_i776.ProfileCubit>(
      () => _i776.ProfileCubit(
        gh<_i222.GetUserProfileUseCase>(),
        gh<_i593.LogoutUseCase>(),
        gh<_i945.DeleteAccountUseCase>(),
        gh<_i402.AppDatabase>(),
      ),
    );
    gh.factory<_i561.LoginCubit>(
      () => _i561.LoginCubit(gh<_i85.LoginUseCase>()),
    );
    gh.factory<_i279.RegisterCubit>(
      () => _i279.RegisterCubit(gh<_i602.RegisterUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i955.RegisterModule {}
