import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../providers/loyalty_provider.dart';
import '../theme/app_theme.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizPlayScreen({super.key, required this.category});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _correctCount = 0;
  int _earnedPoints = 0;

  @override
  Widget build(BuildContext context) {
    final questions = widget.category.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.title)),
        body: Center(
          child: Text(
            'В этой категории пока нет вопросов.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final currentQuestion = questions[_currentIndex];
    final total = questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.category.title),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Текущие очки в игре'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accentGold.withAlpha(70)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 14, color: AppTheme.accentGold),
                const SizedBox(width: 4),
                Text(
                  '+$_earnedPoints',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar & Question Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Вопрос ${_currentIndex + 1} из $total',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentQuestion.difficulty,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(currentQuestion.difficulty),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppTheme.surfaceCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 20),

              // Question Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline_rounded,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${currentQuestion.points} очков',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion.question,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Options List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentQuestion.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final optionText = currentQuestion.options[index];
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == currentQuestion.correctIndex;

                  Color bg = AppTheme.surfaceCard;
                  Color border = AppTheme.surfaceBorder;
                  Color textColor = AppTheme.textPrimary;
                  Widget? statusIcon;

                  if (_isAnswered) {
                    if (isCorrect) {
                      bg = AppTheme.secondary.withAlpha(35);
                      border = AppTheme.secondary;
                      textColor = AppTheme.secondary;
                      statusIcon = const Icon(Icons.check_circle_rounded,
                          color: AppTheme.secondary, size: 20);
                    } else if (isSelected) {
                      bg = AppTheme.accentRose.withAlpha(35);
                      border = AppTheme.accentRose;
                      textColor = AppTheme.accentRose;
                      statusIcon = const Icon(Icons.cancel_rounded,
                          color: AppTheme.accentRose, size: 20);
                    }
                  }

                  return InkWell(
                    onTap: _isAnswered ? null : () => _handleAnswer(index, currentQuestion),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border, width: isSelected ? 2 : 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surface,
                              border: Border.all(color: border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              optionText,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          ?statusIcon,
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Explanation Box if Answered
              if (_isAnswered) ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded,
                          size: 20, color: AppTheme.accentGold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Факт и пояснение',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentQuestion.explanation,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goToNext(questions),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentIndex + 1 < questions.length
                          ? 'Следующий вопрос'
                          : 'Посмотреть итоги',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(int index, QuizQuestion question) {
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index == question.correctIndex) {
        _correctCount += 1;
        _earnedPoints += question.points;
      }
    });
  }

  void _goToNext(List<QuizQuestion> questions) {
    if (_currentIndex + 1 < questions.length) {
      setState(() {
        _currentIndex += 1;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz(questions.length);
    }
  }

  void _finishQuiz(int totalCount) {
    final provider = context.read<LoyaltyProvider>();
    provider.recordQuizCompletion(
      totalQuestions: totalCount,
      correctCount: _correctCount,
      pointsEarned: _earnedPoints,
    );

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(25),
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: AppTheme.neonGlow,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.accentGold,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Квиз завершен!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Вы ответили верно на $_correctCount из $totalCount вопросов',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.accentGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+$_earnedPoints очков лояльности начислено',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(bottomSheetCtx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Вернуться в Матч-центр',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
      case 'легкий':
        return AppTheme.secondary;
      case 'hard':
      case 'сложный':
        return AppTheme.accentRose;
      default:
        return AppTheme.accentGold;
    }
  }
}
