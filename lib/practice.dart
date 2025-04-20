import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({Key? key}) : super(key: key);

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  int _questionIndex = 0;       // Tracks the current question number (0-9)
  int _questionsEncountered = 0; // Tracks how many questions were shown/attempted
  int _timeLeft = 8;             // Timer duration per question
  Timer? _timer;                 // Timer object
  late Map<String, dynamic> _currentQuestion; // Holds question data
  final Random _random = Random();  // Random number generator

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Logic Methods ---

  void _generateQuestion() {
    int num1 = _random.nextInt(20) + 1;
    int num2 = _random.nextInt(20) + 1;
    int operation = _random.nextInt(4); // 0:+, 1:-, 2:*, 3:/
    int correctAnswer;
    String question;

    switch (operation) {
      case 0: // Addition
        question = '$num1 + $num2 = ?';
        correctAnswer = num1 + num2;
        break;
      case 1: // Subtraction
        if (num1 < num2) {
          int temp = num1; num1 = num2; num2 = temp;
        }
        question = '$num1 - $num2 = ?';
        correctAnswer = num1 - num2;
        break;
      case 2: // Multiplication
        num1 = _random.nextInt(12) + 1;
        num2 = _random.nextInt(12) + 1;
        question = '$num1 × $num2 = ?';
        correctAnswer = num1 * num2;
        break;
      case 3: // Division (integer result)
        int result = _random.nextInt(10) + 1;
        num2 = _random.nextInt(10) + 1;
        num1 = result * num2;
        question = '$num1 ÷ $num2 = ?';
        correctAnswer = result;
        break;
      default: // Fallback
        question = '$num1 + $num2 = ?';
        correctAnswer = num1 + num2;
    }

    // Generate distractors carefully
    Set<int> answersSet = {correctAnswer};
    while (answersSet.length < 4) {
      int range = max(10, (correctAnswer * 0.5).abs().ceil());
      int distractor = correctAnswer + _random.nextInt(range * 2 + 1) - range;
      if (correctAnswer >= 0 && distractor < 0) {
        distractor = _random.nextInt(max(1, correctAnswer + range));
      }
      answersSet.add(distractor);
    }

    List<int> answers = answersSet.toList();
    answers.shuffle(_random);

    _currentQuestion = {
      'question': question,
      'answers': answers.map((a) => a.toString()).toList(),
      'correctAnswer': correctAnswer.toString(),
    };
  }

  void _startTimer() {
    _timeLeft = 8;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _nextQuestion(timedOut: true);
      }
    });
  }

  void _nextQuestion({bool timedOut = false}) {
    _timer?.cancel();
    if (!mounted) return;

    _questionsEncountered++; // Increment count for every question passed/timed out

    Future.delayed(Duration(milliseconds: timedOut ? 0 : 100), () {
      if (!mounted) return;

      if (_questionIndex < 9) { // Check if we've finished 10 questions (0-9)
        setState(() {
          _questionIndex++;
          _generateQuestion(); // Prepare the next question's data
          _startTimer();      // Start the timer for the new question
        });
      } else {
        _showEndDialog(); // Show summary if 10 questions are done
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    _timer?.cancel();
    _nextQuestion();
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: const Text(
          '🏁 Practice Finished!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          'You went through $_questionsEncountered questions.\nKeep practicing!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            onPressed: () {
              Navigator.of(context).pop();
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Practice Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _questionIndex = 0;
                _questionsEncountered = 0;
                _generateQuestion();
                _startTimer();
              });
            },
          ),
        ],
      ),
    );
  }

  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {

    final List<String> answers = (_currentQuestion['answers'] as List<String>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Question ${_questionIndex + 1}/10'),
        centerTitle: true,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: (_questionIndex + 1) / 10,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 22, color: _timeLeft < 4 ? Colors.red.shade700 : Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Text(
                    '$_timeLeft seconds',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft < 4 ? Colors.red.shade700 : Colors.orange.shade900, // Highlight low time
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
              margin: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100)
              ),
              child: Text(
                _currentQuestion['question'] ?? 'Loading...',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.indigo),
                textAlign: TextAlign.center,
              ),
            ),

            if (answers.length == 4)
              Column(
                children: [
                  Row(
                    children: [
                      _buildAnswerButton(answers[0]), // Button 1
                      const SizedBox(width: 15),    // Horizontal space
                      _buildAnswerButton(answers[1]), // Button 2
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildAnswerButton(answers[2]), // Button 3
                      const SizedBox(width: 15),    // Horizontal space
                      _buildAnswerButton(answers[3]), // Button 4
                    ],
                  ),
                ],
              )
            else
              ...answers.map((answer) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildAnswerButton(answer, isExpanded: false),
              )).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer, {bool isExpanded = true}) {
    Widget button = ElevatedButton(
      onPressed: () => _checkAnswer(answer),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        elevation: 2,
      ),
      child: Text(answer, textAlign: TextAlign.center),
    );

    return isExpanded ? Expanded(child: button) : button;
  }
}