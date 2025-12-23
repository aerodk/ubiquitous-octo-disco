import 'package:flutter/material.dart';
import '../models/tournament_settings.dart';

/// A collapsible widget for configuring tournament settings
/// Used in SetupScreen to allow customization before tournament starts
class TournamentSettingsWidget extends StatefulWidget {
  final TournamentSettings initialSettings;
  final ValueChanged<TournamentSettings> onSettingsChanged;
  final bool enabled;

  const TournamentSettingsWidget({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
    this.enabled = true,
  });

  @override
  State<TournamentSettingsWidget> createState() => _TournamentSettingsWidgetState();
}

class _TournamentSettingsWidgetState extends State<TournamentSettingsWidget> {
  late TournamentSettings _currentSettings;

  // Available point options (even numbers from 18 to 32)
  static const List<int> _pointOptions = [18, 20, 22, 24, 26, 28, 30, 32];

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.initialSettings;
  }

  void _updateSettings(TournamentSettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  String _getStrategyTitle(PairingStrategy strategy) {
    switch (strategy) {
      case PairingStrategy.balanced:
        return 'Balanced (1+3 vs 2+4)';
      case PairingStrategy.topAlliance:
        return 'Top Alliance (1+2 vs 3+4)';
      case PairingStrategy.maxCompetition:
        return 'Max Competition (1+4 vs 2+3)';
    }
  }

  String _getStrategySubtitle(PairingStrategy strategy) {
    switch (strategy) {
      case PairingStrategy.balanced:
        return 'Standard - mest afbalanceret';
      case PairingStrategy.topAlliance:
        return 'Top 2 spiller sammen';
      case PairingStrategy.maxCompetition:
        return 'Mest konkurrencedygtig';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomized = _currentSettings.isCustomized;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        enabled: widget.enabled,
        leading: Icon(
          Icons.settings,
          color: isCustomized ? theme.colorScheme.primary : null,
        ),
        title: Text(
          'Turnering indstillinger',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCustomized ? theme.colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          _currentSettings.summary,
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points Per Match Setting
                _buildPointsPerMatchSection(theme),
                
                const Divider(height: 32),
                
                // Pause Points Setting
                _buildPausePointsSection(theme),
                
                const Divider(height: 32),
                
                // Lane Assignment Strategy Setting
                _buildLaneAssignmentSection(theme),
                
                const Divider(height: 32),
                
                // Pairing Strategy Setting
                _buildPairingStrategySection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsPerMatchSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Point per kamp',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hvor mange point der spilles til i hver kamp. Standard er 24.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _currentSettings.pointsPerMatch,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            suffixIcon: const Icon(Icons.sports_score),
            enabled: widget.enabled,
          ),
          items: _pointOptions.map((points) {
            return DropdownMenuItem(
              value: points,
              child: Text('$points point'),
            );
          }).toList(),
          onChanged: widget.enabled
              ? (value) {
                  if (value != null) {
                    _updateSettings(_currentSettings.copyWith(
                      pointsPerMatch: value,
                    ));
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPausePointsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Point til spillere på pause',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vælg om spillere på pause skal få point. Standard er 12 point.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _currentSettings.pausePointsAwarded,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            suffixIcon: const Icon(Icons.timer_off),
            enabled: widget.enabled,
          ),
          items: const [
            DropdownMenuItem(
              value: 0,
              child: Text('0 point (ingen belønning)'),
            ),
            DropdownMenuItem(
              value: 12,
              child: Text('12 point (standard)'),
            ),
          ],
          onChanged: widget.enabled
              ? (value) {
                  if (value != null) {
                    _updateSettings(_currentSettings.copyWith(
                      pausePointsAwarded: value,
                    ));
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPairingStrategySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sidste runde parring',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vælg hvordan spillere parres i sidste runde.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...PairingStrategy.values.map((strategy) {
          return RadioListTile<PairingStrategy>(
            title: Text(_getStrategyTitle(strategy)),
            subtitle: Text(_getStrategySubtitle(strategy)),
            value: strategy,
            groupValue: _currentSettings.finalRoundStrategy,
            onChanged: widget.enabled
                ? (value) {
                    if (value != null) {
                      _updateSettings(_currentSettings.copyWith(
                        finalRoundStrategy: value,
                      ));
                    }
                  }
                : null,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildLaneAssignmentSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bane fordeling',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vælg hvordan kampe fordeles på baner.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...LaneAssignmentStrategy.values.map((strategy) {
          return RadioListTile<LaneAssignmentStrategy>(
            title: Text(_getLaneStrategyTitle(strategy)),
            subtitle: Text(_getLaneStrategySubtitle(strategy)),
            value: strategy,
            groupValue: _currentSettings.laneAssignmentStrategy,
            onChanged: widget.enabled
                ? (value) {
                    if (value != null) {
                      _updateSettings(_currentSettings.copyWith(
                        laneAssignmentStrategy: value,
                      ));
                    }
                  }
                : null,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  String _getLaneStrategyTitle(LaneAssignmentStrategy strategy) {
    switch (strategy) {
      case LaneAssignmentStrategy.sequential:
        return 'Sekventiel (bedste spillere på bane 1)';
      case LaneAssignmentStrategy.random:
        return 'Tilfældig (blandet fordeling)';
    }
  }

  String _getLaneStrategySubtitle(LaneAssignmentStrategy strategy) {
    switch (strategy) {
      case LaneAssignmentStrategy.sequential:
        return 'Standard - bedste på første baner';
      case LaneAssignmentStrategy.random:
        return 'Tilfældig banefordeling';
    }
  }
}
