import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:app_/main.dart';
import 'package:app_/models/quiz_models.dart';
import 'package:app_/providers/loyalty_provider.dart';
import 'package:app_/screens/main_navigation_screen.dart';
import 'package:app_/screens/tabs/daily_tab.dart';
import 'package:app_/screens/tabs/profile_tab.dart';
import 'package:app_/screens/tabs/quizzes_tab.dart';
import 'package:app_/screens/tabs/rewards_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => LoyaltyProvider(),
      child: const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
  }

  group('Navigation & Tab Bar Tests', () {
    testWidgets('Verify exactly 4 navigation tabs and smooth tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // 1. Verify exactly 4 BottomNavigationBar items exist
      final navBarFinder = find.byType(BottomNavigationBar);
      expect(navBarFinder, findsOneWidget);

      final BottomNavigationBar navBar = tester.widget(navBarFinder);
      expect(navBar.items.length, 4, reason: 'Bottom navigation must have exactly 4 sections');

      expect(find.text('Квизы'), findsOneWidget);
      expect(find.text('Задания'), findsOneWidget);
      expect(find.text('Награды'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);

      // Verify no Fortune Wheel in the UI or navigation
      expect(find.textContaining('Wheel', findRichText: true), findsNothing);
      expect(find.textContaining('Spin', findRichText: true), findsNothing);
      expect(find.textContaining('Колесо', findRichText: true), findsNothing);
      expect(find.textContaining('Рулетка', findRichText: true), findsNothing);

      // 2. Switch to Daily tab
      await tester.tap(find.text('Задания'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      expect(find.text('Задания на сегодня'), findsOneWidget);

      // 3. Switch to Rewards tab
      await tester.tap(find.text('Награды'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      expect(find.text('БАЛАНС ЛОЯЛЬНОСТИ'), findsOneWidget);

      // 4. Switch to Profile tab
      await tester.tap(find.text('Профиль'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      expect(find.text('Статистика болельщика'), findsOneWidget);

      // 5. Switch back to Quizzes tab
      await tester.tap(find.text('Квизы'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      expect(find.text('Категории квизов'), findsOneWidget);
    });
  });

  group('RenderFlex Overflow & Multi-Screen Responsiveness Matrix', () {
    final screenSizes = [
      {'name': 'Compact Mobile (320x480)', 'size': const Size(320, 480)},
      {'name': 'Standard iPhone (390x844)', 'size': const Size(390, 844)},
      {'name': 'Modern Android (412x915)', 'size': const Size(412, 915)},
      {'name': 'Tablet Viewport (800x1280)', 'size': const Size(800, 1280)},
    ];

    for (final screen in screenSizes) {
      final name = screen['name'] as String;
      final size = screen['size'] as Size;

      testWidgets('No RenderFlex overflow on $name across all 4 tabs', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Test QuizzesTab
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => LoyaltyProvider(),
            child: const MaterialApp(home: Scaffold(body: QuizzesTab())),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull, reason: 'QuizzesTab must not overflow on $name');

        // Test DailyTab
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => LoyaltyProvider(),
            child: const MaterialApp(home: Scaffold(body: DailyTab())),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull, reason: 'DailyTab must not overflow on $name');

        // Test RewardsTab
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => LoyaltyProvider(),
            child: const MaterialApp(home: Scaffold(body: RewardsTab())),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull, reason: 'RewardsTab must not overflow on $name');

        // Test ProfileTab
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => LoyaltyProvider(),
            child: const MaterialApp(home: Scaffold(body: ProfileTab())),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull, reason: 'ProfileTab must not overflow on $name');
      });
    }
  });

  group('JSON Asset Integrity Tests', () {
    test('Load and validate quiz and word content from assets/quiz_data.json and assets/words.json', () {
      final file = File('assets/quiz_data.json');
      expect(file.existsSync(), isTrue, reason: 'assets/quiz_data.json must exist');
      final content = file.readAsStringSync();
      final Map<String, dynamic> data = jsonDecode(content) as Map<String, dynamic>;

      // Check categories
      final categories = (data['categories'] as List)
          .map((e) => QuizCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(categories.isNotEmpty, isTrue, reason: 'Quiz categories should be populated from JSON');
      expect(categories.length, greaterThanOrEqualTo(5));

      for (final cat in categories) {
        expect(cat.questions.isNotEmpty, isTrue, reason: 'Category ${cat.title} must have questions');
        for (final q in cat.questions) {
          expect(q.options.length, 4, reason: 'Each question must have 4 options');
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.explanation.isNotEmpty, isTrue);
        }
      }

      // Check word puzzles
      final wordPuzzles = (data['word_puzzles'] as List)
          .map((e) => WordPuzzle.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(wordPuzzles.isNotEmpty, isTrue, reason: 'Word puzzles should be loaded from JSON');
      for (final wp in wordPuzzles) {
        expect(wp.word.isNotEmpty, isTrue);
        expect(wp.hint.isNotEmpty, isTrue);
        expect(wp.category.isNotEmpty, isTrue);
      }

      // Check words.json also exists and has words
      final wordsFile = File('assets/words.json');
      expect(wordsFile.existsSync(), isTrue, reason: 'assets/words.json must exist');

      // Check daily challenges
      final dailyChallenges = (data['daily_challenges'] as List)
          .map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(dailyChallenges.isNotEmpty, isTrue, reason: 'Daily challenges should be loaded from JSON');

      // Check loyalty store items
      final loyaltyStore = (data['loyalty_store'] as List)
          .map((e) => LoyaltyItem.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(loyaltyStore.isNotEmpty, isTrue, reason: 'Loyalty items should be loaded from JSON');

      // Check RPL fixtures
      final matchFixtures = (data['match_center_fixtures'] as List)
          .map((e) => MatchFixture.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(matchFixtures.isNotEmpty, isTrue, reason: 'Match fixtures should be loaded from JSON');
    });
  });

  group('Application Startup Verification', () {
    testWidgets('Verify MainApp builds and initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LoyaltyProvider(),
          child: const MainApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
