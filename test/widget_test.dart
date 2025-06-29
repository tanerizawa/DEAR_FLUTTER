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
import 'package:dear_flutter/presentation/home/screens/article_detail_screen.dart';
import 'package:dear_flutter/presentation/home/screens/audio_player_screen.dart';
import 'package:dear_flutter/domain/entities/article.dart';
import 'package:dear_flutter/domain/entities/audio_track.dart';
import 'package:dear_flutter/domain/entities/motivational_quote.dart';
import 'package:dear_flutter/domain/entities/home_feed_item.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_feed_state.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

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

class _MockNavigatorObserver extends Mock implements NavigatorObserver {}

class _FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(_FakeRoute());
  });

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

  testWidgets('ListView.builder renders correct number of cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // There should be one Card widget for each feed item
    expect(find.byType(Card), findsNWidgets(_sampleItems.length));
  });

  testWidgets('Tapping an article card navigates to ArticleDetailScreen',
      (WidgetTester tester) async {
    final observer = _MockNavigatorObserver();
    final router = GoRouter(
      initialLocation: '/home',
      observers: [observer],
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/article',
          builder: (_, state) =>
              ArticleDetailScreen(article: state.extra as Article),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();

    verify(() => observer.didPush(any(that: predicate<Route<dynamic>>(
            (route) => route.settings.name == '/article')), any()))
        .called(1);
    expect(find.byType(ArticleDetailScreen), findsOneWidget);
  });

  testWidgets('Tapping an audio card opens AudioPlayerScreen',
      (WidgetTester tester) async {
    final observer = _MockNavigatorObserver();
    final router = GoRouter(
      initialLocation: '/home',
      observers: [observer],
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/audio',
          builder: (_, state) =>
              AudioPlayerScreen(track: state.extra as AudioTrack),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('t'));
    await tester.pumpAndSettle();

    verify(() => observer.didPush(any(that: predicate<Route<dynamic>>(
            (route) => route.settings.name == '/audio')), any()))
        .called(1);
    expect(find.byType(AudioPlayerScreen), findsOneWidget);
  });
}
