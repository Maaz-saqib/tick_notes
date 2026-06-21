import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tick_notes/main.dart'; // Allows access to your HomePage

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late final String _selectedQuote;

  final List<IconData> _icons = [
    Icons.edit_note,
    Icons.add_circle_outline,
    Icons.timer_outlined,
    Icons.check_circle_outline,
  ];

  static const List<String> _quotes = [
    "Discipline is choosing between what you want now and what you want most.",
    "Consistency is the foundation of mastery.",
    "Growth begins at the edge of comfort.",
    "Small steps every day outrun big leaps once in a while.",
    "Focus is not about saying yes — it's about saying no to everything else.",
    "Your future self is built by your present habits.",
    "Don't wait for motivation. Build the system.",
    "The clock doesn't stop. Neither should you.",
    "The secret of getting ahead is getting started.",
    "Focus on progress, not perfection.",
    "Discipline is freedom.",
    "Small habits shape big destinies.",
    "Do it now. Your future self will thank you.",
    "One step at a time. One day at a time.",
  ];

  int _currentIconIndex = 0;

  @override
  void initState() {
    super.initState();
    // Select one random quote to display during the splash duration
    _selectedQuote = _quotes[Random().nextInt(_quotes.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.addListener(() {
      final newIndex = (_controller.value * _icons.length).floor().clamp(
        0,
        _icons.length - 1,
      );
      if (newIndex != _currentIconIndex) {
        setState(() {
          _currentIconIndex = newIndex;
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    _controller.forward();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final primaryColor = isDarkMode ? Colors.white : const Color(0xFF121212);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  _icons[_currentIconIndex],
                  key: ValueKey<int>(_currentIconIndex),
                  size: 80,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 4,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _selectedQuote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: primaryColor.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
