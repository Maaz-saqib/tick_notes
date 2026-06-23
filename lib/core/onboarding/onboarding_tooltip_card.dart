import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class OnboardingTooltipCard extends StatelessWidget {
  final String title;
  final String body;
  final int stepIndex;
  final int totalSteps;
  final TutorialCoachMarkController controller;

  const OnboardingTooltipCard({
    super.key,
    required this.title,
    required this.body,
    required this.stepIndex,
    required this.totalSteps,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E), // The app's navy
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF9FA8DA),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.6,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip button on Step 1 only
              if (stepIndex == 1)
                GestureDetector(
                  onTap: () => controller.skip(),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF9FA8DA),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
              else
                const SizedBox(width: 24), // Maintain alignment spacer

              // Row of totalSteps dots
              Row(
                children: List.generate(totalSteps, (index) {
                  final isCurrent = index == (stepIndex - 1);
                  return Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(right: index == (totalSteps - 1) ? 0 : 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: isCurrent ? 1.0 : 0.3),
                    ),
                  );
                }),
              ),

              // Next / Let's go button
              GestureDetector(
                onTap: () => controller.next(),
                child: Text(
                  stepIndex == totalSteps ? "Let's go" : 'Next',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
