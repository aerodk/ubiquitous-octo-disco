import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';

/// Dialog for loading a tournament from Firebase Cloud Storage
/// 
/// This dialog allows users to:
/// - Enter 8-digit tournament code
/// - Enter 6-digit passcode
/// - Load tournament from Firestore
/// - Handle validation and errors
class LoadTournamentDialog extends StatefulWidget {
  const LoadTournamentDialog({super.key});

  @override
  State<LoadTournamentDialog> createState() => _LoadTournamentDialogState();
}

class _LoadTournamentDialogState extends State<LoadTournamentDialog> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadTournament() async {
    final code = _codeController.text.trim();
    final passcode = _passcodeController.text.trim();
    
    // Validation
    if (code.isEmpty || passcode.isEmpty) {
      setState(() {
        _errorMessage = 'Indtast venligst både kode og adgangskode';
      });
      return;
    }
    
    if (code.length != 8) {
      setState(() {
        _errorMessage = 'Turnerings kode skal være 8 cifre';
      });
      return;
    }
    
    if (passcode.length != 6) {
      setState(() {
        _errorMessage = 'Adgangskode skal være 6 cifre';
      });
      return;
    }
    
    // Validate numeric input
    if (!RegExp(r'^\d+$').hasMatch(code) || !RegExp(r'^\d+$').hasMatch(passcode)) {
      setState(() {
        _errorMessage = 'Kode og adgangskode må kun indeholde tal';
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

      // Try to load tournament
      final tournament = await _firebaseService.loadTournament(
        tournamentCode: code,
        passcode: passcode,
      );

      if (mounted) {
        // Return tournament with codes to caller
        Navigator.pop(context, {
          'tournament': tournament,
          'code': code,
          'passcode': passcode,
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        
        // Parse error message for user-friendly display
        String errorMsg = e.toString();
        if (errorMsg.contains('Invalid passcode')) {
          _errorMessage = 'Forkert adgangskode';
        } else if (errorMsg.contains('Tournament not found')) {
          _errorMessage = 'Turnering ikke fundet. Kontroller koden.';
        } else if (errorMsg.contains('not found')) {
          _errorMessage = 'Turnering ikke fundet. Kontroller koden.';
        } else if (errorMsg.contains('network') || errorMsg.contains('internet')) {
          _errorMessage = 'Netværksfejl. Kontroller din internetforbindelse.';
        } else {
          _errorMessage = 'Fejl ved indlæsning: $errorMsg';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cloud_download, color: Colors.blue),
          SizedBox(width: 8),
          Text('Hent Turnering'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indtast turnerings kode og adgangskode for at hente din gemte turnering.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Turnerings Kode',
              hintText: '12345678',
              helperText: '8 cifre',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pin),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            enabled: !_isLoading,
            onSubmitted: (_) => _loadTournament(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passcodeController,
            decoration: const InputDecoration(
              labelText: 'Adgangskode',
              hintText: '123456',
              helperText: '6 cifre',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            obscureText: true,
            enabled: !_isLoading,
            onSubmitted: (_) => _loadTournament(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
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
          onPressed: _isLoading ? null : _loadTournament,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Hent'),
        ),
      ],
    );
  }
}
