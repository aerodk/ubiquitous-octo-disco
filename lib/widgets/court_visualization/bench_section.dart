import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../utils/colors.dart';
import 'bench_player_chip.dart';

/// Visual section showing players on the bench (on pause) this round
/// F-024: Bench (Pause) Section Redesign
class BenchSection extends StatelessWidget {
  final List<Player> playersOnBreak;
  final Function(Player)? onPlayerTap;

  const BenchSection({
    super.key,
    required this.playersOnBreak,
    this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (playersOnBreak.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.benchBorder, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.benchBackgroundLight,
              AppColors.benchBackgroundDark,
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(
                  Icons.pause_circle,
                  color: AppColors.benchHeaderIcon,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'PÅ BÆNKEN DENNE RUNDE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.benchHeaderText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Players on bench
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: playersOnBreak
                  .map((player) => BenchPlayerChip(
                        player: player,
                        onTap: onPlayerTap != null
                            ? () => onPlayerTap!(player)
                            : null,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
