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
import 'package:dear_flutter/presentation/home/cubit/home_cubit.dart';
import 'package:dear_flutter/presentation/home/cubit/home_state.dart';

class _FakeHomeCubit extends Cubit<HomeState> implements HomeCubit {
  _FakeHomeCubit() : super(const HomeState());

  @override
  Future<void> syncJournals() async {}

  @override
  void watchJournals() {}
}

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.registerFactory<HomeCubit>(() => _FakeHomeCubit());
  });

  tearDown(getIt.reset);

  testWidgets('HomeScreen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });
}
