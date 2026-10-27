class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int points;
  final String difficulty;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.points,
    this.difficulty = 'Medium',
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      points: json['points'] as int? ?? 100,
      difficulty: json['difficulty'] as String? ?? 'Medium',
    );
  }
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String colorHex;
  final List<QuizQuestion> questions;

  QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.questions,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'sports_soccer',
      colorHex: json['color'] as String? ?? '#00F5D4',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WordPuzzle {
  final String id;
  final String word;
  final String hint;
  final String category;
  final int points;

  WordPuzzle({
    required this.id,
    required this.word,
    required this.hint,
    required this.category,
    required this.points,
  });

  factory WordPuzzle.fromJson(Map<String, dynamic> json) {
    return WordPuzzle(
      id: json['id'] as String? ?? '',
      word: (json['word'] as String? ?? '').toUpperCase(),
      hint: json['hint'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      points: json['points'] as int? ?? 100,
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int rewardPoints;
  final String icon;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.rewardPoints,
    required this.icon,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetCount: json['target_count'] as int? ?? 1,
      rewardPoints: json['reward_points'] as int? ?? 100,
      icon: json['icon'] as String? ?? 'sports_soccer',
    );
  }
}

class LoyaltyItem {
  final String id;
  final String title;
  final String category;
  final int cost;
  final String icon;
  final String description;

  LoyaltyItem({
    required this.id,
    required this.title,
    required this.category,
    required this.cost,
    required this.icon,
    required this.description,
  });

  factory LoyaltyItem.fromJson(Map<String, dynamic> json) {
    return LoyaltyItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      cost: json['cost'] as int? ?? 100,
      icon: json['icon'] as String? ?? 'star',
      description: json['description'] as String? ?? '',
    );
  }
}

class MatchFixture {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String stadium;
  final String timeLabel;
  final String status;
  final List<String> homeForm;
  final List<String> awayForm;
  final String triviaPrompt;
  final String triviaAnswer;

  MatchFixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.stadium,
    required this.timeLabel,
    required this.status,
    required this.homeForm,
    required this.awayForm,
    required this.triviaPrompt,
    required this.triviaAnswer,
  });

  factory MatchFixture.fromJson(Map<String, dynamic> json) {
    return MatchFixture(
      id: json['id'] as String? ?? '',
      homeTeam: json['home_team'] as String? ?? '',
      awayTeam: json['away_team'] as String? ?? '',
      stadium: json['stadium'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? 'UPCOMING',
      status: json['status'] as String? ?? 'UPCOMING',
      homeForm: (json['home_form'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      awayForm: (json['away_form'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      triviaPrompt: json['trivia_prompt'] as String? ?? '',
      triviaAnswer: json['trivia_answer'] as String? ?? '',
    );
  }
}

class FanRank {
  final String name;
  final int minPoints;
  final String badge;

  FanRank({
    required this.name,
    required this.minPoints,
    required this.badge,
  });

  factory FanRank.fromJson(Map<String, dynamic> json) {
    return FanRank(
      name: json['name'] as String? ?? '',
      minPoints: json['min_points'] as int? ?? 0,
      badge: json['badge'] as String? ?? 'badge_rookie',
    );
  }
}
