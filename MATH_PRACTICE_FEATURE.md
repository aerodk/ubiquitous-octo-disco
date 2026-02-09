# Math Practice Feature

## Overview

This feature adds a comprehensive math practice module to the Padel Tournament app, allowing users (particularly 5th grade students) to practice various math operations with intelligent hints.

## Requirements Met

Based on the Danish problem statement:

1. ✅ **Expanded exercise types**: Beyond multiplication tables to include 5th grade level exercises
2. ✅ **Four operations**: Addition, subtraction, multiplication, and division
3. ✅ **Appropriate difficulty**: Numbers between 20-50 for realistic 5th grade practice
4. ✅ **Hint system**: Provides hints after 2 incorrect attempts
5. ✅ **Intelligent hints**: Context-aware strategies (e.g., breaking down 7×17 into 7×10 + 7×7)

## Features

### Problem Types

#### Addition
- Numbers: 20-50
- Example: `37 + 25`
- Hint: "Prøv at opdele i 37 + 20 + 5"

#### Subtraction
- Numbers: 20-50
- Always ensures positive results
- Example: `48 - 23`
- Hint: "Prøv at trække 20 fra 48 først, og derefter trække 3"

#### Multiplication
- First operand: 2-11 (smaller for manageability)
- Second operand: 20-50
- Example: `7 × 17`
- Hint: "Prøv at opdele i 7 × 10 (= 70) og 7 × 7 (= 49), og læg resultaterne sammen"

#### Division
- Clean division only (no remainders)
- Divisor: 2-10
- Example: `48 ÷ 6`
- Hint: "Tænk: Hvad gange 6 giver 48?"

### User Interface

#### Operation Selection
- **Blandet** (Mixed): Random selection from all operation types
- **Plus**: Addition only
- **Minus**: Subtraction only
- **Gange**: Multiplication only
- **Division**: Division only

#### Problem Display
- Large, clear problem text with operation symbol
- Operation type label below
- Clean card-based design

#### Answer Input
- Number-only keyboard
- Large input field for easy typing
- Submit button or Enter key

#### Feedback System
- ✅ **Correct**: Green message with emoji, auto-advances after 2 seconds
- ❌ **Incorrect**: Red message, clears input, increments wrong attempt counter
- ℹ️ **Skip**: Blue message showing correct answer, auto-advances after 2 seconds

#### Hint Display
- Appears after 2 wrong attempts
- Yellow/amber highlighted box with lightbulb icon
- Context-specific strategy for the current problem
- Remains visible until problem is solved or skipped

#### Statistics Tracking
- Shows: "Korrekt: X/Y (Z%)"
- Real-time accuracy percentage
- Persistent during session

## Implementation Details

### Models

#### `MathProblem`
- Represents a single math problem
- Properties:
  - `operand1`: First number
  - `operand2`: Second number
  - `operationType`: Addition, subtraction, multiplication, or division
  - `correctAnswer`: Pre-calculated correct answer
  - `hint`: Optional hint string
- Methods:
  - `problemText`: Returns formatted problem (e.g., "7 × 17")
  - `fromOperands()`: Factory constructor to create problem
  - `copyWith()`: Add hint to existing problem

#### `MathOperationType` (Enum)
- Values: `addition`, `subtraction`, `multiplication`, `division`
- Extensions:
  - `displayName`: Danish name (Plus, Minus, Gange, Division)
  - `symbol`: Math symbol (+, -, ×, ÷)

### Services

#### `MathProblemGenerator`
- Generates random problems for each operation type
- Ensures appropriate difficulty levels
- Features:
  - Subtraction always produces positive results
  - Division always has no remainder
  - Multiplication uses smaller first operand
  - Configurable min/max values (currently 20-50)

#### `HintService`
- Generates context-aware hints for each problem type
- Strategies:
  - **Addition**: Break down into tens and ones
  - **Subtraction**: Sequential subtraction of tens then ones
  - **Multiplication**: Distributive property (7×17 = 7×10 + 7×7)
  - **Division**: Convert to multiplication question

### UI Components

#### `MathPracticeScreen`
- Main practice interface
- State management:
  - Current problem
  - Wrong attempt counter (triggers hint at 2)
  - Correct/total statistics
  - Selected operation type filter
  - Feedback message and color
  - Current hint (if shown)
- Auto-advancement after correct answer or skip

## Navigation

Access the math practice feature from:
- **Setup Screen**: Calculator icon (🔢) in the app bar
- Tooltip: "Matematik Øvelser"

## Testing

### Unit Tests (26 tests, all passing)

#### `test/math_problem_test.dart`
- Operation type extensions (display names, symbols)
- Problem creation with correct answers
- Problem text generation
- Copy with hint functionality
- Equality checks

#### `test/math_problem_generator_test.dart`
- Addition problem generation
- Subtraction with positive results
- Multiplication with smaller first operand
- Division with no remainder
- Random problem variety
- Answer correctness

#### `test/hint_service_test.dart`
- Addition hints with ones/tens breakdown
- Subtraction hints with sequential strategy
- Multiplication hints with distributive property
- Division hints with multiplication conversion
- All operation types coverage

## Example User Flow

1. **Start**: User clicks calculator icon on setup screen
2. **Select Type**: User chooses "Gange" (multiplication)
3. **Problem Shown**: "7 × 17"
4. **First Attempt**: User enters "100" → ❌ "Forkert, prøv igen!"
5. **Second Attempt**: User enters "110" → ❌ "Forkert, prøv igen!"
6. **Hint Appears**: "Prøv at opdele i 7 × 10 (= 70) og 7 × 7 (= 49), og læg resultaterne sammen"
7. **Third Attempt**: User calculates 70 + 49 = 119 → ✅ "Korrekt! 🎉"
8. **Auto-Advance**: New problem appears after 2 seconds

## Code Structure

```
lib/
├── models/
│   └── math_problem.dart          # MathProblem class and MathOperationType enum
├── services/
│   ├── math_problem_generator.dart # Problem generation logic
│   └── hint_service.dart          # Hint generation logic
└── screens/
    └── math_practice_screen.dart  # Main UI screen

test/
├── math_problem_test.dart
├── math_problem_generator_test.dart
└── hint_service_test.dart
```

## Future Enhancements

Potential improvements:
- Persistent statistics across sessions
- Difficulty level adjustment
- Time tracking
- Achievement badges
- Progress reports
- Custom number ranges
- More hint variations
- Sound effects
- Celebration animations

## Technical Notes

- Uses Flutter's `StatefulWidget` for state management
- Number-only keyboard with input validation
- Clean separation of concerns (Model-Service-UI)
- Comprehensive test coverage
- Danish language throughout
- Follows existing app patterns and style
