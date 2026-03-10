import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_notes_app/core/network/ai_service.dart';
import 'package:uuid/uuid.dart';
import '../../data/note_model.dart';

final aiServiceProvider = Provider((ref) => AIService());

final notesSearchQueryProvider = StateProvider<String>((ref) => '');

class NotesState {
  final List<Note> notes;
  final bool isLoadingMore;
  final bool hasReachedMax;

  NotesState(
      {this.notes = const [],
      this.isLoadingMore = false,
      this.hasReachedMax = false});

  NotesState copyWith(
      {List<Note>? notes, bool? isLoadingMore, bool? hasReachedMax}) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class NotesNotifier extends Notifier<NotesState> {
  late Box<Note> _notesBox;
  final int _pageSize = 15;
  int _currentPage = 1;

  @override
  NotesState build() {
    _notesBox = Hive.box<Note>('notesBox');

    _notesBox.listenable().addListener(() {
      _loadInitialNotes();
    });

    _currentPage = 1;

    final allNotes = _getSortedNotes();
    final initialNotes = allNotes.take(_pageSize).toList();

    return NotesState(
      notes: initialNotes,
      hasReachedMax: initialNotes.length == allNotes.length,
    );
  }

  void _loadInitialNotes() {
    _currentPage = 1;
    final allNotes = _getSortedNotes();
    final initialNotes = allNotes.take(_pageSize).toList();
    state = NotesState(
      notes: initialNotes,
      hasReachedMax: initialNotes.length == allNotes.length,
    );
  }

  Future<void> loadMoreNotes() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true);
    await Future.delayed(const Duration(
        milliseconds: 300)); // Simulate slight delay for smoothness

    _currentPage++;
    final allNotes = _getSortedNotes();
    final nextCount = _currentPage * _pageSize;

    final nextNotes = allNotes.take(nextCount).toList();
    state = state.copyWith(
      notes: nextNotes,
      isLoadingMore: false,
      hasReachedMax: nextNotes.length >= allNotes.length,
    );
  }

  List<Note> _getSortedNotes() {
    final query = ref.read(notesSearchQueryProvider).toLowerCase();
    List<Note> notes = _notesBox.values.toList();

    if (query.isNotEmpty) {
      notes = notes
          .where((n) =>
              n.title.toLowerCase().contains(query) ||
              n.content.toLowerCase().contains(query))
          .toList();
    }

    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  void filterNotes() {
    _loadInitialNotes(); // Reset pagination on search
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    await _notesBox.put(note.id, note);
    _loadInitialNotes();
  }

  Future<void> updateNote(Note updatedNote) async {
    await _notesBox.put(updatedNote.id, updatedNote);
    _loadInitialNotes();
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
    _loadInitialNotes();
  }

  Future<void> generateAndSaveSummary(Note note) async {
    if (note.content.isEmpty) return;

    // Uses your working AIService
    final summary = await AIService.askAI(note.content);

    if (summary != null) {
      final updatedNote = note.copyWith(aiSummary: summary);
      await updateNote(updatedNote); // Saves to Hive and refreshes UI
    }
  }

  Future<String?> summarizeNoteContent(String content) async {
    if (content.isEmpty) return null;

    // Call your new static method directly!
    return await AIService.askAI(content);
  }
}

final notesProvider =
    NotifierProvider<NotesNotifier, NotesState>(NotesNotifier.new);
