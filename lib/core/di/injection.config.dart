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

import '../../data/datasources/local/app_database.dart' as _i483;
import '../../data/datasources/local/journal_dao.dart' as _i28;
import '../../data/datasources/remote/journal_api_service.dart' as _i1020;
import '../../data/repositories/journal_repository_impl.dart' as _i625;
import '../../domain/repositories/journal_repository.dart' as _i847;
import '../../domain/usecases/get_journals_usecase.dart' as _i738;
import '../../presentation/home/cubit/home_cubit.dart' as _i288;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i361.Dio>(() => registerModule.dio);
    gh.singleton<_i483.AppDatabase>(() => registerModule.database);
    gh.factory<_i1020.JournalApiService>(
      () => _i1020.JournalApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i28.JournalDao>(
      () => registerModule.provideJournalDao(gh<_i483.AppDatabase>()),
    );
    gh.factory<_i847.JournalRepository>(
      () => _i625.JournalRepositoryImpl(
        gh<_i1020.JournalApiService>(),
        gh<InvalidType>(),
      ),
    );
    gh.factory<_i738.GetJournalsUseCase>(
      () => _i738.GetJournalsUseCase(gh<_i847.JournalRepository>()),
    );
    gh.factory<_i288.HomeCubit>(
      () => _i288.HomeCubit(gh<_i738.GetJournalsUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
