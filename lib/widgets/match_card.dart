import 'package:flutter/material.dart';
import '../models/match.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_tennis, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        match.court.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (match.isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (onTap != null)
                    const Icon(Icons.edit, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              _buildTeam('Par 1', match.team1, match.team1Score),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'VS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              _buildTeam('Par 2', match.team2, match.team2Score),
              if (!match.isCompleted && onTap != null) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Tryk for at indtaste score',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(String label, Team team, int? score) {
    final isTeam1 = label == 'Par 1';
    final teamColor = isTeam1 ? Colors.blue : Colors.red;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: teamColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${team.player1.name} & ${team.player2.name}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
