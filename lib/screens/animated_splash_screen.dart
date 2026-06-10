import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/Services/Auth/FirebaseAuthProvider.dart';
import 'package:practice_app/Services/Auth/bloc/auth_bloc.dart';
import 'package:practice_app/main.dart'; // Allows access to your HomePage

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  final List<IconData> _icons = [
    Icons.edit_note,
    Icons.add_circle_outline,
    Icons.timer_outlined,
    Icons.check_circle_outline,
  ];

  int _currentIconIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addListener(() {
      final newIndex = (_controller.value * _icons.length).floor().clamp(0, _icons.length - 1);
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
        pageBuilder: (context, animation, secondaryAnimation) => BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
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
          ],
        ),
      ),
    );
  }
}
