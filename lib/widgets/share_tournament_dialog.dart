import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/share_service.dart';

/// Dialog for sharing a tournament via a direct link
/// 
/// This dialog allows users to:
/// - Generate a shareable link with or without passcode
/// - Copy the link to clipboard
/// - Understand the difference between view-only and editable shares
class ShareTournamentDialog extends StatefulWidget {
  final String tournamentCode;
  final String? passcode;

  const ShareTournamentDialog({
    super.key,
    required this.tournamentCode,
    this.passcode,
  });

  @override
  State<ShareTournamentDialog> createState() => _ShareTournamentDialogState();
}

class _ShareTournamentDialogState extends State<ShareTournamentDialog> {
  final ShareService _shareService = ShareService();
  bool _includePasscode = false;

  String get _shareLink {
    return _shareService.generateShareLink(
      tournamentCode: widget.tournamentCode,
      includePasscode: _includePasscode,
      passcode: widget.passcode,
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _shareLink));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link kopieret til udklipsholder'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canIncludePasscode = widget.passcode != null && widget.passcode!.isNotEmpty;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.share, color: Colors.blue),
          SizedBox(width: 8),
          Text('Del Turnering'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vælg hvordan du vil dele turneringen:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Option 1: View-only (no passcode)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: !_includePasscode ? Colors.blue.shade400 : Colors.blue.shade200,
                  width: !_includePasscode ? 2 : 1,
                ),
              ),
              child: RadioListTile<bool>(
                title: const Text(
                  'Kun Visning',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Andre kan se turneringen, men ikke redigere eller indtaste resultater. Ingen adgangskode kræves.',
                  style: TextStyle(fontSize: 12),
                ),
                value: false,
                groupValue: _includePasscode,
                onChanged: (value) {
                  setState(() {
                    _includePasscode = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Option 2: With passcode (still view-only but with passcode in URL)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canIncludePasscode ? Colors.orange.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _includePasscode && canIncludePasscode 
                      ? Colors.orange.shade400 
                      : Colors.grey.shade300,
                  width: _includePasscode && canIncludePasscode ? 2 : 1,
                ),
              ),
              child: RadioListTile<bool>(
                title: Text(
                  'Med Adgangskode (Kun Visning)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canIncludePasscode ? null : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  canIncludePasscode
                      ? 'Adgangskoden inkluderes i linket. Andre kan se turneringen uden at indtaste kode, men kan stadig ikke redigere.'
                      : 'Ikke tilgængelig - turnering er ikke gemt med adgangskode',
                  style: TextStyle(
                    fontSize: 12,
                    color: canIncludePasscode ? null : Colors.grey,
                  ),
                ),
                value: true,
                groupValue: _includePasscode,
                onChanged: canIncludePasscode
                    ? (value) {
                        setState(() {
                          _includePasscode = value ?? false;
                        });
                      }
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Generated link display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Del Link:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: _copyToClipboard,
                        tooltip: 'Kopiér link',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _shareLink,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Information box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delte links er kun til visning. For at redigere turneringen, skal andre bruge "Hent Turnering" med koden og adgangskoden.',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Luk'),
        ),
        ElevatedButton.icon(
          onPressed: _copyToClipboard,
          icon: const Icon(Icons.copy),
          label: const Text('Kopiér Link'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
