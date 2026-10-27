import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../theme/app_theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final List<String> _clubs = [
    'Спартак Москва',
    'Зенит Санкт-Петербург',
    'ЦСКА Москва',
    'ФК Краснодар',
    'Динамо Москва',
    'Локомотив Москва',
    'ФК Ростов',
    'Рубин Казань',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoyaltyProvider>();
    final rank = provider.getFanRank();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Banner Card
          _buildProfileHeader(context, provider, rank),
          const SizedBox(height: 20),

          // Favorite Club Selector
          _buildFavoriteClubSelector(context, provider),
          const SizedBox(height: 20),

          // Statistics Grid
          Text(
            'Статистика болельщика',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(context, provider),
          const SizedBox(height: 24),

          // Leaderboard
          Text(
            'Рейтинг болельщиков РПЛ',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildLeaderboard(context, provider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, LoyaltyProvider provider, dynamic rank) {
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
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(30),
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: AppTheme.neonGlow,
                ),
                child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Болельщик РПЛ #729',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: AppTheme.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rank.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.selectedClub,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rank progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'До следующего уровня',
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
                    '${provider.points} / 5000 очков',
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
                  value: (provider.points / 5000).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteClubSelector(BuildContext context, LoyaltyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Любимый клуб РПЛ',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _clubs.map((club) {
              final isSelected = provider.selectedClub == club;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    club,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : AppTheme.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) provider.setSelectedClub(club);
                  },
                  backgroundColor: AppTheme.surfaceCard,
                  selectedColor: AppTheme.primary,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.surfaceBorder,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, LoyaltyProvider provider) {
    final stats = [
      {
        'title': 'Точность',
        'value': '${provider.accuracyRate.toStringAsFixed(1)}%',
        'icon': Icons.track_changes_rounded,
        'color': AppTheme.secondary,
      },
      {
        'title': 'Квизов сыграно',
        'value': '${provider.totalQuizzesPlayed}',
        'icon': Icons.sports_soccer_rounded,
        'color': AppTheme.primary,
      },
      {
        'title': 'Верных ответов',
        'value': '${provider.totalCorrectAnswers}',
        'icon': Icons.check_circle_outline_rounded,
        'color': AppTheme.accentGold,
      },
      {
        'title': 'Слов отгадано',
        'value': '${provider.wordPuzzlesSolved}',
        'icon': Icons.spellcheck_rounded,
        'color': AppTheme.accentPurple,
      },
      {
        'title': 'Серия',
        'value': '${provider.streakDays} дн.',
        'icon': Icons.local_fire_department_rounded,
        'color': AppTheme.accentOrange,
      },
      {
        'title': 'Наград открыто',
        'value': '${provider.ownedItemIds.length}',
        'icon': Icons.shield_rounded,
        'color': AppTheme.primaryDark,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = stat['color'] as Color;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.surfaceBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat['icon'] as IconData, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                stat['value'] as String,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                stat['title'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboard(BuildContext context, LoyaltyProvider provider) {
    final leaderUsers = [
      {'rank': 1, 'name': 'Alexey_Zenit7', 'points': 4850, 'club': 'Зенит Санкт-Петербург'},
      {'rank': 2, 'name': 'Spartak_Ultras_92', 'points': 3920, 'club': 'Спартак Москва'},
      {'rank': 3, 'name': 'Вы (Преданный фанат)', 'points': provider.points, 'club': provider.selectedClub},
      {'rank': 4, 'name': 'ArmyBoy_CSKA', 'points': 2100, 'club': 'ЦСКА Москва'},
      {'rank': 5, 'name': 'SouthBull_KRD', 'points': 1850, 'club': 'ФК Краснодар'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaderUsers.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: AppTheme.surfaceBorder,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final user = leaderUsers[index];
          final isUser = index == 2;
          final rankNum = user['rank'] as int;

          Color rankColor = AppTheme.textMuted;
          if (rankNum == 1) rankColor = AppTheme.accentGold;
          if (rankNum == 2) rankColor = const Color(0xFFC0C0C0);
          if (rankNum == 3 && !isUser) rankColor = const Color(0xFFCD7F32);
          if (isUser) rankColor = AppTheme.primary;

          return Container(
            color: isUser ? AppTheme.primary.withAlpha(20) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '#$rankNum',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isUser
                      ? AppTheme.primary.withAlpha(40)
                      : AppTheme.surface,
                  child: Icon(
                    Icons.sports_soccer,
                    size: 16,
                    color: isUser ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: isUser ? FontWeight.bold : FontWeight.w600,
                          color: isUser ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user['club'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${user['points']} очков',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
