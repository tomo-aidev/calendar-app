import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../models/fortune.dart';
import '../../../models/user_profile.dart';

class FortuneCard extends StatelessWidget {
  final Fortune fortune;
  final ZodiacSign? zodiacSign;

  const FortuneCard({
    super.key,
    required this.fortune,
    this.zodiacSign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\u{1F52E}',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                const Text(
                  'あなたの運勢',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (zodiacSign != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${zodiacSign!.emoji} ${zodiacSign!.displayName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Luck ratings with individual icons
            _LuckRow(
              label: '総合運',
              stars: fortune.overallLuck,
              color: AppColors.fortuneOverall,
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
            ),
            _LuckRow(
              label: '恋愛運',
              stars: fortune.loveLuck,
              color: AppColors.fortuneLove,
              filledIcon: Icons.favorite,
              emptyIcon: Icons.favorite_border,
            ),
            _LuckRow(
              label: '仕事運',
              stars: fortune.workLuck,
              color: AppColors.fortuneWork,
              filledIcon: Icons.workspace_premium,
              emptyIcon: Icons.workspace_premium_outlined,
            ),
            _LuckRow(
              label: '金運　',
              stars: fortune.moneyLuck,
              color: AppColors.fortuneMoney,
              filledIcon: Icons.monetization_on,
              emptyIcon: Icons.monetization_on_outlined,
            ),
            _LuckRow(
              label: '健康運',
              stars: fortune.healthLuck,
              color: AppColors.fortuneHealth,
              filledIcon: Icons.spa,
              emptyIcon: Icons.spa_outlined,
            ),
            const SizedBox(height: 16),
            // Advice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日のアドバイス:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fortune.adviceMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Lucky items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LuckyColorItem(colorName: fortune.luckyColor),
                _LuckyItem(
                  label: 'ラッキーナンバー',
                  value: '${fortune.luckyNumber}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LuckRow extends StatelessWidget {
  final String label;
  final int stars;
  final Color color;
  final IconData filledIcon;
  final IconData emptyIcon;
  const _LuckRow({
    required this.label,
    required this.stars,
    required this.color,
    this.filledIcon = Icons.circle,
    this.emptyIcon = Icons.circle_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(5, (i) {
              if (i < stars) {
                return Icon(filledIcon, color: color, size: 22);
              } else {
                return Icon(
                  emptyIcon,
                  color: color.withValues(alpha: 0.3),
                  size: 22,
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}

class _LuckyColorItem extends StatelessWidget {
  final String colorName;

  const _LuckyColorItem({required this.colorName});

  @override
  Widget build(BuildContext context) {
    final actualColor =
        AppColors.luckyColorMap[colorName] ?? AppColors.gold;

    return Column(
      children: [
        Text(
          'ラッキーカラー',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: actualColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: actualColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: actualColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                colorName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: actualColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LuckyItem extends StatelessWidget {
  final String label;
  final String value;

  const _LuckyItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}
