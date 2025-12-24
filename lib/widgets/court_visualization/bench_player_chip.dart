import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../utils/colors.dart';

/// A chip representing a player sitting on the bench (on pause)
/// F-024: Bench Player Chip Component
class BenchPlayerChip extends StatelessWidget {
  final Player player;
  final int? rankChange;
  final VoidCallback? onTap;

  const BenchPlayerChip({
    super.key,
    required this.player,
    this.rankChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.benchChipBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bench emoji
            const Text('🪑', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            // Person icon
            Icon(
              Icons.person,
              size: 18,
              color: AppColors.benchChipIcon,
            ),
            const SizedBox(width: 6),
            // Player name
            Text(
              player.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            // Position change indicator (shown from round 3 onwards)
            if (rankChange != null) ...[
              const SizedBox(width: 8),
              _buildPositionChangeIndicator(rankChange!),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Build position change indicator widget
  /// Shows green +N for improvement, red -N for decline, black ±0 for no change
  Widget _buildPositionChangeIndicator(int change) {
    final Color indicatorColor;
    final String prefix;
    
    if (change > 0) {
      // Positive change = rank improvement (moved up)
      indicatorColor = Colors.green;
      prefix = '+';
    } else if (change < 0) {
      // Negative change = rank decline (moved down)
      indicatorColor = Colors.red;
      prefix = '';
    } else {
      // No change
      indicatorColor = Colors.black87;
      prefix = '±';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: indicatorColor,
          width: 1,
        ),
      ),
      child: Text(
        '$prefix$change',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: indicatorColor,
        ),
      ),
    );
  }
}
