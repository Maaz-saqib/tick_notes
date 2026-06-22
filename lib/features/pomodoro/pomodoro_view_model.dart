import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'pomodoro_repository.dart';
import '../../core/database/app_database.dart';
import '../../core/notifications/notification_service.dart';

part 'pomodoro_view_model.g.dart';

enum FocusMode { pomodoro, open }

enum PomodoroPhase { focus, breakPhase }

class PomodoroState {
  final FocusMode mode;
  final PomodoroPhase pomodoroPhase;
  final int pomodoroSession; // ranges from 1 to 4
  final bool isRunning;
  final Duration durationLimit;
  final Duration elapsedDuration;
  final DateTime? sessionStart;
  final DateTime? lastTickTime;

  const PomodoroState({
    required this.mode,
    required this.pomodoroPhase,
    required this.pomodoroSession,
    required this.isRunning,
    required this.durationLimit,
    required this.elapsedDuration,
    this.sessionStart,
    this.lastTickTime,
  });

  PomodoroState copyWith({
    FocusMode? mode,
    PomodoroPhase? pomodoroPhase,
    int? pomodoroSession,
    bool? isRunning,
    Duration? durationLimit,
    Duration? elapsedDuration,
    DateTime? sessionStart,
    DateTime? lastTickTime,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      pomodoroPhase: pomodoroPhase ?? this.pomodoroPhase,
      pomodoroSession: pomodoroSession ?? this.pomodoroSession,
      isRunning: isRunning ?? this.isRunning,
      durationLimit: durationLimit ?? this.durationLimit,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      sessionStart: sessionStart ?? this.sessionStart,
      lastTickTime: lastTickTime ?? this.lastTickTime,
    );
  }
}

@riverpod
class PomodoroViewModel extends _$PomodoroViewModel {
  Timer? _timer;
  Duration _customFocusDuration = const Duration(minutes: 25);
  Duration _customBreakDuration = const Duration(minutes: 5);

  @override
  PomodoroState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return PomodoroState(
      mode: FocusMode.pomodoro,
      pomodoroPhase: PomodoroPhase.focus,
      pomodoroSession: 1,
      isRunning: false,
      durationLimit: _customFocusDuration,
      elapsedDuration: Duration.zero,
    );
  }

  void updateCustomDurations({required int focusMins, required int breakMins}) {
    _customFocusDuration = Duration(minutes: focusMins);
    _customBreakDuration = Duration(minutes: breakMins);
    if (!state.isRunning && state.mode == FocusMode.pomodoro) {
      if (state.pomodoroPhase == PomodoroPhase.focus) {
        state = state.copyWith(durationLimit: _customFocusDuration);
      } else if (state.pomodoroPhase == PomodoroPhase.breakPhase) {
        state = state.copyWith(durationLimit: _customBreakDuration);
      }
    }
  }

  int get customFocusMins => _customFocusDuration.inMinutes;
  int get customBreakMins => _customBreakDuration.inMinutes;

  void setMode(FocusMode mode) {
    if (state.isRunning) {
      stopSession();
    }
    Duration limit = Duration.zero;
    if (mode == FocusMode.pomodoro) {
      limit = _customFocusDuration;
    }
    state = PomodoroState(
      mode: mode,
      pomodoroPhase: PomodoroPhase.focus,
      pomodoroSession: 1,
      isRunning: false,
      durationLimit: limit,
      elapsedDuration: Duration.zero,
    );
  }

  void startSession() {
    if (state.isRunning) return;

    final now = DateTime.now();
    state = state.copyWith(
      isRunning: true,
      sessionStart: state.sessionStart ?? now,
      lastTickTime: now,
    );

    // Schedule notification for background if we are in Pomodoro mode
    if (state.mode == FocusMode.pomodoro) {
      final remaining = state.durationLimit - state.elapsedDuration;
      final scheduledTime = now.add(remaining);
      NotificationService.instance.scheduleNotification(
        id: 9999, // Static ID for Pomodoro reminders
        title: state.pomodoroPhase == PomodoroPhase.focus
            ? 'Focus Timer Done'
            : 'Break Timer Done',
        body: state.pomodoroPhase == PomodoroPhase.focus
            ? 'Time to take a break!'
            : 'Break is over. Ready to focus?',
        scheduledTime: scheduledTime,
      );
    }

    _startTimer();
  }

  void pauseSession() {
    if (!state.isRunning) return;
    _timer?.cancel();
    NotificationService.instance.cancelNotification(9999);
    state = state.copyWith(isRunning: false);
  }

  void stopSession({bool forceSave = true}) {
    _timer?.cancel();
    NotificationService.instance.cancelNotification(9999);

    final start = state.sessionStart;
    final now = DateTime.now();

    if (forceSave && start != null) {
      final elapsedMins = state.elapsedDuration.inMinutes;
      final elapsedSecs = state.elapsedDuration.inSeconds;

      // Only save if elapsed session is meaningful (>= 10 seconds)
      if (elapsedSecs >= 10) {
        final durationMinutes = elapsedMins > 0 ? elapsedMins : 1;

        if (state.mode == FocusMode.open) {
          // Open Focus Mode: Save time with "open" mode
          ref
              .read(pomodoroRepositoryProvider)
              .add(
                PomodoroSessionsCompanion.insert(
                  startTime: start,
                  endTime: now,
                  durationMinutes: durationMinutes,
                  mode: 'open',
                ),
              );
        } else if (state.mode == FocusMode.pomodoro &&
            state.pomodoroPhase == PomodoroPhase.focus) {
          // Pomodoro Focus Phase: Save time with "pomodoro" mode
          ref
              .read(pomodoroRepositoryProvider)
              .add(
                PomodoroSessionsCompanion.insert(
                  startTime: start,
                  endTime: now,
                  durationMinutes: durationMinutes,
                  mode: 'pomodoro',
                ),
              );
        }
        // If it's a break phase, we skip database writing entirely
      }
    }

    Duration limit = Duration.zero;
    if (state.mode == FocusMode.pomodoro) {
      limit = state.pomodoroPhase == PomodoroPhase.focus
          ? _customFocusDuration
          : _customBreakDuration;
    }

    state = PomodoroState(
      mode: state.mode,
      pomodoroPhase: state.pomodoroPhase,
      pomodoroSession: state.pomodoroSession,
      isRunning: false,
      durationLimit: limit,
      elapsedDuration: Duration.zero,
      sessionStart: null,
      lastTickTime: null,
    );
  }

  void skipSession() {
    stopSession(forceSave: false);
    // Cycle phases
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.breakPhase,
        pomodoroSession: state.pomodoroSession,
        isRunning: false,
        durationLimit: _customBreakDuration,
        elapsedDuration: Duration.zero,
      );
    } else {
      final nextSession = state.pomodoroSession >= 4
          ? 1
          : state.pomodoroSession + 1;
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.focus,
        pomodoroSession: nextSession,
        isRunning: false,
        durationLimit: _customFocusDuration,
        elapsedDuration: Duration.zero,
      );
    }
  }

  void handleLifecycleChange(bool resumed) {
    if (!state.isRunning) return;

    if (resumed) {
      final start = state.lastTickTime;
      if (start != null) {
        final now = DateTime.now();
        final delta = now.difference(start);
        final newElapsed = state.elapsedDuration + delta;

        if (state.mode == FocusMode.pomodoro &&
            newElapsed >= state.durationLimit) {
          // Timer finished in background
          state = state.copyWith(
            elapsedDuration: state.durationLimit,
            lastTickTime: now,
          );
          _sessionCompleted();
        } else {
          state = state.copyWith(
            elapsedDuration: newElapsed,
            lastTickTime: now,
          );
          _startTimer();
        }
      }
    } else {
      _timer?.cancel();
      state = state.copyWith(lastTickTime: DateTime.now());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final newElapsed = state.elapsedDuration + const Duration(seconds: 1);

      if (state.mode == FocusMode.pomodoro &&
          newElapsed >= state.durationLimit) {
        state = state.copyWith(
          elapsedDuration: state.durationLimit,
          lastTickTime: now,
        );
        _sessionCompleted();
      } else {
        state = state.copyWith(elapsedDuration: newElapsed, lastTickTime: now);
      }
    });
  }

  void _sessionCompleted() {
    _timer?.cancel();
    final start =
        state.sessionStart ?? DateTime.now().subtract(state.durationLimit);
    final now = DateTime.now();

    // Only save if completed session was Focus, not Break
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      ref
          .read(pomodoroRepositoryProvider)
          .add(
            PomodoroSessionsCompanion.insert(
              startTime: start,
              endTime: now,
              durationMinutes: state.durationLimit.inMinutes,
              mode: 'pomodoro',
            ),
          );
    }

    // Switch next phase
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.breakPhase,
        pomodoroSession: state.pomodoroSession,
        isRunning: false,
        durationLimit: _customBreakDuration,
        elapsedDuration: Duration.zero,
      );
    } else {
      final nextSession = state.pomodoroSession >= 4
          ? 1
          : state.pomodoroSession + 1;
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.focus,
        pomodoroSession: nextSession,
        isRunning: false,
        durationLimit: _customFocusDuration,
        elapsedDuration: Duration.zero,
      );
    }
  }
}
