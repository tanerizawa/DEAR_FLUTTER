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
import '../../data/datasources/local/journal_dao.dart' as _i28;
import '../../data/datasources/local/user_preferences_repository.dart' as _i324;
import '../../data/datasources/remote/auth_api_service.dart' as _i228;
import '../../data/datasources/remote/journal_api_service.dart' as _i1020;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/journal_repository_impl.dart' as _i625;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/journal_repository.dart' as _i847;
import '../../domain/usecases/get_journals_usecase.dart' as _i738;
import '../../domain/usecases/login_usecase.dart' as _i253;
import '../../domain/usecases/register_usecase.dart' as _i35;
import '../../domain/usecases/save_journal_usecase.dart' as _i415;
import '../../domain/usecases/sync_journals_usecase.dart' as _i873;
import '../../presentation/auth/cubit/login_cubit.dart' as _i774;
import '../../presentation/auth/cubit/register_cubit.dart' as _i887;
import '../../presentation/home/cubit/home_cubit.dart' as _i288;
import '../../presentation/journal/cubit/journal_editor_cubit.dart' as _i826;
import '../api/auth_interceptor.dart' as _i577;
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
    gh.lazySingleton<_i324.UserPreferencesRepository>(
      () => _i324.UserPreferencesRepository(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i28.JournalDao>(
      () => registerModule.journalDao(gh<_i483.AppDatabase>()),
    );
    gh.factory<_i577.AuthInterceptor>(
      () => _i577.AuthInterceptor(gh<_i324.UserPreferencesRepository>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i577.AuthInterceptor>()),
    );
    gh.factory<_i1020.JournalApiService>(
      () => _i1020.JournalApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i228.AuthApiService>(
      () => _i228.AuthApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1073.AuthRepository>(
      () => _i895.AuthRepositoryImpl(
        gh<_i228.AuthApiService>(),
        gh<_i324.UserPreferencesRepository>(),
      ),
    );
    gh.lazySingleton<_i847.JournalRepository>(
      () => _i625.JournalRepositoryImpl(
        gh<_i1020.JournalApiService>(),
        gh<_i28.JournalDao>(),
      ),
    );
    gh.factory<_i35.RegisterUseCase>(
      () => _i35.RegisterUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i253.LoginUseCase>(
      () => _i253.LoginUseCase(gh<_i1073.AuthRepository>()),
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
