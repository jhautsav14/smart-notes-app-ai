import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes_app/features/notes/data/note_model.dart';
import 'package:smart_notes_app/features/notes/presentation/screens/note_detail_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  bool _showSearch = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);

    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(notesProvider.notifier).loadMoreNotes();
    }
  }

  void _onSearchChanged() {
    ref.read(notesSearchQueryProvider.notifier).state = _searchController.text;

    ref.read(notesProvider.notifier).filterNotes();
  }

  void _openNoteDetail(Note note) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => NoteDetailScreen(noteId: note.id),
      ),
    );
  }

  void _showAddEditSheet([note]) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddEditNoteSheet(existingNote: note),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: !_showSearch
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: "Search notes...",
                    style: const TextStyle(color: CupertinoColors.white),
                    backgroundColor: AppColors.card.withOpacity(0.8),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('Smart Notes'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _showSearch = !_showSearch;
                        });
                      },
                      child: const Icon(
                        CupertinoIcons.search,
                        size: 26,
                        color: AppColors.primaryAction,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showAddEditSheet(),
                      child: const Icon(
                        CupertinoIcons.add_circled_solid,
                        size: 28,
                        color: AppColors.primaryAction,
                      ),
                    ),
                  ],
                ),
              ),

              /// Search
              SliverToBoxAdapter(child: _buildSearchBar()),

              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  ref.read(notesProvider.notifier).filterNotes();
                  await Future.delayed(const Duration(seconds: 1));
                },
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == notesState.notes.length) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: notesState.isLoadingMore
                              ? const CupertinoActivityIndicator(radius: 12)
                              : const SizedBox(),
                        ),
                      );
                    }

                    final note = notesState.notes[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Dismissible(
                        key: ValueKey(note.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          ref.read(notesProvider.notifier).deleteNote(note.id);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.destructiveRed,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            CupertinoIcons.delete,
                            color: CupertinoColors.white,
                          ),
                        ),
                        child: NoteCard(
                          note: note,
                          onTap: () => _openNoteDetail(note),
                        ),
                      ),
                    );
                  },
                  childCount: notesState.notes.length +
                      (notesState.isLoadingMore ? 1 : 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
