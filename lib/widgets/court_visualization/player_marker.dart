import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../utils/colors.dart';

/// A visual marker for a player with person icon and name
/// F-021: Player Marker Component
class PlayerMarker extends StatelessWidget {
  final Player player;

  const PlayerMarker({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
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
            size: 20,
            color: AppColors.playerIcon,
          ),
          const SizedBox(width: 8),
          // Player name
          Flexible(
            child: Text(
              player.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
