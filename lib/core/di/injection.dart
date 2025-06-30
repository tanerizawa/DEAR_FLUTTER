// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart'; // File ini akan dibuat oleh generator
import '../../services/notification_service.dart';
import '../../services/quote_update_service.dart';
import '../../data/datasources/remote/home_api_service.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<GetIt> configureDependencies() async {
  await getIt.init();
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<QuoteUpdateService>(
      () => QuoteUpdateService(getIt<HomeApiService>(), getIt<NotificationService>()));
  return getIt;
}
