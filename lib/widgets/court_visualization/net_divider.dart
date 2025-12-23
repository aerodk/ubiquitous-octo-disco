import 'package:flutter/material.dart';
import '../../utils/colors.dart';

/// A vertical divider that resembles a net with optional VS badge
/// F-022: Net Divider Component
class NetDivider extends StatelessWidget {
  const NetDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.netPrimary,
                  AppColors.netAccent,
                  AppColors.netPrimary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // VS label in middle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.netAccent,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.netPrimary,
                  AppColors.netAccent,
                  AppColors.netPrimary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
