import 'package:flutter/material.dart';
import '../models/match.dart';
import '../utils/colors.dart';

/// Dialog that explains the reasoning behind a match pairing and lane assignment
class MatchupReasoningDialog extends StatelessWidget {
  final Match match;

  const MatchupReasoningDialog({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final reasoning = match.reasoning;

    // If no reasoning is available, show a default message
    if (reasoning == null) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.courtHeader),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Kamp på ${match.court.name}'),
            ),
          ],
        ),
        content: const Text(
          'Begrundelse ikke tilgængelig for denne kamp.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Luk'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.sports_tennis, color: AppColors.courtHeader),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Kamp på ${match.court.name}'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round type header
            _buildSectionHeader(
              _getRoundTypeTitle(reasoning.roundType),
              Icons.emoji_events,
            ),
            const SizedBox(height: 8),
            
            // Player pairing explanation
            _buildInfoCard(
              title: 'Spillerparring',
              icon: Icons.people,
              content: reasoning.pairingMethod,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            
            // Lane assignment explanation
            _buildInfoCard(
              title: 'Bane tildeling',
              icon: Icons.place,
              content: reasoning.laneAssignment,
              color: Colors.green,
            ),
            
            // Player metadata (if available)
            if (reasoning.playerMetadata != null) ...[
              const SizedBox(height: 12),
              _buildPlayerMetadata(reasoning.playerMetadata!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Luk'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.courtHeader, size: 20),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.courtHeader,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerMetadata(Map<String, dynamic> metadata) {
    return Card(
      elevation: 2,
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.leaderboard, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Spiller detaljer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...metadata.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getRoundTypeTitle(String roundType) {
    switch (roundType) {
      case 'first':
        return '🎲 Første Runde';
      case 'regular':
        return '🔄 Normal Runde';
      case 'final':
        return '🏆 Sidste Runde';
      default:
        return 'Runde Information';
    }
  }
}
