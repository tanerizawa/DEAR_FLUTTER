//lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import hasil generate injectable dan module utama
import 'injection.config.dart'; // <--- auto-generated oleh build_runner

final getIt = GetIt.instance;

/// Inisialisasi semua dependency dari module-module injectable.
/// Tidak ada @module atau pendaftaran manual di file ini!
@InjectableInit()
Future<GetIt> configureDependencies() async => await getIt.init();
