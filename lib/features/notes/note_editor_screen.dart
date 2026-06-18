import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'notes_view_model.dart';
import 'notes_repository.dart';
import '../../core/database/app_database.dart';
import '../../Utilities/Generics/get_arguments.dart';
import '../../Utilities/Dialog/cannot_share_empty_note_dialog.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  Note? _note;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isInitialized = false;

  @override
  void initState() {
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _removeListeners();
    _saveOrDeleteNote();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveOrDeleteNote() {
    final note = _note;
    if (note == null) return;

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ref.read(notesViewModelProvider.notifier).deleteNote(note.id);
    } else {
      ref.read(notesViewModelProvider.notifier).updateNoteContent(
            note.id,
            title,
            body,
            note.colorTag,
          );
    }
  }

  void _setupListeners() {
    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onTextChanged);
  }

  void _removeListeners() {
    _titleController.removeListener(_onTextChanged);
    _bodyController.removeListener(_onTextChanged);
  }

  void _onTextChanged() {
    final note = _note;
    if (note == null) return;
    ref.read(notesViewModelProvider.notifier).updateNoteContent(
          note.id,
          _titleController.text,
          _bodyController.text,
          note.colorTag,
        );
  }

  Future<Note> _createOrGetExistingNote() async {
    if (_isInitialized) {
      return _note!;
    }

    final widgetNote = context.getArgument<Note>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _bodyController.text = widgetNote.body;
      _isInitialized = true;
      _setupListeners();
      return widgetNote;
    }

    // Creating a new note locally
    final newId = await ref.read(notesViewModelProvider.notifier).addNote('', '', 0);
    final newNote = await ref.read(notesRepositoryProvider).getNote(newId);
    _note = newNote;
    _isInitialized = true;
    _setupListeners();
    return newNote!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = '${_titleController.text}\n\n${_bodyController.text}'.trim();
              if (text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder<Note>(
        future: _createOrGetExistingNote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(),
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Start typing your note...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
