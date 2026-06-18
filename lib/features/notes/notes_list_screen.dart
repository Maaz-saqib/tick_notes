import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:practice_app/Services/Auth/bloc/auth_bloc.dart';
import 'package:practice_app/Services/Auth/bloc/auth_event.dart';
import 'package:practice_app/core/theme/theme_notifier.dart';
import 'notes_view_model.dart';
import '../../core/database/app_database.dart';
import '../../Constants/Routes.dart';
import '../../Enums/MenuActions.dart';
import '../../Utilities/Dialog/LogOut_dialog.dart';
import '../../Utilities/Dialog/delete_dialog.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesViewModelProvider);
    final themeSettings = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          // Theme mode toggle button
          IconButton(
            icon: Icon(
              themeSettings.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final newMode = themeSettings.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeNotifierProvider.notifier).setThemeMode(newMode);
            },
            tooltip: 'Toggle Theme',
          ),
          // Seed color changer popup menu
          PopupMenuButton<Color>(
            icon: const Icon(Icons.palette),
            onSelected: (color) {
              ref.read(themeNotifierProvider.notifier).setSeedColor(color);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Colors.deepPurple,
                child: Text('Purple (Default)'),
              ),
              const PopupMenuItem(
                value: Colors.blue,
                child: Text('Blue'),
              ),
              const PopupMenuItem(
                value: Colors.teal,
                child: Text('Teal'),
              ),
              const PopupMenuItem(
                value: Colors.orange,
                child: Text('Orange'),
              ),
              const PopupMenuItem(
                value: Colors.red,
                child: Text('Red'),
              ),
            ],
            tooltip: 'Change Seed Color',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // Trigger the BLoC event for logout
                    bloc.BlocProvider.of<AuthBloc>(context).add(
                      const AuthEventLogOut(),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          )
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet. Click the "+" button to add one!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    createOrUpdateNoteRoute,
                    arguments: note,
                  );
                },
                title: Text(
                  note.title.isNotEmpty ? note.title : 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  note.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      await ref.read(notesViewModelProvider.notifier).deleteNote(note.id);
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }
}
