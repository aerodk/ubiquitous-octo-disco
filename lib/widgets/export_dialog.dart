import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import '../models/player_standing.dart';
import '../models/tournament.dart';
import '../services/export_service.dart';

// Conditional import for web vs non-web platforms
import '../utils/html_stub.dart'
    if (dart.library.html) 'dart:html' as html;

/// Reusable widget to display export options and handle export operations
class ExportDialog extends StatefulWidget {
  final List<PlayerStanding> standings;
  final Tournament tournament;

  const ExportDialog({
    super.key,
    required this.standings,
    required this.tournament,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Generate export data
      final exportData = ExportService.exportStandings(
        standings: widget.standings,
        tournament: widget.tournament,
        format: _selectedFormat,
      );

      // Get file name and MIME type
      final fileName = ExportService.getFileName(
        tournament: widget.tournament,
        format: _selectedFormat,
      );
      final mimeType = ExportService.getMimeType(_selectedFormat);

      // Trigger download for web platform
      _downloadFile(exportData, fileName, mimeType);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eksporteret til $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved eksport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _downloadFile(String content, String fileName, String mimeType) {
    if (!kIsWeb) {
      // For mobile platforms, this would need platform-specific implementation
      // For now, show a message that export is only available on web
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eksport er kun tilgængelig på web-versionen'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Web-specific download implementation
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a temporary anchor element and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    // Clean up
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final availableFormats = ExportService.getAvailableFormats();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.file_download, color: Colors.blue),
          SizedBox(width: 8),
          Text('Eksporter Resultater'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vælg format til eksport:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...availableFormats.map((format) => RadioListTile<ExportFormat>(
                title: Text(format.displayName),
                subtitle: Text(
                  format.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                value: format,
                groupValue: _selectedFormat,
                onChanged: _isExporting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFormat = value;
                          });
                        }
                      },
              )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filen vil blive gemt i din downloads mappe',
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuller'),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _handleExport,
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_isExporting ? 'Eksporterer...' : 'Eksporter'),
        ),
      ],
    );
  }
}

/// Future export options information dialog
class FutureExportOptionsDialog extends StatelessWidget {
  const FutureExportOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber),
          SizedBox(width: 8),
          Text('Fremtidige Eksport Muligheder'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kommende eksport formater:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFormatItem(
              Icons.picture_as_pdf,
              'PDF',
              'Flot formateret rapport med grafer og statistikker',
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildFormatItem(
              Icons.table_chart,
              'Excel',
              'Microsoft Excel spreadsheet med formler og diagrammer',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildFormatItem(
              Icons.image,
              'Billede',
              'PNG/JPEG billede af leaderboard til deling på sociale medier',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildFormatItem(
              Icons.share,
              'Del direkte',
              'Del resultater via e-mail, SMS eller sociale medier',
              Colors.blue,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Luk'),
        ),
      ],
    );
  }

  Widget _buildFormatItem(
      IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
