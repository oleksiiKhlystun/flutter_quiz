import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const QuizPage(),
    );
  }
}

class Question {
  final String text;
  final List<Option> options;
  bool isLocked;
  Option? selectedOption;

  Question({
    required this.text,
    required this.options,
    this.isLocked = false,
    this.selectedOption,
  });
}

class Option {
  final String text;
  final bool isCorrect;

  const Option({
    required this.text,
    required this.isCorrect,
  });
}

final List<Question> originalQuestions = [
Question(
  text: 'Choose the correct sentence in third conditional form:',
  options: [
    const Option(text: 'If I win the lottery, I would have bought a house', isCorrect: false),
    const Option(text: 'If I had studied harder, I would have passed the exam.', isCorrect: true),
    const Option(text: 'If I would have seen him, I told him the truth.', isCorrect: false),
    const Option(text: 'If I studied, I would pass the test.', isCorrect: false),
  ],
),

Question(
  text: 'What does the third conditional usually express?',
  options: [
    const Option(text: 'A future possibility', isCorrect: false),
    const Option(text: 'A general truth', isCorrect: false),
    const Option(text: 'A past unreal situation and its result', isCorrect: true),
    const Option(text: 'A habit or routine', isCorrect: false),
  ],
),

Question(
  text: 'Choose the sentence with the correct third conditional form:',
  options: [
    const Option(text: 'If she had left earlier, she will catch the train.', isCorrect: false),
    const Option(text: 'If we had known about the traffic, we would have left sooner.', isCorrect: true),
    const Option(text: 'If I would know, I would have helped you.', isCorrect: false),
    const Option(text: 'If he would have tried, he could win.', isCorrect: false),
  ],
),

Question(
  text: 'Which of the following sentences is NOT a third conditional?',
  options: [
    const Option(text: 'If you had told me, I would have come.', isCorrect: false),
    const Option(text: 'If they had studied, they would have passed.', isCorrect: false),
    const Option(text: 'If I see her, I will say hello.', isCorrect: true),
    const Option(text: 'If he had called, we would have answered.', isCorrect: false),
  ],
),
];

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late PageController _controller;
  late List<Question> _questions;
  int _questionNumber = 1;
  int _score = 0;
  bool _isLocked = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  static List<int> _history = [];

  @override
  void initState() {
    super.initState();
    _questions = originalQuestions.map((q) => Question(
      text: q.text,
      options: q.options,
    )).toList();

    _controller = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void restartQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const QuizPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 32),
            Text('Question $_questionNumber/${_questions.length}'),
            const Divider(thickness: 1, color: Colors.grey),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PageView.builder(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return buildQuestion(question);
                  },
                ),
              ),
            ),
            _isLocked ? buildElevatedButton() : const SizedBox.shrink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Column buildQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          question.text,
          style: const TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: OptionsWidget(
            question: question,
            onClickedOption: (option) {
              if (question.isLocked) return;
              setState(() {
                question.isLocked = true;
                question.selectedOption = option;
                _isLocked = question.isLocked;
                if (option.isCorrect) _score++;
              });
            },
          ),
        ),
      ],
    );
  }

  ElevatedButton buildElevatedButton() {
    return ElevatedButton(
      onPressed: () {
        _animationController.reset();
        _animationController.forward();
        if (_questionNumber < _questions.length) {
          _controller.nextPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
          );
          setState(() {
            _questionNumber++;
            _isLocked = false;
          });
        } else {
          _history.add(_score);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(score: _score, history: _history),
            ),
          );
        }
      },
      child: Text(_questionNumber < _questions.length ? 'Next Page' : 'See the Result'),
    );
  }
}

class OptionsWidget extends StatelessWidget {
  final Question question;
  final ValueChanged<Option> onClickedOption;

  const OptionsWidget({super.key, required this.question, required this.onClickedOption});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: question.options
              .map((option) => buildOption(context, option))
              .toList(),
        ),
      );

  Widget buildOption(BuildContext context, Option option) {
    final color = getColorForOption(option, question);
    return GestureDetector(
      onTap: () => onClickedOption(option),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(option.text, style: const TextStyle(fontSize: 20)),
            getIconForOption(option, question)
          ],
        ),
      ),
    );
  }

  Color getColorForOption(Option option, Question question) {
    final isSelected = option == question.selectedOption;
    if (question.isLocked) {
      if (isSelected) {
        return option.isCorrect ? Colors.green : Colors.red;
      } else if (option.isCorrect) {
        return Colors.green;
      }
    }
    return Colors.grey.shade300;
  }

  Widget getIconForOption(Option option, Question question) {
    final isSelected = option == question.selectedOption;
    if (question.isLocked) {
      if (isSelected) {
        return option.isCorrect
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.red);
      } else if (option.isCorrect) {
        return const Icon(Icons.check_circle, color: Colors.green);
      }
    }
    return const SizedBox.shrink();
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final List<int> history;

  const ResultPage({super.key, required this.score, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You got $score/${originalQuestions.length}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizPage()),
                );
              },
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 40),
            const Text('Results History:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Attempt ${index + 1}'),
                  trailing: Text('${history[index]}/${originalQuestions.length}'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
