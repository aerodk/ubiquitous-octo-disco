import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/math_problem.dart';
import 'package:star_cano/services/math_problem_generator.dart';

void main() {
  group('MathProblemGenerator', () {
    final generator = MathProblemGenerator();

    test('should generate addition problem with correct answer', () {
      final problem = generator.generateProblem(MathOperationType.addition);
      
      expect(problem.operationType, MathOperationType.addition);
      expect(problem.correctAnswer, problem.operand1 + problem.operand2);
      expect(problem.operand1, greaterThanOrEqualTo(MathProblemGenerator.minValue));
      expect(problem.operand1, lessThanOrEqualTo(MathProblemGenerator.maxValue));
      expect(problem.operand2, greaterThanOrEqualTo(MathProblemGenerator.minValue));
      expect(problem.operand2, lessThanOrEqualTo(MathProblemGenerator.maxValue));
    });

    test('should generate subtraction problem with positive result', () {
      final problem = generator.generateProblem(MathOperationType.subtraction);
      
      expect(problem.operationType, MathOperationType.subtraction);
      expect(problem.correctAnswer, greaterThanOrEqualTo(0));
      expect(problem.correctAnswer, problem.operand1 - problem.operand2);
    });

    test('should generate multiplication problem with smaller first operand', () {
      final problem = generator.generateProblem(MathOperationType.multiplication);
      
      expect(problem.operationType, MathOperationType.multiplication);
      expect(problem.correctAnswer, problem.operand1 * problem.operand2);
      expect(problem.operand1, greaterThanOrEqualTo(2));
      expect(problem.operand1, lessThanOrEqualTo(11));
      expect(problem.operand2, greaterThanOrEqualTo(MathProblemGenerator.minValue));
      expect(problem.operand2, lessThanOrEqualTo(MathProblemGenerator.maxValue));
    });

    test('should generate division problem with no remainder', () {
      final problem = generator.generateProblem(MathOperationType.division);
      
      expect(problem.operationType, MathOperationType.division);
      expect(problem.correctAnswer, problem.operand1 ~/ problem.operand2);
      expect(problem.operand1 % problem.operand2, 0); // No remainder
      expect(problem.operand2, greaterThanOrEqualTo(2));
      expect(problem.operand2, lessThanOrEqualTo(10));
    });

    test('should generate random problem from any operation type', () {
      final problems = List.generate(20, (_) => generator.generateRandomProblem());
      
      // Check that we get different operation types
      final operationTypes = problems.map((p) => p.operationType).toSet();
      expect(operationTypes.length, greaterThan(1)); // Should have variety
      
      // All problems should have correct answers
      for (final problem in problems) {
        switch (problem.operationType) {
          case MathOperationType.addition:
            expect(problem.correctAnswer, problem.operand1 + problem.operand2);
            break;
          case MathOperationType.subtraction:
            expect(problem.correctAnswer, problem.operand1 - problem.operand2);
            break;
          case MathOperationType.multiplication:
            expect(problem.correctAnswer, problem.operand1 * problem.operand2);
            break;
          case MathOperationType.division:
            expect(problem.correctAnswer, problem.operand1 ~/ problem.operand2);
            expect(problem.operand1 % problem.operand2, 0);
            break;
        }
      }
    });

    test('should generate unique problems', () {
      final problems = List.generate(10, (_) => generator.generateRandomProblem());
      
      // Check that we get at least some different problems
      final uniqueProblems = problems.toSet();
      expect(uniqueProblems.length, greaterThan(5)); // At least some variety
    });
  });
}
