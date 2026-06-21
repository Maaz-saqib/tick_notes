import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database_provider.dart';
import '../database/app_database.dart';

part 'theme_notifier.g.dart';

class ThemeSettingsState {
  final ThemeMode themeMode;
  final Color seedColor;

  const ThemeSettingsState({
    required this.themeMode,
    required this.seedColor,
  });

  ThemeSettingsState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
  }) {
    return ThemeSettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _seedColorKey = 'seed_color';
  static const _defaultColor = Colors.blue;

  @override
  ThemeSettingsState build() {
    // Start loading settings from database
    _loadSettings();

    return const ThemeSettingsState(
      themeMode: ThemeMode.system,
      seedColor: _defaultColor,
    );
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    try {
      final modeRow = await (db.select(db.settings)..where((tbl) => tbl.key.equals(_themeModeKey))).getSingleOrNull();
      final colorRow = await (db.select(db.settings)..where((tbl) => tbl.key.equals(_seedColorKey))).getSingleOrNull();

      ThemeMode mode = ThemeMode.system;
      if (modeRow != null && modeRow.value != null) {
        mode = ThemeMode.values.firstWhere(
          (e) => e.name == modeRow.value,
          orElse: () => ThemeMode.system,
        );
      }

      Color color = _defaultColor;
      if (colorRow != null && colorRow.value != null) {
        final intValue = int.tryParse(colorRow.value!);
        if (intValue != null) {
          color = Color(intValue);
        }
      }

      state = ThemeSettingsState(themeMode: mode, seedColor: color);
    } catch (e) {
      // Fail silently, fallback to default state
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final db = ref.read(databaseProvider);
    await db.into(db.settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: const drift.Value(_themeModeKey),
        value: drift.Value(mode.name),
      ),
    );
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final db = ref.read(databaseProvider);
    await db.into(db.settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: const drift.Value(_seedColorKey),
        value: drift.Value(color.value.toString()),
      ),
    );
  }
}
