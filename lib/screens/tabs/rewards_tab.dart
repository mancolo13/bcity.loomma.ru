import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models.dart';
import '../../providers/loyalty_provider.dart';
import '../../theme/app_theme.dart';

class RewardsTab extends StatefulWidget {
  const RewardsTab({super.key});

  @override
  State<RewardsTab> createState() => _RewardsTabState();
}

class _RewardsTabState extends State<RewardsTab> {
  String _selectedCategory = 'Все';

  final List<String> _filterCategories = [
    'Все',
    'Значки',
    'Бустеры',
    'Темы',
    'Аватары',
    'VIP-статус',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoyaltyProvider>();
    final allItems = provider.repository.loyaltyStore;

    final filteredItems = _selectedCategory == 'Все'
        ? allItems
        : allItems.where((item) => item.category == _selectedCategory).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance & Loyalty Status Card
          _buildBalanceCard(context, provider),
          const SizedBox(height: 18),

          // Category Chips Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _filterCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.black : AppTheme.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppTheme.surfaceCard,
                    selectedColor: AppTheme.primary,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 18),

          // Store Items List
          if (filteredItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'В этой категории пока нет наград',
                style: GoogleFonts.inter(color: AppTheme.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildStoreItemCard(context, provider, item);
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, LoyaltyProvider provider) {
    final rank = provider.getFanRank();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2B48), Color(0xFF162032)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withAlpha(70)),
        boxShadow: AppTheme.neonGlow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'БАЛАНС ЛОЯЛЬНОСТИ',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppTheme.accentGold, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '${provider.points}',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'очков',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withAlpha(200),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.military_tech_rounded,
                        color: AppTheme.primary, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      rank.name,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.background.withAlpha(140),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Зарабатывайте очки в квизах и ежедневных заданиях',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItemCard(
      BuildContext context, LoyaltyProvider provider, LoyaltyItem item) {
    final isOwned = provider.isItemOwned(item.id);
    final canAfford = provider.canAfford(item.cost);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned ? AppTheme.secondary.withAlpha(80) : AppTheme.surfaceBorder,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOwned
                      ? AppTheme.secondary.withAlpha(25)
                      : AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOwned
                        ? AppTheme.secondary.withAlpha(80)
                        : AppTheme.primary.withAlpha(60),
                  ),
                ),
                child: Icon(
                  _getStoreIcon(item.icon),
                  color: isOwned ? AppTheme.secondary : AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 13, color: AppTheme.accentGold),
                            const SizedBox(width: 3),
                            Text(
                              '${item.cost} очков',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isOwned
                  ? null
                  : () => _confirmPurchase(context, provider, item, canAfford),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwned
                    ? AppTheme.surface
                    : (canAfford ? AppTheme.primary : AppTheme.surface),
                foregroundColor: isOwned
                    ? AppTheme.secondary
                    : (canAfford ? Colors.black : AppTheme.textMuted),
                disabledBackgroundColor: AppTheme.surface,
                disabledForegroundColor: AppTheme.secondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isOwned
                        ? AppTheme.secondary.withAlpha(60)
                        : (canAfford ? AppTheme.primary : AppTheme.surfaceBorder),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isOwned) ...[
                    const Icon(Icons.check, size: 15, color: AppTheme.secondary),
                    const SizedBox(width: 6),
                    Text('Разблокировано',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                  ] else ...[
                    Icon(
                      canAfford ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      canAfford ? 'Получить за ${item.cost} очков' : 'Не хватает ${item.cost - provider.points} очков',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPurchase(
      BuildContext context, LoyaltyProvider provider, LoyaltyItem item, bool canAfford) {
    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Недостаточно очков! Нужно еще ${item.cost - provider.points}.'),
          backgroundColor: AppTheme.accentRose,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceBorder),
        ),
        title: Text(
          'Получение награды',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Желаете приобрести «${item.title}» за ${item.cost} очков?',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Остаток на балансе:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  Text('${provider.points - item.cost} очков',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Отмена', style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final success = provider.buyItem(item);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Награда «${item.title}» успешно получена!'),
                    backgroundColor: AppTheme.secondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Подтвердить', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getStoreIcon(String icon) {
    switch (icon) {
      case 'shield':
        return Icons.shield_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'stars':
        return Icons.stars_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }
}
