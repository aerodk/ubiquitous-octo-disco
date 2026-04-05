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
  final bool isCompactMode;

  const PlayerMarker({
    super.key,
    required this.player,
    this.onLongPress,
    this.isDesktopMode = false,
    this.zoomFactor = 1.0,
    this.isCompactMode = false,
  });

  String _compactDisplayName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      if (parts.first.length <= 10) {
        return parts.first;
      }
      return '${parts.first.substring(0, 9)}.';
    }

    final firstInitial = parts.first.substring(0, 1).toUpperCase();

    final surnameParts = parts.sublist(1);
    const surnameParticles = {
      'de',
      'del',
      'della',
      'di',
      'du',
      'van',
      'von',
      'der',
      'den',
      'af',
      'la',
      'le'
    };

    final coreSurname = surnameParts.last;

    final prefixParticles = <String>[];
    int index = surnameParts.length - 2;
    while (index >= 0 &&
        surnameParticles.contains(surnameParts[index].toLowerCase())) {
      prefixParticles.insert(0, surnameParts[index]);
      index--;
    }

    String preferredSurname;
    if (prefixParticles.isNotEmpty) {
      preferredSurname = '${prefixParticles.join(' ')} $coreSurname';
    } else if (surnameParts.length >= 2) {
      preferredSurname =
          '${surnameParts[surnameParts.length - 2]} ${surnameParts.last}';
    } else {
      preferredSurname = coreSurname;
    }

    String compactSurname;
    if (!preferredSurname.contains(' ')) {
      const int maxSurnameChars = 7;
      compactSurname = preferredSurname.length > maxSurnameChars
          ? '${preferredSurname.substring(0, maxSurnameChars)}.'
          : preferredSurname;
    } else {
      const int maxCompoundChars = 12;
      if (preferredSurname.length <= maxCompoundChars) {
        compactSurname = preferredSurname;
      } else {
        final surnameTokens = preferredSurname.split(' ');
        final prefixes = surnameTokens.sublist(0, surnameTokens.length - 1);
        final lastToken = surnameTokens.last;
        final prefixText = prefixes.join(' ');
        final availableForLast = maxCompoundChars - prefixText.length - 1;

        if (availableForLast >= 3) {
          final shortenedLast = lastToken.length > availableForLast
              ? '${lastToken.substring(0, availableForLast - 1)}.'
              : lastToken;
          compactSurname = '$prefixText $shortenedLast';
        } else {
          compactSurname = '${preferredSurname.substring(0, 11)}.';
        }
      }
    }

    return '$firstInitial. $compactSurname';
  }

  @override
  Widget build(BuildContext context) {
    final double baseFontScale =
        isDesktopMode ? Constants.desktopModeFontScale : 1.0;
    final double baseSizeScale =
        isDesktopMode ? Constants.desktopModeScaleFactor : 1.0;
    final double compactFontScale = isCompactMode ? 0.8 : 1.0;
    final double compactSizeScale = isCompactMode ? 0.72 : 1.0;
    final double fontScale = baseFontScale * zoomFactor * compactFontScale;
    final double sizeScale = baseSizeScale * zoomFactor * compactSizeScale;
    final String displayName =
        isCompactMode ? _compactDisplayName(player.name) : player.name;

    final Widget marker = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: (isCompactMode ? 8 : 12) * sizeScale,
          vertical: (isCompactMode ? 3 : 4) * sizeScale),
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
        mainAxisSize: MainAxisSize.max,
        children: [
          // Person icon
          Icon(
            Icons.person,
            size: (isCompactMode ? 16 : 20) * sizeScale,
            color: AppColors.playerIcon,
          ),
          SizedBox(width: (isCompactMode ? 6 : 8) * sizeScale),
          // Player name
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: (isCompactMode ? 14 : 16) * fontScale,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
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
