/// Represents different types of math operations
enum MathOperationType {
  addition,
  subtraction,
  multiplication,
  division,
}

/// Extension to get Danish display name for operation types
extension MathOperationTypeExtension on MathOperationType {
  String get displayName {
    switch (this) {
      case MathOperationType.addition:
        return 'Plus';
      case MathOperationType.subtraction:
        return 'Minus';
      case MathOperationType.multiplication:
        return 'Gange';
      case MathOperationType.division:
        return 'Division';
    }
  }

  String get symbol {
    switch (this) {
      case MathOperationType.addition:
        return '+';
      case MathOperationType.subtraction:
        return '-';
      case MathOperationType.multiplication:
        return '×';
      case MathOperationType.division:
        return '÷';
    }
  }
}

/// Represents a math problem with operands, operation type, and correct answer
class MathProblem {
  final int operand1;
  final int operand2;
  final MathOperationType operationType;
  final int correctAnswer;
  final String? hint;

  MathProblem({
    required this.operand1,
    required this.operand2,
    required this.operationType,
    required this.correctAnswer,
    this.hint,
  });

  /// Returns the problem as a string (e.g., "7 × 17")
  String get problemText {
    return '$operand1 ${operationType.symbol} $operand2';
  }

  /// Factory constructor to create a problem from operands and operation type
  factory MathProblem.fromOperands(
    int operand1,
    int operand2,
    MathOperationType operationType,
  ) {
    int answer;
    switch (operationType) {
      case MathOperationType.addition:
        answer = operand1 + operand2;
        break;
      case MathOperationType.subtraction:
        answer = operand1 - operand2;
        break;
      case MathOperationType.multiplication:
        answer = operand1 * operand2;
        break;
      case MathOperationType.division:
        answer = operand1 ~/ operand2; // Integer division
        break;
    }

    return MathProblem(
      operand1: operand1,
      operand2: operand2,
      operationType: operationType,
      correctAnswer: answer,
    );
  }

  /// Copy with method to add hint
  MathProblem copyWith({String? hint}) {
    return MathProblem(
      operand1: operand1,
      operand2: operand2,
      operationType: operationType,
      correctAnswer: correctAnswer,
      hint: hint ?? this.hint,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MathProblem &&
          runtimeType == other.runtimeType &&
          operand1 == other.operand1 &&
          operand2 == other.operand2 &&
          operationType == other.operationType &&
          correctAnswer == other.correctAnswer;

  @override
  int get hashCode =>
      operand1.hashCode ^
      operand2.hashCode ^
      operationType.hashCode ^
      correctAnswer.hashCode;
}
