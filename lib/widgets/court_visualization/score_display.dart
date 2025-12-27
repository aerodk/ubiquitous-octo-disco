import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

/// Displays a team's score with different styling for empty vs entered states
/// F-023: Score Display Component
class ScoreDisplay extends StatelessWidget {
  final int? score;
  final VoidCallback? onTap;
  final bool isDesktopMode;

  const ScoreDisplay({
    super.key,
    this.score,
    this.onTap,
    this.isDesktopMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null;
    final double fontScale = isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double sizeScale = isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;

    final Widget scoreWidget = Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * sizeScale, vertical: 12 * sizeScale),
      decoration: BoxDecoration(
        color: hasScore ? AppColors.scoreEntered : AppColors.scoreEmpty,
        borderRadius: BorderRadius.circular(12 * sizeScale),
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
              style: TextStyle(
                fontSize: 32 * fontScale,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            )
          : Text(
              '--',
              style: TextStyle(
                fontSize: 28 * fontScale,
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
