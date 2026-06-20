import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'pomodoro_repository.dart';
import '../../core/database/app_database.dart';
import '../../core/notifications/notification_service.dart';

part 'pomodoro_view_model.g.dart';

enum PomodoroMode { focus, shortBreak, open }

class PomodoroState {
  final PomodoroMode mode;
  final bool isRunning;
  final Duration durationLimit;
  final Duration elapsedDuration;
  final DateTime? sessionStart;
  final DateTime? lastTickTime;

  const PomodoroState({
    required this.mode,
    required this.isRunning,
    required this.durationLimit,
    required this.elapsedDuration,
    this.sessionStart,
    this.lastTickTime,
  });

  PomodoroState copyWith({
    PomodoroMode? mode,
    bool? isRunning,
    Duration? durationLimit,
    Duration? elapsedDuration,
    DateTime? sessionStart,
    DateTime? lastTickTime,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
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
      mode: PomodoroMode.focus,
      isRunning: false,
      durationLimit: _customFocusDuration,
      elapsedDuration: Duration.zero,
    );
  }

  void updateCustomDurations({required int focusMins, required int breakMins}) {
    _customFocusDuration = Duration(minutes: focusMins);
    _customBreakDuration = Duration(minutes: breakMins);
    if (!state.isRunning) {
      if (state.mode == PomodoroMode.focus) {
        state = state.copyWith(durationLimit: _customFocusDuration);
      } else if (state.mode == PomodoroMode.shortBreak) {
        state = state.copyWith(durationLimit: _customBreakDuration);
      }
    }
  }

  int get customFocusMins => _customFocusDuration.inMinutes;
  int get customBreakMins => _customBreakDuration.inMinutes;

  void setMode(PomodoroMode mode) {
    if (state.isRunning) {
      stopSession();
    }
    Duration limit = Duration.zero;
    if (mode == PomodoroMode.focus) {
      limit = _customFocusDuration;
    } else if (mode == PomodoroMode.shortBreak) {
      limit = _customBreakDuration;
    }
    state = PomodoroState(
      mode: mode,
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

    // Schedule notification for background if we are not in open stopwatch mode
    if (state.mode != PomodoroMode.open) {
      final remaining = state.durationLimit - state.elapsedDuration;
      final scheduledTime = now.add(remaining);
      NotificationService.instance.scheduleNotification(
        id: 9999, // Static ID for Pomodoro reminders
        title: 'Pomodoro Timer Done',
        body: state.mode == PomodoroMode.focus
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
      if (elapsedMins > 0 || state.elapsedDuration.inSeconds >= 10) {
        // Save to DB
        ref.read(pomodoroRepositoryProvider).add(
          PomodoroSessionsCompanion.insert(
            startTime: start,
            endTime: now,
            durationMinutes: elapsedMins > 0 ? elapsedMins : 1,
            mode: state.mode.name,
          ),
        );
      }
    }

    Duration limit = Duration.zero;
    if (state.mode == PomodoroMode.focus) {
      limit = _customFocusDuration;
    } else if (state.mode == PomodoroMode.shortBreak) {
      limit = _customBreakDuration;
    }

    state = PomodoroState(
      mode: state.mode,
      isRunning: false,
      durationLimit: limit,
      elapsedDuration: Duration.zero,
    );
  }

  void skipSession() {
    stopSession(forceSave: false);
    // Cycle modes focus <-> break
    if (state.mode == PomodoroMode.focus) {
      setMode(PomodoroMode.shortBreak);
    } else if (state.mode == PomodoroMode.shortBreak) {
      setMode(PomodoroMode.focus);
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

        if (state.mode != PomodoroMode.open && newElapsed >= state.durationLimit) {
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

      if (state.mode != PomodoroMode.open && newElapsed >= state.durationLimit) {
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
      }
    });
  }

  void _sessionCompleted() {
    _timer?.cancel();
    final start = state.sessionStart ?? DateTime.now().subtract(state.durationLimit);
    final now = DateTime.now();

    ref.read(pomodoroRepositoryProvider).add(
      PomodoroSessionsCompanion.insert(
        startTime: start,
        endTime: now,
        durationMinutes: state.durationLimit.inMinutes,
        mode: state.mode.name,
      ),
    );

    // Switch to next mode
    final nextMode = state.mode == PomodoroMode.focus
        ? PomodoroMode.shortBreak
        : PomodoroMode.focus;

    Duration nextLimit = nextMode == PomodoroMode.focus
        ? _customFocusDuration
        : _customBreakDuration;

    state = PomodoroState(
      mode: nextMode,
      isRunning: false,
      durationLimit: nextLimit,
      elapsedDuration: Duration.zero,
    );
  }
}
