import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/math_problem.dart';

void main() {
  group('MathOperationType Extension', () {
    test('should return correct display names', () {
      expect(MathOperationType.addition.displayName, 'Plus');
      expect(MathOperationType.subtraction.displayName, 'Minus');
      expect(MathOperationType.multiplication.displayName, 'Gange');
      expect(MathOperationType.division.displayName, 'Division');
    });

    test('should return correct symbols', () {
      expect(MathOperationType.addition.symbol, '+');
      expect(MathOperationType.subtraction.symbol, '-');
      expect(MathOperationType.multiplication.symbol, '×');
      expect(MathOperationType.division.symbol, '÷');
    });
  });

  group('MathProblem', () {
    test('should create problem with correct answer for addition', () {
      final problem = MathProblem.fromOperands(25, 37, MathOperationType.addition);
      
      expect(problem.operand1, 25);
      expect(problem.operand2, 37);
      expect(problem.operationType, MathOperationType.addition);
      expect(problem.correctAnswer, 62);
    });

    test('should create problem with correct answer for subtraction', () {
      final problem = MathProblem.fromOperands(48, 23, MathOperationType.subtraction);
      
      expect(problem.operand1, 48);
      expect(problem.operand2, 23);
      expect(problem.operationType, MathOperationType.subtraction);
      expect(problem.correctAnswer, 25);
    });

    test('should create problem with correct answer for multiplication', () {
      final problem = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      
      expect(problem.operand1, 7);
      expect(problem.operand2, 17);
      expect(problem.operationType, MathOperationType.multiplication);
      expect(problem.correctAnswer, 119);
    });

    test('should create problem with correct answer for division', () {
      final problem = MathProblem.fromOperands(48, 6, MathOperationType.division);
      
      expect(problem.operand1, 48);
      expect(problem.operand2, 6);
      expect(problem.operationType, MathOperationType.division);
      expect(problem.correctAnswer, 8);
    });

    test('should generate correct problem text', () {
      final additionProblem = MathProblem.fromOperands(25, 37, MathOperationType.addition);
      expect(additionProblem.problemText, '25 + 37');

      final multiplicationProblem = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      expect(multiplicationProblem.problemText, '7 × 17');
    });

    test('should copy with hint', () {
      final problem = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      final withHint = problem.copyWith(hint: 'Break it down');
      
      expect(withHint.operand1, problem.operand1);
      expect(withHint.operand2, problem.operand2);
      expect(withHint.operationType, problem.operationType);
      expect(withHint.correctAnswer, problem.correctAnswer);
      expect(withHint.hint, 'Break it down');
      expect(problem.hint, null); // Original should be unchanged
    });

    test('should be equal when all properties match', () {
      final problem1 = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      final problem2 = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      
      expect(problem1, problem2);
    });

    test('should not be equal when properties differ', () {
      final problem1 = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      final problem2 = MathProblem.fromOperands(7, 18, MathOperationType.multiplication);
      
      expect(problem1, isNot(problem2));
    });
  });
}
