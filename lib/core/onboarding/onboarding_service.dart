import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'onboarding_tooltip_card.dart';

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
              return OnboardingTooltipCard(
                title: "Your second brain",
                body: "Thoughts disappear. Notes don't. Capture anything instantly before your mind moves on.",
                stepIndex: 1,
                totalSteps: 5,
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
              return OnboardingTooltipCard(
                title: "Stop forgetting. Start doing.",
                body: "Your to-do list with reminders that actually fire. Because a task without a deadline is just a wish.",
                stepIndex: 2,
                totalSteps: 5,
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
              return OnboardingTooltipCard(
                title: "Protect your attention",
                body: "Distractions are expensive. The Pomodoro timer gives your focus a structure that makes deep work feel achievable.",
                stepIndex: 3,
                totalSteps: 5,
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
              return OnboardingTooltipCard(
                title: "One tap to start",
                body: "Everything in this app begins here. Fast, clean, no friction between your idea and saving it.",
                stepIndex: 4,
                totalSteps: 5,
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
              return OnboardingTooltipCard(
                title: "See your effort, not just feel it",
                body: "30 days of your focus time visualized. Because progress you can see is progress you will repeat.",
                stepIndex: 5,
                totalSteps: 5,
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


}
