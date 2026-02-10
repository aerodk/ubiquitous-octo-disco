import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/math_problem.dart';
import '../services/math_problem_generator.dart';
import '../services/hint_service.dart';

/// Screen for practicing 5th grade level math problems
class MathPracticeScreen extends StatefulWidget {
  const MathPracticeScreen({super.key});

  @override
  State<MathPracticeScreen> createState() => _MathPracticeScreenState();
}

class _MathPracticeScreenState extends State<MathPracticeScreen> {
  final MathProblemGenerator _problemGenerator = MathProblemGenerator();
  final HintService _hintService = HintService();
  final TextEditingController _answerController = TextEditingController();
  
  late MathProblem _currentProblem;
  int _wrongAttempts = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;
  String? _feedbackMessage;
  Color? _feedbackColor;
  String? _currentHint;
  MathOperationType? _selectedType;

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _generateNewProblem() {
    setState(() {
      if (_selectedType != null) {
        _currentProblem = _problemGenerator.generateProblem(_selectedType!);
      } else {
        _currentProblem = _problemGenerator.generateRandomProblem();
      }
      _wrongAttempts = 0;
      _feedbackMessage = null;
      _feedbackColor = null;
      _currentHint = null;
      _answerController.clear();
    });
  }

  void _checkAnswer() {
    final userAnswer = int.tryParse(_answerController.text);
    
    if (userAnswer == null) {
      setState(() {
        _feedbackMessage = 'Indtast venligst et tal';
        _feedbackColor = Colors.orange;
      });
      return;
    }

    _totalAttempts++;

    if (userAnswer == _currentProblem.correctAnswer) {
      // Correct answer
      setState(() {
        _correctCount++;
        _feedbackMessage = 'Korrekt! 🎉';
        _feedbackColor = Colors.green;
      });
      
      // Auto-generate new problem after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _generateNewProblem();
        }
      });
    } else {
      // Wrong answer
      _wrongAttempts++;
      
      setState(() {
        _feedbackMessage = 'Forkert, prøv igen! 😕';
        _feedbackColor = Colors.red;
        
        // Show hint after 2 wrong attempts
        if (_wrongAttempts >= 2 && _currentHint == null) {
          _currentHint = _hintService.generateHint(_currentProblem);
        }
      });
      
      _answerController.clear();
    }
  }

  void _skipProblem() {
    setState(() {
      _feedbackMessage = 'Rigtigt svar var: ${_currentProblem.correctAnswer}';
      _feedbackColor = Colors.blue;
    });
    
    // Generate new problem after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _generateNewProblem();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = _totalAttempts > 0 
        ? (_correctCount / _totalAttempts * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matematik Øvelser'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Statistics display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Korrekt: $_correctCount/$_totalAttempts ($accuracy%)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Operation type selector
              const Text(
                'Vælg opgave type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Blandet'),
                    selected: _selectedType == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = null;
                        _generateNewProblem();
                      });
                    },
                  ),
                  ...MathOperationType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = selected ? type : null;
                          _generateNewProblem();
                        });
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 32),
              
              // Problem display
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        _currentProblem.problemText,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentProblem.operationType.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Answer input
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Dit svar',
                  border: OutlineInputBorder(),
                  hintText: 'Indtast dit svar',
                ),
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
                onSubmitted: (_) => _checkAnswer(),
              ),
              const SizedBox(height: 16),
              
              // Check answer button
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Tjek Svar'),
              ),
              const SizedBox(height: 8),
              
              // Skip button
              TextButton(
                onPressed: _skipProblem,
                child: const Text('Spring over'),
              ),
              const SizedBox(height: 16),
              
              // Feedback message
              if (_feedbackMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _feedbackColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _feedbackColor ?? Colors.grey),
                  ),
                  child: Text(
                    _feedbackMessage!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _feedbackColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Hint display
              if (_currentHint != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Hint:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentHint!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
