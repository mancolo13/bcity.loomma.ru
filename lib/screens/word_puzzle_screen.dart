import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../providers/loyalty_provider.dart';
import '../theme/app_theme.dart';

class WordPuzzleScreen extends StatefulWidget {
  const WordPuzzleScreen({super.key});

  @override
  State<WordPuzzleScreen> createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> {
  int _puzzleIndex = 0;
  List<String> _currentLetters = [];
  List<int?> _selectedLetterIndices = [];
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPuzzle();
    });
  }

  void _loadPuzzle() {
    final provider = context.read<LoyaltyProvider>();
    final puzzles = provider.repository.wordPuzzles;
    if (puzzles.isNotEmpty) {
      final puzzle = puzzles[_puzzleIndex % puzzles.length];
      final letters = puzzle.word.split('')..shuffle();
      setState(() {
        _currentLetters = letters;
        _selectedLetterIndices = [];
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoyaltyProvider>();
    final puzzles = provider.repository.wordPuzzles;

    if (puzzles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Футбольный филворд')),
        body: Center(
          child: Text(
            'Головоломки не найдены.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final currentPuzzle = puzzles[_puzzleIndex % puzzles.length];
    final targetWord = currentPuzzle.word;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Футбольный филворд'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accentGold.withAlpha(70)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_outlined,
                    size: 14, color: AppTheme.accentGold),
                const SizedBox(width: 4),
                Text(
                  '${provider.points} очков',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category & Reward Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary.withAlpha(60)),
                    ),
                    child: Text(
                      'Категория: ${currentPuzzle.category}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Загадка ${_puzzleIndex + 1} из ${puzzles.length}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hint Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppTheme.accentGold, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'ПОДСКАЗКА',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentGold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentPuzzle.hint,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Награда: +${currentPuzzle.points} очков',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Answer Letter Slots
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(targetWord.length, (slotIdx) {
                  final hasLetter = slotIdx < _selectedLetterIndices.length;
                  final letter = hasLetter
                      ? _currentLetters[_selectedLetterIndices[slotIdx]!]
                      : '';

                  return Container(
                    width: 42,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? AppTheme.secondary.withAlpha(30)
                          : (hasLetter ? AppTheme.surfaceCard : AppTheme.surface),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isSuccess
                            ? AppTheme.secondary
                            : (hasLetter ? AppTheme.primary : AppTheme.surfaceBorder),
                        width: hasLetter ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isSuccess ? AppTheme.secondary : AppTheme.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Control Actions (Clear & Backspace)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectedLetterIndices.isNotEmpty && !_isSuccess
                        ? () {
                            setState(() {
                              _selectedLetterIndices.removeLast();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.backspace_outlined, size: 16),
                    label: const Text('Стереть'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _selectedLetterIndices.isNotEmpty && !_isSuccess
                        ? () {
                            setState(() {
                              _selectedLetterIndices.clear();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Сбросить'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scrambled Letter Tiles Buttons
              Text(
                'Нажимайте на буквы, чтобы собрать слово:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_currentLetters.length, (tileIdx) {
                  final isUsed = _selectedLetterIndices.contains(tileIdx);

                  return InkWell(
                    onTap: isUsed || _isSuccess
                        ? null
                        : () => _pickLetter(tileIdx, targetWord, currentPuzzle),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isUsed
                            ? AppTheme.surface.withAlpha(80)
                            : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUsed
                              ? AppTheme.surfaceBorder.withAlpha(50)
                              : AppTheme.primary.withAlpha(70),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentLetters[tileIdx],
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isUsed
                              ? AppTheme.textMuted.withAlpha(80)
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Success Banner & Next Button
              if (_isSuccess) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.secondary),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.secondary, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'Отлично! Слово разгадано!',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${currentPuzzle.points} очков лояльности начислено!',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _puzzleIndex += 1;
                              _loadPuzzle();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Следующее слово',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _pickLetter(int tileIdx, String targetWord, WordPuzzle currentPuzzle) {
    if (_selectedLetterIndices.length >= targetWord.length) return;

    setState(() {
      _selectedLetterIndices.add(tileIdx);
    });

    if (_selectedLetterIndices.length == targetWord.length) {
      final formed = _selectedLetterIndices
          .map((i) => _currentLetters[i!])
          .join('');

      if (formed == targetWord) {
        setState(() {
          _isSuccess = true;
        });
        context.read<LoyaltyProvider>().recordWordPuzzleSolved(currentPuzzle.points);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не совсем верно, попробуйте другую комбинацию!'),
            backgroundColor: AppTheme.accentRose,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
