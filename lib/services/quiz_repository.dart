import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_models.dart';

class QuizRepository {
  List<QuizCategory> categories = [];
  List<WordPuzzle> wordPuzzles = [];
  List<DailyChallenge> dailyChallenges = [];
  List<LoyaltyItem> loyaltyStore = [];
  List<MatchFixture> matchFixtures = [];
  List<FanRank> fanRanks = [];
  bool isLoaded = false;

  Future<void> loadQuizData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/quiz_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data['categories'] != null) {
        categories = (data['categories'] as List)
            .map((e) => QuizCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['word_puzzles'] != null) {
        wordPuzzles = (data['word_puzzles'] as List)
            .map((e) => WordPuzzle.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['daily_challenges'] != null) {
        dailyChallenges = (data['daily_challenges'] as List)
            .map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['loyalty_store'] != null) {
        loyaltyStore = (data['loyalty_store'] as List)
            .map((e) => LoyaltyItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['match_center_fixtures'] != null) {
        matchFixtures = (data['match_center_fixtures'] as List)
            .map((e) => MatchFixture.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data['fan_ranks'] != null) {
        fanRanks = (data['fan_ranks'] as List)
            .map((e) => FanRank.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      isLoaded = true;
    } catch (e) {
      // Fallback in case of bundle load issue in testing
      isLoaded = false;
    }
  }
}
