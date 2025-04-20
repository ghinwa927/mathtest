import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int _timeLeft = 8;
  Timer? _timer;
  late Map<String, dynamic> _currentQuestion;
  final Random _random = Random();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 1), // Make confetti burst shorter
  );
  bool _allCorrect = false;
  int _score = 0;
  int _testCounter = 0;

  // --- Data Generation & Logic (mostly unchanged) ---
  @override
  void initState() {
    super.initState();
    _loadTestCounter();
    _generateQuestion();
    _startTimer();
  }

  Future<void> _loadTestCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _testCounter = prefs.getInt('testCounter') ?? 0;
    });
  }

  Future<void> _saveTestCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('testCounter', _testCounter);
  }

  void _generateQuestion() {
    int num1 = _random.nextInt(20) + 1;
    int num2 = _random.nextInt(20) + 1;
    int operation = _random.nextInt(4);
    int correctAnswer;
    String question;

    switch (operation) {
      case 0: // Addition
        question = '$num1 + $num2 = ?';
        correctAnswer = num1 + num2;
        break;
      case 1: // Subtraction
        if (num1 < num2) {
          // Swap numbers for non-negative result
          int temp = num1;
          num1 = num2;
          num2 = temp;
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
      case 3: // Division
        int result = _random.nextInt(10) + 1;
        num2 = _random.nextInt(10) + 1;
        num1 = result * num2;
        question = '$num1 ÷ $num2 = ?';
        correctAnswer = result;
        break;
      default: // Fallback (shouldn't happen)
        question = '$num1 + $num2 = ?';
        correctAnswer = num1 + num2;
    }

    // Generate distractors more carefully to avoid collision with correct answer
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
    answers.shuffle();

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

    Future.delayed( Duration(milliseconds: timedOut ? 0 : 150), () {
      if (!mounted) return;

      if (_questionIndex < 9) {
        setState(() {
          _questionIndex++;
          _generateQuestion();
          _startTimer();
        });
      } else {
        _showEndDialog();
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    _timer?.cancel();
    bool isCorrect = selectedAnswer == _currentQuestion['correctAnswer'];
    if (isCorrect) {
      _correctAnswers++;
    }

    _nextQuestion();
  }

  void _showEndDialog() async {
    if (!mounted) return;

    _score = _correctAnswers * 10;
    _allCorrect = _correctAnswers == 10;

    if (_allCorrect) {
      _confettiController.play();
    }

    _testCounter++;
    await _saveScore('test$_testCounter', _score.toString());
    await _saveTestCounter();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Text(
          _allCorrect ? '🎉 Perfect Score! 🎉' : 'Test Finished!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Size column to content
          children: [
            Text(
              'Your score: $_score / 100',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (_allCorrect)
              const Text(
                'Amazing job! You got all questions right!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.green),
              )
            else
              Text(
                'You answered $_correctAnswers out of 10 questions correctly.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center, // Center the button
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, // Use theme color
              foregroundColor: Colors.white, // Text color
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Go back from TestPage
              }
              // Alternatively, use Navigator.pushReplacement if TestPage should replace previous
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveScore(String testId, String score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> testGrades = prefs.getStringList('testGrades') ?? [];
      // Store more info: testId, score, date
      String dateStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
      testGrades.add('$testId:$score:$dateStr');
      await prefs.setStringList('testGrades', testGrades);
    } catch (e) {
      print("Error saving score: $e");
      // Optionally show a snackbar to the user
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the answers list safely
    final List<String> answers = (_currentQuestion['answers'] as List<String>?) ?? [];

    return Scaffold(
      appBar: AppBar(
          title: Text('Question ${_questionIndex + 1}/10'),
          centerTitle: true, // Center the title
          // Simple progress bar in the app bar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6.0),
            child: LinearProgressIndicator(
              value: (_questionIndex + 1) / 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          )
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0), // Increased padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push elements apart
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch elements horizontally
              children: [
                // Top Section: Score and Timer
                Card( // Use a Card for better visual grouping
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: ${_correctAnswers * 10}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Row( // Timer with Icon
                          children: [
                            Icon(Icons.timer_outlined, size: 20, color: _timeLeft < 4 ? Colors.red : Colors.grey[700]),
                            const SizedBox(width: 4),
                            Text(
                              '$_timeLeft s',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _timeLeft < 4 ? Colors.red : Colors.black87, // Highlight when time is low
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),


                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentQuestion['question'] ?? 'Loading...',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),

                if (answers.length == 4)
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildAnswerButton(answers[0]), // Button 1
                          const SizedBox(width: 15),
                          _buildAnswerButton(answers[1]), // Button 2
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildAnswerButton(answers[2]), // Button 3
                          const SizedBox(width: 15),
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

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String answer, {bool isExpanded = true}) {
    Widget button = ElevatedButton(
      onPressed: () => _checkAnswer(answer),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        elevation: 3,
      ),
      child: Text(answer, textAlign: TextAlign.center),
    );

    return isExpanded ? Expanded(child: button) : button;
  }
}