import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../providers/loyalty_provider.dart';
import '../../theme/app_theme.dart';

class DailyTab extends StatefulWidget {
  const DailyTab({super.key});

  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  int? _selectedDailyAnswer;
  bool _answeredDailyQuestion = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoyaltyProvider>();
    final challenges = provider.repository.dailyChallenges;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Counter Card
          _buildStreakCard(context, provider),
          const SizedBox(height: 20),

          // Question of the Day
          _buildDailyTriviaCard(context, provider),
          const SizedBox(height: 24),

          // Daily Missions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Задания на сегодня',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Сброс через 08:42:15',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Challenges List
          if (challenges.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challenges.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return _buildChallengeCard(context, provider, challenge);
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, LoyaltyProvider provider) {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final currentStreak = provider.streakDays;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppTheme.accentOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Серия $currentStreak дн. подряд!',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Заходите каждый день и получайте +50% очков',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withAlpha(70)),
                ),
                child: Text(
                  'АКТИВНО',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 7 Days Visual Row
          Row(
            children: List.generate(7, (i) {
              final isDone = i < currentStreak;
              final isToday = i == currentStreak - 1;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == 6 ? 0 : 5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppTheme.primary.withAlpha(30)
                        : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday
                          ? AppTheme.primary
                          : (isDone
                              ? AppTheme.primary.withAlpha(80)
                              : AppTheme.surfaceBorder),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        days[i],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDone ? AppTheme.primary : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        isDone ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                        size: 14,
                        color: isDone ? AppTheme.primary : AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTriviaCard(BuildContext context, LoyaltyProvider provider) {
    const dailyQuestion =
        'Какой клуб в чемпионате России традиционно называют «железнодорожниками»?';
    final options = ['Спартак', 'Локомотив', 'Торпедо', 'Зенит'];
    const correctIndex = 1;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, color: AppTheme.accentGold, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ВОПРОС ДНЯ',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+100 очков',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dailyQuestion,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(options.length, (idx) {
              final isSelected = _selectedDailyAnswer == idx;
              final isCorrect = idx == correctIndex;

              Color bg = AppTheme.surface;
              Color border = AppTheme.surfaceBorder;

              if (_answeredDailyQuestion) {
                if (isCorrect) {
                  bg = AppTheme.secondary.withAlpha(40);
                  border = AppTheme.secondary;
                } else if (isSelected) {
                  bg = AppTheme.accentRose.withAlpha(40);
                  border = AppTheme.accentRose;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: _answeredDailyQuestion
                      ? null
                      : () {
                          setState(() {
                            _selectedDailyAnswer = idx;
                            _answeredDailyQuestion = true;
                          });
                          if (idx == correctIndex) {
                            provider.addPoints(100);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Верно! +100 очков начислено!'),
                                backgroundColor: AppTheme.secondary,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          options[idx],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (_answeredDailyQuestion && isCorrect)
                          const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 18)
                        else if (_answeredDailyQuestion && isSelected)
                          const Icon(Icons.cancel_rounded, color: AppTheme.accentRose, size: 18)
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
      BuildContext context, LoyaltyProvider provider, DailyChallenge challenge) {
    final progress = provider.getChallengeProgress(challenge.id);
    final isClaimed = provider.isChallengeClaimed(challenge.id);
    final isCompleted = progress >= challenge.targetCount;
    final clampedProgress = progress.clamp(0, challenge.targetCount);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted && !isClaimed
              ? AppTheme.primary.withAlpha(90)
              : AppTheme.surfaceBorder,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getIcon(challenge.icon), color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: AppTheme.accentGold),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.rewardPoints}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar and Claim Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Прогресс',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$clampedProgress / ${challenge.targetCount}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: challenge.targetCount > 0
                      ? clampedProgress / challenge.targetCount
                      : 0,
                  minHeight: 6,
                  backgroundColor: AppTheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppTheme.secondary : AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isCompleted && !isClaimed)
                      ? () {
                          provider.claimChallenge(challenge.id, challenge.rewardPoints);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Получено ${challenge.rewardPoints} очков за «${challenge.title}»!'),
                              backgroundColor: AppTheme.secondary,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClaimed
                        ? AppTheme.surface
                        : (isCompleted ? AppTheme.secondary : AppTheme.surface),
                    foregroundColor: isClaimed
                        ? AppTheme.textMuted
                        : (isCompleted ? Colors.black : AppTheme.textMuted),
                    disabledBackgroundColor: AppTheme.surface,
                    disabledForegroundColor: AppTheme.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isCompleted && !isClaimed
                            ? AppTheme.secondary
                            : AppTheme.surfaceBorder,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isClaimed) ...[
                        const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text('Награда получена',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                      ] else if (isCompleted) ...[
                        const Icon(Icons.card_giftcard, size: 14, color: Colors.black),
                        const SizedBox(width: 6),
                        Text('Забрать +${challenge.rewardPoints} очков',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                      ] else ...[
                        const Icon(Icons.hourglass_empty_rounded, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text('В процессе ($clampedProgress/${challenge.targetCount})',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'spellcheck':
        return Icons.spellcheck_rounded;
      case 'verified_user':
        return Icons.verified_user_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
