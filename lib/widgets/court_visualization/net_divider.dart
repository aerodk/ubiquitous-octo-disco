import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

/// A vertical divider that resembles a net with optional VS badge
/// F-022: Net Divider Component
class NetDivider extends StatelessWidget {
  final bool isDesktopMode;
  final double zoomFactor;
  
  const NetDivider({
    super.key,
    this.isDesktopMode = false,
    this.zoomFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double baseFontScale = isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double baseSizeScale = isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double fontScale = baseFontScale * zoomFactor;
    final double sizeScale = baseSizeScale * zoomFactor;
    
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 4 * sizeScale,
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
              borderRadius: BorderRadius.circular(2 * sizeScale),
            ),
          ),
        ),
        // VS label in middle
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8 * sizeScale),
          child: Container(
            padding: EdgeInsets.all(6 * sizeScale),
            decoration: const BoxDecoration(
              color: AppColors.netAccent,
              shape: BoxShape.circle,
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 10 * fontScale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 4 * sizeScale,
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
              borderRadius: BorderRadius.circular(2 * sizeScale),
            ),
          ),
        ),
      ],
    );
  }
}
