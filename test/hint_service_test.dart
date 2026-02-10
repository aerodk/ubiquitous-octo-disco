import 'package:flutter_test/flutter_test.dart';
import 'package:star_cano/models/math_problem.dart';
import 'package:star_cano/services/hint_service.dart';

void main() {
  group('HintService', () {
    final hintService = HintService();

    group('Addition Hints', () {
      test('should generate hint for addition with ones', () {
        final problem = MathProblem.fromOperands(37, 25, MathOperationType.addition);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('opdele'));
        expect(hint, contains('37'));
        expect(hint, contains('20'));
        expect(hint, contains('5'));
      });

      test('should generate hint for addition with only tens', () {
        final problem = MathProblem.fromOperands(30, 20, MathOperationType.addition);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('20'));
        expect(hint, contains('30'));
      });
    });

    group('Subtraction Hints', () {
      test('should generate hint for subtraction with ones', () {
        final problem = MathProblem.fromOperands(48, 23, MathOperationType.subtraction);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('trække'));
        expect(hint, contains('48'));
        expect(hint, contains('20'));
        expect(hint, contains('3'));
      });

      test('should generate hint for subtraction with only tens', () {
        final problem = MathProblem.fromOperands(50, 30, MathOperationType.subtraction);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('trække'));
        expect(hint, contains('30'));
        expect(hint, contains('50'));
      });
    });

    group('Multiplication Hints', () {
      test('should generate detailed hint for multiplication with ones', () {
        final problem = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('opdele'));
        expect(hint, contains('7 × 10'));
        expect(hint, contains('7 × 7'));
        expect(hint, contains('70')); // 7 × 10
        expect(hint, contains('49')); // 7 × 7
      });

      test('should generate simple hint for multiplication with only tens', () {
        final problem = MathProblem.fromOperands(5, 20, MathOperationType.multiplication);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('5 × 20'));
        expect(hint, contains('100')); // 5 × 20
      });

      test('should handle single-digit second operand', () {
        final problem = MathProblem.fromOperands(8, 9, MathOperationType.multiplication);
        final hint = hintService.generateHint(problem);
        
        // Should still work for numbers less than 10
        expect(hint, isNotEmpty);
      });
    });

    group('Division Hints', () {
      test('should generate hint using multiplication concept', () {
        final problem = MathProblem.fromOperands(48, 6, MathOperationType.division);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('Tænk'));
        expect(hint, contains('6'));
        expect(hint, contains('48'));
        expect(hint, contains('gange'));
      });

      test('should work for different division problems', () {
        final problem = MathProblem.fromOperands(36, 9, MathOperationType.division);
        final hint = hintService.generateHint(problem);
        
        expect(hint, contains('9'));
        expect(hint, contains('36'));
      });
    });

    test('should generate hints for all operation types', () {
      final additionProblem = MathProblem.fromOperands(25, 37, MathOperationType.addition);
      final subtractionProblem = MathProblem.fromOperands(48, 23, MathOperationType.subtraction);
      final multiplicationProblem = MathProblem.fromOperands(7, 17, MathOperationType.multiplication);
      final divisionProblem = MathProblem.fromOperands(48, 6, MathOperationType.division);

      expect(hintService.generateHint(additionProblem), isNotEmpty);
      expect(hintService.generateHint(subtractionProblem), isNotEmpty);
      expect(hintService.generateHint(multiplicationProblem), isNotEmpty);
      expect(hintService.generateHint(divisionProblem), isNotEmpty);
    });
  });
}
