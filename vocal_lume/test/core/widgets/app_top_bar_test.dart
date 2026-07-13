import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vocal_lume/src/core/routing/app_routes.dart';
import 'package:vocal_lume/src/core/widgets/app_top_bar.dart';

void main() {
  testWidgets('renders title, avatar and search icon by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTopBar(),
        ),
      ),
    );

    expect(find.text('VocaLume'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('hides avatar when showAvatar is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTopBar(showAvatar: false),
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('calls onSearch callback when provided', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTopBar(
            onSearch: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('navigates to podcast search route by default', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home,
          builder: (context, state) => const Scaffold(body: AppTopBar()),
        ),
        GoRoute(
          path: '/search',
          name: AppRoutes.podcastSearch,
          builder: (context, state) => const Scaffold(
            body: Text('Search Screen'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Search Screen'), findsOneWidget);
  });
}
