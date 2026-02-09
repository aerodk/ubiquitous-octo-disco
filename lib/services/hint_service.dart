import '../models/math_problem.dart';

/// Service to generate contextual hints for math problems
class HintService {
  /// Generate a hint for the given math problem
  String generateHint(MathProblem problem) {
    switch (problem.operationType) {
      case MathOperationType.addition:
        return _generateAdditionHint(problem);
      case MathOperationType.subtraction:
        return _generateSubtractionHint(problem);
      case MathOperationType.multiplication:
        return _generateMultiplicationHint(problem);
      case MathOperationType.division:
        return _generateDivisionHint(problem);
    }
  }

  /// Generate hint for addition problems
  /// Example: 37 + 25 → "Prøv at opdele i 37 + 20 + 5"
  String _generateAdditionHint(MathProblem problem) {
    final op1 = problem.operand1;
    final op2 = problem.operand2;
    
    // Break down second operand into tens and ones
    final tens = (op2 ~/ 10) * 10;
    final ones = op2 % 10;
    
    if (ones == 0) {
      return 'Prøv at lægge $tens til $op1';
    } else {
      return 'Prøv at opdele i $op1 + $tens + $ones';
    }
  }

  /// Generate hint for subtraction problems
  /// Example: 48 - 23 → "Prøv at trække 20 fra 48 først, og derefter trække 3"
  String _generateSubtractionHint(MathProblem problem) {
    final op1 = problem.operand1;
    final op2 = problem.operand2;
    
    // Break down second operand into tens and ones
    final tens = (op2 ~/ 10) * 10;
    final ones = op2 % 10;
    
    if (ones == 0) {
      return 'Prøv at trække $tens fra $op1';
    } else {
      return 'Prøv at trække $tens fra $op1 først, og derefter trække $ones';
    }
  }

  /// Generate hint for multiplication problems
  /// Example: 7 × 17 → "Prøv at opdele i 7 × 10 og 7 × 7, og læg resultaterne sammen"
  String _generateMultiplicationHint(MathProblem problem) {
    final op1 = problem.operand1;
    final op2 = problem.operand2;
    
    // Break down larger operand into tens and ones
    final tens = (op2 ~/ 10) * 10;
    final ones = op2 % 10;
    
    if (ones == 0) {
      final result = op1 * tens;
      return 'Prøv at beregne $op1 × $tens = $result';
    } else {
      final tensResult = op1 * tens;
      final onesResult = op1 * ones;
      return 'Prøv at opdele i $op1 × $tens (= $tensResult) og $op1 × $ones (= $onesResult), og læg resultaterne sammen';
    }
  }

  /// Generate hint for division problems
  /// Example: 48 ÷ 6 → "Tænk: Hvad gange 6 giver 48?"
  String _generateDivisionHint(MathProblem problem) {
    final dividend = problem.operand1;
    final divisor = problem.operand2;
    
    // Provide hint using multiplication
    return 'Tænk: Hvad gange $divisor giver $dividend?';
  }
}
