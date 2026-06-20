import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pomodoro_view_model.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isResumed = state == AppLifecycleState.resumed;
    ref.read(pomodoroViewModelProvider.notifier).handleLifecycleChange(isResumed);
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _showSettingsBottomSheet() {
    final notifier = ref.read(pomodoroViewModelProvider.notifier);
    int selectedFocus = notifier.customFocusMins;
    int selectedBreak = notifier.customBreakMins;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text('Focus Duration: $selectedFocus mins'),
                  Slider(
                    value: selectedFocus.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (val) {
                      setModalState(() {
                        selectedFocus = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Break Duration: $selectedBreak mins'),
                  Slider(
                    value: selectedBreak.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (val) {
                      setModalState(() {
                        selectedBreak = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(pomodoroViewModelProvider.notifier)
                            .updateCustomDurations(
                              focusMins: selectedFocus,
                              breakMins: selectedBreak,
                            );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroViewModelProvider);
    final notifier = ref.read(pomodoroViewModelProvider.notifier);

    final total = timerState.durationLimit.inSeconds;
    final elapsed = timerState.elapsedDuration.inSeconds;
    final progress = total > 0 ? elapsed / total : 0.0;

    String modeLabel = '';
    Color themeColor = Theme.of(context).colorScheme.primary;

    switch (timerState.mode) {
      case PomodoroMode.focus:
        modeLabel = 'Focus Session';
        themeColor = Colors.redAccent;
        break;
      case PomodoroMode.shortBreak:
        modeLabel = 'Short Break';
        themeColor = Colors.green;
        break;
      case PomodoroMode.open:
        modeLabel = 'Stopwatch Mode';
        themeColor = Colors.blue;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsBottomSheet,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Segmented controls for Mode Selection
              SegmentedButton<PomodoroMode>(
                segments: const [
                  ButtonSegment(
                    value: PomodoroMode.focus,
                    label: Text('Focus'),
                    icon: Icon(Icons.work_outline),
                  ),
                  ButtonSegment(
                    value: PomodoroMode.shortBreak,
                    label: Text('Break'),
                    icon: Icon(Icons.coffee_outlined),
                  ),
                  ButtonSegment(
                    value: PomodoroMode.open,
                    label: Text('Stopwatch'),
                    icon: Icon(Icons.timer_outlined),
                  ),
                ],
                selected: {timerState.mode},
                onSelectionChanged: (selection) {
                  notifier.setMode(selection.first);
                },
              ),
              const SizedBox(height: 48),
              // Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: timerState.mode == PomodoroMode.open
                          ? null // Indeterminate spin or empty progress for count up
                          : 1.0 - progress, // Countdown visual
                      strokeWidth: 10,
                      backgroundColor: themeColor.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(timerState.mode == PomodoroMode.open
                            ? timerState.elapsedDuration
                            : (timerState.durationLimit - timerState.elapsedDuration)),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        modeLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (timerState.isRunning)
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.pause),
                      onPressed: () => notifier.pauseSession(),
                    )
                  else
                    IconButton.filled(
                      iconSize: 32,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => notifier.startSession(),
                    ),
                  const SizedBox(width: 24),
                  if (timerState.elapsedDuration > Duration.zero || timerState.isRunning)
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.stop),
                      onPressed: () => notifier.stopSession(),
                    ),
                  if (timerState.mode != PomodoroMode.open && timerState.isRunning) ...[
                    const SizedBox(width: 24),
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => notifier.skipSession(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
