import 'package:flutter/material.dart';

class ScoreButtonGrid extends StatelessWidget {
  final int? selectedScore;
  final Function(int) onScoreSelected;
  final Color color;

  const ScoreButtonGrid({
    super.key,
    required this.selectedScore,
    required this.onScoreSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(25, (index) {
        final isSelected = selectedScore == index;
        return SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
            onPressed: () => onScoreSelected(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? color : Colors.grey[300],
              foregroundColor: isSelected ? Colors.white : Colors.black87,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('$index', style: const TextStyle(fontSize: 16)),
          ),
        );
      }),
    );
  }
}
