import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import '../services/quiz_repository.dart';

class LoyaltyProvider extends ChangeNotifier {
  final QuizRepository repository = QuizRepository();

  int _points = 650;
  int _streakDays = 5;
  int _totalQuizzesPlayed = 8;
  int _totalCorrectAnswers = 34;
  int _totalQuestionsAnswered = 40;
  int _wordPuzzlesSolved = 3;
  String _selectedClub = 'Спартак Москва';
  final Set<String> _ownedItemIds = {'item_badge_bronze'};
  final Set<String> _claimedChallengeIds = {'daily_quiz_ace'};
  final Map<String, int> _challengeProgress = {'daily_quiz_ace': 5, 'daily_word_solver': 1};
  bool _isLoading = true;

  int get points => _points;
  int get streakDays => _streakDays;
  int get totalQuizzesPlayed => _totalQuizzesPlayed;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalQuestionsAnswered => _totalQuestionsAnswered;
  int get wordPuzzlesSolved => _wordPuzzlesSolved;
  String get selectedClub => _selectedClub;
  Set<String> get ownedItemIds => _ownedItemIds;
  Set<String> get claimedChallengeIds => _claimedChallengeIds;
  Map<String, int> get challengeProgress => _challengeProgress;
  bool get isLoading => _isLoading;

  double get accuracyRate {
    if (_totalQuestionsAnswered == 0) return 0.0;
    return (_totalCorrectAnswers / _totalQuestionsAnswered) * 100;
  }

  LoyaltyProvider() {
    _init();
  }

  Future<void> _init() async {
    await repository.loadQuizData();
    await _loadFromPrefs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _points = prefs.getInt('loyalty_points') ?? 650;
      _streakDays = prefs.getInt('loyalty_streak') ?? 5;
      _totalQuizzesPlayed = prefs.getInt('loyalty_quizzes') ?? 8;
      _totalCorrectAnswers = prefs.getInt('loyalty_correct') ?? 34;
      _totalQuestionsAnswered = prefs.getInt('loyalty_answered') ?? 40;
      _wordPuzzlesSolved = prefs.getInt('loyalty_words') ?? 3;
      _selectedClub = prefs.getString('loyalty_club') ?? 'Спартак Москва';

      final owned = prefs.getStringList('loyalty_owned_items');
      if (owned != null) {
        _ownedItemIds.addAll(owned);
      }

      final claimed = prefs.getStringList('loyalty_claimed_challenges');
      if (claimed != null) {
        _claimedChallengeIds.addAll(claimed);
      }
    } catch (_) {
      // Keep defaults
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('loyalty_points', _points);
      await prefs.setInt('loyalty_streak', _streakDays);
      await prefs.setInt('loyalty_quizzes', _totalQuizzesPlayed);
      await prefs.setInt('loyalty_correct', _totalCorrectAnswers);
      await prefs.setInt('loyalty_answered', _totalQuestionsAnswered);
      await prefs.setInt('loyalty_words', _wordPuzzlesSolved);
      await prefs.setString('loyalty_club', _selectedClub);
      await prefs.setStringList('loyalty_owned_items', _ownedItemIds.toList());
      await prefs.setStringList('loyalty_claimed_challenges', _claimedChallengeIds.toList());
    } catch (_) {}
  }

  void addPoints(int amount) {
    _points += amount;
    _saveToPrefs();
    notifyListeners();
  }

  bool canAfford(int cost) => _points >= cost;

  bool buyItem(LoyaltyItem item) {
    if (_ownedItemIds.contains(item.id)) return true;
    if (_points >= item.cost) {
      _points -= item.cost;
      _ownedItemIds.add(item.id);
      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool isItemOwned(String itemId) => _ownedItemIds.contains(itemId);

  void recordQuizCompletion({
    required int totalQuestions,
    required int correctCount,
    required int pointsEarned,
  }) {
    _totalQuizzesPlayed += 1;
    _totalQuestionsAnswered += totalQuestions;
    _totalCorrectAnswers += correctCount;
    _points += pointsEarned;

    // Advance daily challenge progress
    final currentQProgress = (_challengeProgress['daily_quiz_ace'] ?? 0) + correctCount;
    _challengeProgress['daily_quiz_ace'] = currentQProgress;

    if (totalQuestions > 0 && correctCount == totalQuestions) {
      _challengeProgress['daily_perfect_run'] = 1;
    }

    _saveToPrefs();
    notifyListeners();
  }

  void recordWordPuzzleSolved(int pointsEarned) {
    _wordPuzzlesSolved += 1;
    _points += pointsEarned;

    final currentW = (_challengeProgress['daily_word_solver'] ?? 0) + 1;
    _challengeProgress['daily_word_solver'] = currentW;

    _saveToPrefs();
    notifyListeners();
  }

  bool claimChallenge(String challengeId, int reward) {
    if (_claimedChallengeIds.contains(challengeId)) return false;
    _claimedChallengeIds.add(challengeId);
    _points += reward;
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  bool isChallengeClaimed(String id) => _claimedChallengeIds.contains(id);

  int getChallengeProgress(String id) => _challengeProgress[id] ?? 0;

  void setSelectedClub(String club) {
    _selectedClub = club;
    _saveToPrefs();
    notifyListeners();
  }

  FanRank getFanRank() {
    if (repository.fanRanks.isEmpty) {
      return FanRank(name: 'Преданный фанат', minPoints: 500, badge: 'badge_fan');
    }
    for (int i = repository.fanRanks.length - 1; i >= 0; i--) {
      if (_points >= repository.fanRanks[i].minPoints) {
        return repository.fanRanks[i];
      }
    }
    return repository.fanRanks.first;
  }
}
