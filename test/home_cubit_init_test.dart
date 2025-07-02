import 'package:dear_flutter/domain/usecases/get_journals_usecase.dart';
import 'package:dear_flutter/domain/usecases/sync_journals_usecase.dart';
import 'package:dear_flutter/presentation/home/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetJournalsUseCase extends Mock implements GetJournalsUseCase {}

class _MockSyncJournalsUseCase extends Mock implements SyncJournalsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initialize only triggers sync once', () async {
    final get = _MockGetJournalsUseCase();
    final sync = _MockSyncJournalsUseCase();
    when(() => get()).thenAnswer((_) => const Stream.empty());
    when(() => sync()).thenAnswer((_) async {});

    final cubit = HomeCubit(get, sync);
    cubit.initialize();

    verify(() => sync()).called(1);
  });
}
