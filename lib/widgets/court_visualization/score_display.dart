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
  final bool isCompactMode;

  const ScoreDisplay({
    super.key,
    this.score,
    this.onTap,
    this.isDesktopMode = false,
    this.zoomFactor = 1.0,
    this.isCompactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null;
    final double baseFontScale =
        isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double baseSizeScale =
        isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double compactFontScale = isCompactMode ? 0.82 : 1.0;
    final double compactSizeScale = isCompactMode ? 0.74 : 1.0;
    final double fontScale = baseFontScale * zoomFactor * compactFontScale;
    final double sizeScale = baseSizeScale * zoomFactor * compactSizeScale;

    final Widget scoreWidget = Container(
      padding: EdgeInsets.symmetric(
          horizontal: (isCompactMode ? 12 : 20) * sizeScale,
          vertical: (isCompactMode ? 8 : 12) * sizeScale),
      constraints: BoxConstraints(
        minWidth: (isCompactMode ? 44 : 56) * sizeScale,
      ),
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: hasScore
            ? Text(
                '$score',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: (isCompactMode ? 26 : 32) * fontScale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              )
            : Text(
                '--',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: (isCompactMode ? 22 : 28) * fontScale,
                  fontWeight: FontWeight.w300,
                  color: AppColors.scoreEmptyText,
                ),
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
