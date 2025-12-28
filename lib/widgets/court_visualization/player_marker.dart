import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

/// A visual marker for a player with person icon and name
/// F-021: Player Marker Component
class PlayerMarker extends StatelessWidget {
  final Player player;
  final VoidCallback? onLongPress;
  final bool isDesktopMode;
  final double zoomFactor;

  const PlayerMarker({
    super.key,
    required this.player,
    this.onLongPress,
    this.isDesktopMode = false,
    this.zoomFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double baseFontScale = isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double baseSizeScale = isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double fontScale = baseFontScale * zoomFactor;
    final double sizeScale = baseSizeScale * zoomFactor;
    
    final Widget marker = Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeScale, vertical: 4 * sizeScale),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20 * sizeScale),
        border: Border.all(color: AppColors.playerBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Person icon
          Icon(
            Icons.person,
            size: 20 * sizeScale,
            color: AppColors.playerIcon,
          ),
          SizedBox(width: 8 * sizeScale),
          // Player name
          Flexible(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 16 * fontScale,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onLongPress != null) {
      return GestureDetector(
        onLongPress: onLongPress,
        child: marker,
      );
    }

    return marker;
  }
}
