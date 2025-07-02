import 'package:dear_flutter/presentation/home/cubit/latest_music_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_music_state.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/latest_quote_state.dart';
import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/song_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _CachedMusicCubit extends Cubit<LatestMusicState>
    implements LatestMusicCubit {
  _CachedMusicCubit()
      : super(const LatestMusicState(
          status: LatestMusicStatus.cached,
          suggestions: [SongSuggestion(title: 't', artist: 'a')],
        ));

  @override
  Future<void> fetchLatestMusic() async {}
}

class _CachedQuoteCubit extends Cubit<LatestQuoteState>
    implements LatestQuoteCubit {
  _CachedQuoteCubit()
      : super(const LatestQuoteState(
          status: LatestQuoteStatus.cached,
          quote: MotivationalQuote(id: 1, text: 'q', author: 'a'),
        ));

  @override
  Future<void> fetchLatestQuote() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.registerFactory<LatestMusicCubit>(() => _CachedMusicCubit());
    getIt.registerFactory<LatestQuoteCubit>(() => _CachedQuoteCubit());
  });

  tearDown(getIt.reset);

  testWidgets('displays cached quote and music cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('"q"'), findsOneWidget);
    expect(find.text('a'), findsNWidgets(2));
    expect(find.text('t'), findsOneWidget);
  });
}
