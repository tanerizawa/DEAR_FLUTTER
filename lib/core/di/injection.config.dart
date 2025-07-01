// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/datasources/local/app_database.dart' as _i483;
import '../../data/datasources/local/chat_message_dao.dart' as _i109;
import '../../data/datasources/local/journal_dao.dart' as _i28;
import '../../data/datasources/local/user_preferences_repository.dart' as _i324;
import '../../data/datasources/remote/auth_api_service.dart' as _i228;
import '../../data/datasources/remote/chat_api_service.dart' as _i489;
import '../../data/datasources/remote/home_api_service.dart' as _i1004;
import '../../data/datasources/remote/journal_api_service.dart' as _i1020;
import '../../data/datasources/remote/user_api_service.dart' as _i637;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/chat_repository_impl.dart' as _i838;
import '../../data/repositories/home_repository_impl.dart' as _i514;
import '../../data/repositories/journal_repository_impl.dart' as _i625;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/chat_repository.dart' as _i1072;
import '../../domain/repositories/home_repository.dart' as _i826;
import '../../domain/repositories/journal_repository.dart' as _i847;
import '../../domain/usecases/delete_account_usecase.dart' as _i874;
import '../../domain/usecases/get_auth_status_usecase.dart' as _i126;
import '../../domain/usecases/get_chat_history_usecase.dart' as _i992;
import '../../domain/usecases/get_journals_usecase.dart' as _i738;
import '../../domain/usecases/get_latest_music_usecase.dart' as _i77;
import '../../domain/usecases/get_latest_quote_usecase.dart' as _i789;
import '../../domain/usecases/get_music_suggestions_usecase.dart' as _i381;
import '../../domain/usecases/get_user_profile_usecase.dart' as _i629;
import '../../domain/usecases/login_usecase.dart' as _i253;
import '../../domain/usecases/logout_usecase.dart' as _i981;
import '../../domain/usecases/register_usecase.dart' as _i35;
import '../../domain/usecases/save_journal_usecase.dart' as _i415;
import '../../domain/usecases/send_message_usecase.dart' as _i955;
import '../../domain/usecases/sync_journals_usecase.dart' as _i873;
import '../../presentation/auth/cubit/login_cubit.dart' as _i774;
import '../../presentation/auth/cubit/register_cubit.dart' as _i887;
import '../../presentation/chat/cubit/chat_cubit.dart' as _i207;
import '../../presentation/home/cubit/home_cubit.dart' as _i288;
import '../../presentation/home/cubit/latest_music_cubit.dart' as _i186;
import '../../presentation/journal/cubit/journal_editor_cubit.dart' as _i826;
import '../../presentation/profile/cubit/profile_cubit.dart' as _i107;
import '../../services/music_update_service.dart' as _i508;
import '../../services/notification_service.dart' as _i85;
import '../../services/quote_update_service.dart' as _i642;
import '../../services/youtube_audio_service.dart' as _i221;
import '../api/auth_interceptor.dart' as _i577;
import '../api/logging_interceptor.dart' as _i427;
import 'package:hive/hive.dart' as _i1108;
import '../../domain/repositories/song_history_repository.dart' as _i1109;
import '../../data/repositories/song_history_repository_impl.dart' as _i1110;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i483.AppDatabase>(() => registerModule.database);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i427.LoggingInterceptor>(
      () => _i427.LoggingInterceptor(),
    );
    gh.lazySingleton<_i85.NotificationService>(
      () => _i85.NotificationService(),
    );
    gh.lazySingleton<_i324.UserPreferencesRepository>(
      () => _i324.UserPreferencesRepository(gh<_i460.SharedPreferences>()),
    );
    await gh.lazySingletonAsync<_i1108.Box<_i1108.Map>>(
      () => registerModule.songBox,
      preResolve: true,
    );
    gh.lazySingleton<_i28.JournalDao>(
      () => registerModule.journalDao(gh<_i483.AppDatabase>()),
    );
    gh.lazySingleton<_i109.ChatMessageDao>(
      () => registerModule.chatMessageDao(gh<_i483.AppDatabase>()),
    );
    gh.lazySingleton<_i221.YoutubeAudioService>(
      () => _i221.YoutubeAudioService(),
    );
    gh.factory<_i577.AuthInterceptor>(
      () => _i577.AuthInterceptor(gh<_i324.UserPreferencesRepository>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i577.AuthInterceptor>(),
        gh<_i427.LoggingInterceptor>(),
      ),
    );
    gh.factory<_i1004.HomeApiService>(
      () => _i1004.HomeApiService(gh<_i361.Dio>()),
    );
    gh.factory<_i1020.JournalApiService>(
      () => _i1020.JournalApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i637.UserApiService>(
      () => _i637.UserApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i489.ChatApiService>(
      () => _i489.ChatApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i228.AuthApiService>(
      () => _i228.AuthApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i826.HomeRepository>(
      () => _i514.HomeRepositoryImpl(gh<_i1004.HomeApiService>()),
    );
    gh.factory<_i789.GetLatestQuoteUseCase>(
      () => _i789.GetLatestQuoteUseCase(gh<_i826.HomeRepository>()),
    );
    gh.factory<_i77.GetLatestMusicUseCase>(
      () => _i77.GetLatestMusicUseCase(gh<_i826.HomeRepository>()),
    );
    gh.factory<_i381.GetMusicSuggestionsUseCase>(
      () => _i381.GetMusicSuggestionsUseCase(gh<_i826.HomeRepository>()),
    );
    gh.factory<_i186.LatestMusicCubit>(
      () => _i186.LatestMusicCubit(gh<_i381.GetMusicSuggestionsUseCase>()),
    );
    gh.lazySingleton<_i1072.ChatRepository>(
      () => _i838.ChatRepositoryImpl(
        gh<_i489.ChatApiService>(),
        gh<_i109.ChatMessageDao>(),
      ),
    );
    gh.lazySingleton<_i1109.SongHistoryRepository>(
      () => _i1110.SongHistoryRepositoryImpl(
        gh<_i1108.Box<_i1108.Map>>(),
      ),
    );
    gh.factory<_i992.GetChatHistoryUseCase>(
      () => _i992.GetChatHistoryUseCase(gh<_i1072.ChatRepository>()),
    );
    gh.factory<_i955.SendMessageUseCase>(
      () => _i955.SendMessageUseCase(gh<_i1072.ChatRepository>()),
    );
    gh.lazySingleton<_i847.JournalRepository>(
      () => _i625.JournalRepositoryImpl(
        gh<_i1020.JournalApiService>(),
        gh<_i28.JournalDao>(),
      ),
    );
    gh.lazySingleton<_i642.QuoteUpdateService>(
      () => _i642.QuoteUpdateService(
        gh<_i1004.HomeApiService>(),
        gh<_i85.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i1073.AuthRepository>(
      () => _i895.AuthRepositoryImpl(
        gh<_i228.AuthApiService>(),
        gh<_i637.UserApiService>(),
        gh<_i324.UserPreferencesRepository>(),
      ),
    );
    gh.factory<_i207.ChatCubit>(
      () => _i207.ChatCubit(
        gh<_i992.GetChatHistoryUseCase>(),
        gh<_i955.SendMessageUseCase>(),
      ),
    );
    gh.lazySingleton<_i508.MusicUpdateService>(
      () => _i508.MusicUpdateService(gh<_i1004.HomeApiService>()),
    );
    gh.factory<_i629.GetUserProfileUseCase>(
      () => _i629.GetUserProfileUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i35.RegisterUseCase>(
      () => _i35.RegisterUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i253.LoginUseCase>(
      () => _i253.LoginUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i981.LogoutUseCase>(
      () => _i981.LogoutUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i126.GetAuthStatusUseCase>(
      () => _i126.GetAuthStatusUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i874.DeleteAccountUseCase>(
      () => _i874.DeleteAccountUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i415.SaveJournalUseCase>(
      () => _i415.SaveJournalUseCase(gh<_i847.JournalRepository>()),
    );
    gh.factory<_i738.GetJournalsUseCase>(
      () => _i738.GetJournalsUseCase(gh<_i847.JournalRepository>()),
    );
    gh.factory<_i873.SyncJournalsUseCase>(
      () => _i873.SyncJournalsUseCase(gh<_i847.JournalRepository>()),
    );
    gh.factory<_i826.JournalEditorCubit>(
      () => _i826.JournalEditorCubit(gh<_i415.SaveJournalUseCase>()),
    );
    gh.factory<_i288.HomeCubit>(
      () => _i288.HomeCubit(
        gh<_i738.GetJournalsUseCase>(),
        gh<_i873.SyncJournalsUseCase>(),
      ),
    );
    gh.factory<_i107.ProfileCubit>(
      () => _i107.ProfileCubit(
        gh<_i629.GetUserProfileUseCase>(),
        gh<_i981.LogoutUseCase>(),
        gh<_i874.DeleteAccountUseCase>(),
        gh<_i483.AppDatabase>(),
      ),
    );
    gh.factory<_i774.LoginCubit>(
      () => _i774.LoginCubit(gh<_i253.LoginUseCase>()),
    );
    gh.factory<_i887.RegisterCubit>(
      () => _i887.RegisterCubit(gh<_i35.RegisterUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
