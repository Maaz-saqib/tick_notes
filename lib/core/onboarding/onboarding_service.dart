import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class OnboardingService {
  OnboardingService._internal();
  static final OnboardingService instance = OnboardingService._internal();

  TutorialCoachMark? _tutorial;

  bool get isShowing => _tutorial?.isShowing ?? false;

  void skip() {
    _tutorial?.skip();
  }

  void showOnboarding(
    BuildContext context, {
    required GlobalKey notesTabKey,
    required GlobalKey tasksTabKey,
    required GlobalKey focusTabKey,
    required GlobalKey addNoteKey,
    required GlobalKey statsTabKey,
  }) {
    final targets = <TargetFocus>[
      // STEP 1 — Notes tab
      TargetFocus(
        identify: "notes_tab",
        keyTarget: notesTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 8,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTooltipCard(
                context: context,
                title: "Your second brain",
                body: "Thoughts disappear. Notes don't. Capture anything instantly before your mind moves on.",
                stepIndex: 1,
                controller: controller,
              );
            },
          ),
        ],
      ),
      // STEP 2 — Tasks tab
      TargetFocus(
        identify: "tasks_tab",
        keyTarget: tasksTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 8,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTooltipCard(
                context: context,
                title: "Stop forgetting. Start doing.",
                body: "Your to-do list with reminders that actually fire. Because a task without a deadline is just a wish.",
                stepIndex: 2,
                controller: controller,
              );
            },
          ),
        ],
      ),
      // STEP 3 — Focus tab
      TargetFocus(
        identify: "focus_tab",
        keyTarget: focusTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 8,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTooltipCard(
                context: context,
                title: "Protect your attention",
                body: "Distractions are expensive. The Pomodoro timer gives your focus a structure that makes deep work feel achievable.",
                stepIndex: 3,
                controller: controller,
              );
            },
          ),
        ],
      ),
      // STEP 4 — FAB button (add note)
      TargetFocus(
        identify: "add_note_fab",
        keyTarget: addNoteKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 8,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTooltipCard(
                context: context,
                title: "One tap to start",
                body: "Everything in this app begins here. Fast, clean, no friction between your idea and saving it.",
                stepIndex: 4,
                controller: controller,
              );
            },
          ),
        ],
      ),
      // STEP 5 — Stats / Analytics tab
      TargetFocus(
        identify: "stats_tab",
        keyTarget: statsTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 8,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTooltipCard(
                context: context,
                title: "See your effort, not just feel it",
                body: "30 days of your focus time visualized. Because progress you can see is progress you will repeat.",
                stepIndex: 5,
                controller: controller,
              );
            },
          ),
        ],
      ),
    ];

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xBF000000), // Black at 75% opacity
      opacityShadow: 1.0,
      paddingFocus: 8,
      hideSkip: true,
      pulseEnable: false, // No pulsing animation (no physics-based animation)
      focusAnimationDuration: const Duration(milliseconds: 250), // Fade in duration 250ms
      unFocusAnimationDuration: const Duration(milliseconds: 250),
      onFinish: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('onboarding_complete', true);
        });
        _tutorial = null;
      },
      onSkip: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('onboarding_complete', true);
        });
        _tutorial = null;
        return true;
      },
    );

    _tutorial!.show(context: context);
  }

  Widget _buildTooltipCard({
    required BuildContext context,
    required String title,
    required String body,
    required int stepIndex,
    required TutorialCoachMarkController controller,
  }) {
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
            color: Colors.white.withOpacity(0.2),
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

              // Row of 5 dots
              Row(
                children: List.generate(5, (index) {
                  final isCurrent = index == (stepIndex - 1);
                  return Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(right: index == 4 ? 0 : 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(isCurrent ? 1.0 : 0.3),
                    ),
                  );
                }),
              ),

              // Next / Let's go button
              GestureDetector(
                onTap: () => controller.next(),
                child: Text(
                  stepIndex == 5 ? "Let's go" : 'Next',
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
