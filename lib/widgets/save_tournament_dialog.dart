import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tournament.dart';
import '../services/firebase_service.dart';

/// Dialog for saving a tournament to Firebase Cloud Storage
/// 
/// This dialog allows users to:
/// - Enter/confirm tournament name
/// - Generate unique 8-digit tournament code
/// - Generate 6-digit passcode
/// - Save tournament to Firestore
/// - Copy codes to clipboard
class SaveTournamentDialog extends StatefulWidget {
  final Tournament tournament;
  final String? existingCode;
  final String? existingPasscode;

  const SaveTournamentDialog({
    super.key,
    required this.tournament,
    this.existingCode,
    this.existingPasscode,
  });

  @override
  State<SaveTournamentDialog> createState() => _SaveTournamentDialogState();
}

class _SaveTournamentDialogState extends State<SaveTournamentDialog> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = false;
  bool _isSaved = false;
  String? _tournamentCode;
  String? _passcode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.tournament.name;
    
    // If we have existing codes, this is an update
    if (widget.existingCode != null && widget.existingPasscode != null) {
      _tournamentCode = widget.existingCode;
      _passcode = widget.existingPasscode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateAndSave() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Indtast venligst et turnerings navn';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if Firebase is available
      final isAvailable = await _firebaseService.isFirebaseAvailable();
      if (!isAvailable) {
        throw Exception('Firebase er ikke tilgængelig. Kontroller din internetforbindelse.');
      }

      String code;
      String passcode;
      
      // If updating existing tournament, use existing codes
      if (widget.existingCode != null && widget.existingPasscode != null) {
        code = widget.existingCode!;
        passcode = widget.existingPasscode!;
        
        // Update existing tournament
        await _firebaseService.updateTournament(
          tournamentCode: code,
          passcode: passcode,
          /// Creates a copy of the tournament with an updated name field.
          /// This is necessary because the tournament object is immutable, so we must
          /// create a new instance with the modified name rather than mutating the
          /// existing object directly. This follows the immutability pattern common
          /// in Flutter and Dart applications.
          tournament: widget.tournament.copyWith(name: name)
        );
      } else {
        // Generate new codes
        code = await _firebaseService.generateUniqueTournamentCode();
        passcode = _firebaseService.generatePasscode();
        
        // Save new tournament
        await _firebaseService.saveTournament(
          tournament: widget.tournament.copyWith(name: name),
          tournamentCode: code,
          passcode: passcode,
        );
      }

      setState(() {
        _isLoading = false;
        _isSaved = true;
        _tournamentCode = code;
        _passcode = passcode;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fejl ved gemning: ${e.toString()}';
      });
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kopieret til udklipsholder'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyBothCodes() async {
    final text = 'Turnerings Kode: $_tournamentCode\nAdgangskode: $_passcode';
    await _copyToClipboard(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaved) {
      return _buildSuccessDialog();
    } else {
      return _buildInputDialog();
    }
  }

  Widget _buildInputDialog() {
    final isUpdate = widget.existingCode != null;
    
    return AlertDialog(
      title: Text(isUpdate ? 'Opdater Turnering i Cloud' : 'Gem Turnering i Cloud'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Turnerings Navn',
              border: OutlineInputBorder(),
            ),
            enabled: !_isLoading,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ],
          if (isUpdate) ...[
            const SizedBox(height: 16),
            Text(
              'Turnerings Kode: ${widget.existingCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _generateAndSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isUpdate ? 'Opdater' : 'Generer Kode'),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog() {
    final isUpdate = widget.existingCode != null;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isUpdate ? Icons.cloud_upload : Icons.cloud_done,
            color: Colors.green,
            size: 32,
          ),
          const SizedBox(width: 8),
          Text(isUpdate ? 'Turnering Opdateret!' : 'Turnering Gemt!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Turnerings Kode:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(_tournamentCode!),
                      tooltip: 'Kopiér kode',
                    ),
                  ],
                ),
                Text(
                  _tournamentCode!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Adgangskode:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyToClipboard(_passcode!),
                      tooltip: 'Kopiér adgangskode',
                    ),
                  ],
                ),
                Text(
                  _passcode!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Skriv disse koder ned!\nDu skal bruge dem for at hente turneringen senere.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _copyBothCodes,
          child: const Text('Kopiér Begge'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'code': _tournamentCode,
              'passcode': _passcode,
              'name': _nameController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Færdig'),
        ),
      ],
    );
  }
}
