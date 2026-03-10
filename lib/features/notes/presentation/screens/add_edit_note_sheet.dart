import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/note_model.dart';
import '../providers/notes_provider.dart';

class AddEditNoteSheet extends ConsumerStatefulWidget {
  final Note? existingNote;

  const AddEditNoteSheet({super.key, this.existingNote});

  @override
  ConsumerState<AddEditNoteSheet> createState() => _AddEditNoteSheetState();
}

class _AddEditNoteSheetState extends ConsumerState<AddEditNoteSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool _isSummarizing = false;
  String? _aiSummary;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.existingNote?.title ?? '');

    _contentController =
        TextEditingController(text: widget.existingNote?.content ?? '');

    _aiSummary = widget.existingNote?.aiSummary;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    if (widget.existingNote == null) {
      ref.read(notesProvider.notifier).addNote(title, content);
    } else {
      final updatedNote = widget.existingNote!.copyWith(
        title: title,
        content: content,
        aiSummary: _aiSummary,
      );

      ref.read(notesProvider.notifier).updateNote(updatedNote);
    }

    Navigator.of(context).pop();
  }

  Future<void> _summarize() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isSummarizing = true);

    final summary = await ref
        .read(notesProvider.notifier)
        .summarizeNoteContent(_contentController.text);

    if (summary != null) {
      setState(() => _aiSummary = summary);
    }

    setState(() => _isSummarizing = false);
  }

  Widget _aiSummaryCard() {
    if (_aiSummary == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryAction.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryAction.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.sparkles,
            size: 18,
            color: AppColors.primaryAction,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _aiSummary!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomToolbar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.9),
            border: const Border(
              top: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isSummarizing ? null : _summarize,
                  child: Row(
                    children: [
                      if (_isSummarizing)
                        const CupertinoActivityIndicator()
                      else
                        const Icon(
                          CupertinoIcons.sparkles,
                          color: AppColors.primaryAction,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isSummarizing ? 'Summarizing...' : 'Summarize with AI',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          CupertinoNavigationBar(
            backgroundColor: AppColors.background,
            border: null,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            middle: Text(
              widget.existingNote == null ? 'New Note' : 'Edit Note',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveNote,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAction,
                ),
              ),
            ),
          ),

          Expanded(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  /// TITLE FIELD
                  CupertinoTextField(
                    controller: _titleController,
                    placeholder: 'Title',
                    placeholderStyle: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: null,
                    maxLines: 1,
                  ),

                  const SizedBox(height: 20),

                  /// AI SUMMARY
                  if (_aiSummary != null) _aiSummaryCard(),

                  if (_aiSummary != null) const SizedBox(height: 20),

                  /// CONTENT FIELD
                  CupertinoTextField(
                    controller: _contentController,
                    placeholder: 'Start typing your thoughts...',
                    placeholderStyle: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                    decoration: null,
                    maxLines: null,
                    minLines: 12,
                  ),
                ],
              ),
            ),
          ),

          /// Bottom toolbar
          _bottomToolbar(),
        ],
      ),
    );
  }
}
