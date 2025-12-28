import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

/// Displays a team's score with different styling for empty vs entered states
/// F-023: Score Display Component
class ScoreDisplay extends StatelessWidget {
  final int? score;
  final VoidCallback? onTap;
  final bool isDesktopMode;
  final double zoomFactor;

  const ScoreDisplay({
    super.key,
    this.score,
    this.onTap,
    this.isDesktopMode = false,
    this.zoomFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null;
    final double baseFontScale = isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double baseSizeScale = isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double fontScale = baseFontScale * zoomFactor;
    final double sizeScale = baseSizeScale * zoomFactor;

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
