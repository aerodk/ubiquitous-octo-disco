import 'dart:math';
import '../models/math_problem.dart';

/// Service to generate random math problems for 5th grade level practice
class MathProblemGenerator {
  final Random _random = Random();

  /// Minimum value for operands (5th grade level)
  static const int minValue = 20;

  /// Maximum value for operands (5th grade level)
  static const int maxValue = 50;

  /// Generate a random math problem of the specified type
  MathProblem generateProblem(MathOperationType operationType) {
    switch (operationType) {
      case MathOperationType.addition:
        return _generateAddition();
      case MathOperationType.subtraction:
        return _generateSubtraction();
      case MathOperationType.multiplication:
        return _generateMultiplication();
      case MathOperationType.division:
        return _generateDivision();
    }
  }

  /// Generate a random problem from any operation type
  MathProblem generateRandomProblem() {
    final operations = MathOperationType.values;
    final randomType = operations[_random.nextInt(operations.length)];
    return generateProblem(randomType);
  }

  /// Generate an addition problem (e.g., 25 + 37)
  MathProblem _generateAddition() {
    final operand1 = _randomNumber();
    final operand2 = _randomNumber();
    return MathProblem.fromOperands(
      operand1,
      operand2,
      MathOperationType.addition,
    );
  }

  /// Generate a subtraction problem (e.g., 48 - 23)
  /// Ensures result is positive
  MathProblem _generateSubtraction() {
    final operand1 = _randomNumber();
    final operand2 = _randomNumber();
    
    // Ensure operand1 >= operand2 for positive result
    if (operand1 >= operand2) {
      return MathProblem.fromOperands(
        operand1,
        operand2,
        MathOperationType.subtraction,
      );
    } else {
      return MathProblem.fromOperands(
        operand2,
        operand1,
        MathOperationType.subtraction,
      );
    }
  }

  /// Generate a multiplication problem (e.g., 7 × 17)
  /// Uses smaller numbers to keep it at 5th grade level
  MathProblem _generateMultiplication() {
    // Use smaller numbers for multiplication
    final operand1 = _random.nextInt(10) + 2; // 2-11
    final operand2 = _randomNumber(); // 20-50
    return MathProblem.fromOperands(
      operand1,
      operand2,
      MathOperationType.multiplication,
    );
  }

  /// Generate a division problem (e.g., 48 ÷ 6)
  /// Ensures clean division with no remainder
  MathProblem _generateDivision() {
    // Generate divisor (smaller number)
    final divisor = _random.nextInt(9) + 2; // 2-10
    
    // Generate quotient
    final quotient = _random.nextInt(10) + 3; // 3-12
    
    // Calculate dividend to ensure clean division
    final dividend = divisor * quotient;
    
    return MathProblem.fromOperands(
      dividend,
      divisor,
      MathOperationType.division,
    );
  }

  /// Generate a random number between minValue and maxValue
  int _randomNumber() {
    return _random.nextInt(maxValue - minValue + 1) + minValue;
  }
}
