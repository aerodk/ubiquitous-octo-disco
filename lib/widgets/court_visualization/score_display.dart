import 'package:flutter/material.dart';
import '../../utils/colors.dart';

/// Displays a team's score with different styling for empty vs entered states
/// F-023: Score Display Component
class ScoreDisplay extends StatelessWidget {
  final int? score;
  final VoidCallback? onTap;

  const ScoreDisplay({
    super.key,
    this.score,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null;

    final Widget scoreWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: hasScore ? AppColors.scoreEntered : AppColors.scoreEmpty,
        borderRadius: BorderRadius.circular(12),
        boxShadow: hasScore
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: hasScore
          ? Text(
              '$score',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            )
          : const Text(
              '--',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: AppColors.scoreEmptyText,
              ),
            ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: scoreWidget,
      );
    }

    return scoreWidget;
  }
}
