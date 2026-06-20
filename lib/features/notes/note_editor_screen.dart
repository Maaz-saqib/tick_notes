import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'notes_view_model.dart';
import 'notes_repository.dart';
import '../../core/database/app_database.dart';
import '../../Utilities/Generics/get_arguments.dart';
import '../../Utilities/Dialog/cannot_share_empty_note_dialog.dart';

Color getNoteColor(BuildContext context, int colorTag) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  switch (colorTag) {
    case 1:
      return isDark ? const Color(0xFF421D1D) : const Color(0xFFFFEBEE); // Soft Red
    case 2:
      return isDark ? const Color(0xFF422D1D) : const Color(0xFFFFF3E0); // Soft Orange
    case 3:
      return isDark ? const Color(0xFF423D1D) : const Color(0xFFFFFDE7); // Soft Yellow
    case 4:
      return isDark ? const Color(0xFF1D4222) : const Color(0xFFE8F5E9); // Soft Green
    case 5:
      return isDark ? const Color(0xFF1D2E42) : const Color(0xFFE3F2FD); // Soft Blue
    case 6:
      return isDark ? const Color(0xFF331D42) : const Color(0xFFF3E5F5); // Soft Purple
    default:
      return Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3); // Default
  }
}

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
    final scaffoldBgColor = _note != null
        ? getNoteColor(context, _note!.colorTag)
        : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final text = '${_titleController.text}\n\n${_bodyController.text}'.trim();
              if (text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                await SharePlus.instance.share(ShareParams(text: text));
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color Tag',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final color = getNoteColor(context, index);
                    final isSelected = (_note?.colorTag ?? 0) == index;
                    return GestureDetector(
                      onTap: () {
                        if (_note == null) return;
                        setState(() {
                          _note = _note!.copyWith(colorTag: index);
                        });
                        ref.read(notesViewModelProvider.notifier).updateNoteContent(
                          _note!.id,
                          _titleController.text,
                          _bodyController.text,
                          index,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
