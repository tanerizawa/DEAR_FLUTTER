// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dear_flutter/presentation/home/screens/home_screen.dart';
import 'package:dear_flutter/domain/entities/article.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';

final _sampleItems = [
  const HomeFeedItem.article(
    data: Article(id: 1, title: 'a', url: 'u'),
  ),
  const HomeFeedItem.audio(
    data: AudioTrack(id: 2, title: 't', url: 'm'),
  ),
  const HomeFeedItem.quote(
    data: MotivationalQuote(id: 3, text: 'q', author: 'au'),
  ),
];

class _FakeHomeFeedCubit extends Cubit<HomeFeedState> implements HomeFeedCubit {
  _FakeHomeFeedCubit()
      : super(const HomeFeedState(
          status: HomeFeedStatus.success,
          items: _sampleItems,
        ));

  @override
  Future<void> fetchHomeFeed() async {}
}

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.registerFactory<HomeFeedCubit>(() => _FakeHomeFeedCubit());
  });

  tearDown(getIt.reset);

  testWidgets('HomeScreen renders feed cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);
    expect(find.text('t'), findsOneWidget);
    expect(find.textContaining('q'), findsOneWidget);
  });
}
