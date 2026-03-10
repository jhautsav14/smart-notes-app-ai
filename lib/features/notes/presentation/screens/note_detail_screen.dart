import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/note_model.dart';
import '../providers/notes_provider.dart';
import 'add_edit_note_sheet.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _isSummarizing = false;

  void _showEditSheet(Note note) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddEditNoteSheet(existingNote: note),
    );
  }

  void _confirmDelete() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(widget.noteId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _summarize(Note note) async {
    setState(() => _isSummarizing = true);

    await ref.read(notesProvider.notifier).generateAndSaveSummary(note);

    setState(() => _isSummarizing = false);
  }

  Widget _aiSummaryCard(String summary) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryAction.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryAction.withOpacity(0.25),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              CupertinoIcons.sparkles,
              size: 20,
              color: AppColors.primaryAction,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(Note note) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.85),
            border: const Border(
              top: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _confirmDelete,
                child: const Icon(
                  CupertinoIcons.trash,
                  color: CupertinoColors.destructiveRed,
                  size: 26,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isSummarizing ? null : () => _summarize(note),
                child: Row(
                  children: [
                    if (_isSummarizing)
                      const CupertinoActivityIndicator()
                    else
                      const Icon(
                        CupertinoIcons.sparkles,
                        color: AppColors.primaryAction,
                        size: 22,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isSummarizing ? 'Summarizing...' : 'Summarize',
                      style: const TextStyle(
                        color: AppColors.primaryAction,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    final noteIndex = notesState.notes.indexWhere((n) => n.id == widget.noteId);

    if (noteIndex == -1) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(),
        child: Center(child: Text('Note not found')),
      );
    }

    final note = notesState.notes[noteIndex];

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Notes',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showEditSheet(note),
          child: const Text(
            'Edit',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryAction,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                children: [
                  /// TITLE
                  Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DATE
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.clock,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMMM d, yyyy • h:mm a')
                            .format(note.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  /// AI SUMMARY
                  if (note.aiSummary != null && note.aiSummary!.isNotEmpty) ...[
                    _aiSummaryCard(note.aiSummary!),
                    const SizedBox(height: 28),
                  ],

                  /// CONTENT
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            /// Bottom toolbar
            _bottomBar(note),
          ],
        ),
      ),
    );
  }
}
