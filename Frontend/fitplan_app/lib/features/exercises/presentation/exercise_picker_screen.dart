import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/feedback.dart';
import '../data/exercises_repository.dart';
import '../domain/exercise.dart';
import 'widgets/exercise_thumb.dart';

/// Search the library and pick one exercise. Pops with the chosen [Exercise].
/// [excludedIds] are already in the plan/session: shown as added, not selectable.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key, this.excludedIds = const {}});

  final Set<String> excludedIds;

  @override
  ConsumerState<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  String? _bodyPart;
  final _items = <Exercise>[];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  /// Ignores answers of older searches that arrive late.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) _loadMore();
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _reload);
  }

  void _reload() {
    _requestId++;
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _loading = false;
      _error = null;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    final requestId = _requestId;
    setState(() => _loading = true);

    try {
      final page = await ref.read(exercisesRepositoryProvider).getPage(
            page: _page + 1,
            bodyPart: _bodyPart,
            search: _search.text,
          );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items.addAll(page.items);
        _page = page.page;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _pick(Exercise exercise) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add exercise', style: AppText.heading)),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.screen,
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
                suffixIcon: ListenableBuilder(
                  listenable: _search,
                  builder: (_, _) => _search.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            _reload();
                          },
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screen,
              children: [
                _BodyPartChip(
                  label: 'All',
                  selected: _bodyPart == null,
                  onTap: () {
                    _bodyPart = null;
                    _reload();
                  },
                ),
                for (final part in bodyParts)
                  _BodyPartChip(
                    label: capitalize(part),
                    selected: _bodyPart == part,
                    onTap: () {
                      _bodyPart = _bodyPart == part ? null : part;
                      _reload();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      if (_error != null) {
        return LoadError(message: errorMessage(_error!, 'Could not load exercises.'), onRetry: _reload);
      }
      if (_loading || _hasMore) return const Center(child: CircularProgressIndicator());
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No exercises found',
        message: 'Try another word or body part.',
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: AppSpacing.screen.copyWith(top: AppSpacing.sm, bottom: AppSpacing.xxl),
      itemCount: _items.length + (_hasMore || _error != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: _error != null
                  ? TextButton(onPressed: _loadMore, child: const Text('Load more'))
                  : const CircularProgressIndicator(),
            ),
          );
        }
        final exercise = _items[index];
        final added = widget.excludedIds.contains(exercise.id);
        return _ExerciseRow(
          exercise: exercise,
          added: added,
          onTap: added ? null : () => _pick(exercise),
        );
      },
    );
  }
}

class _BodyPartChip extends StatelessWidget {
  const _BodyPartChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: AppText.secondary.copyWith(
          color: selected ? AppColors.onAccent : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        selectedColor: AppColors.accent,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, required this.added, required this.onTap});

  final Exercise exercise;
  final bool added;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Opacity(
          opacity: added ? 0.5 : 1,
          child: Row(
            children: [
              ExerciseThumb(url: exercise.gifUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalize(exercise.name),
                      style: AppText.bodyStrong,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(capitalize(exercise.bodyPart), style: AppText.caption),
                  ],
                ),
              ),
              Icon(
                added ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                color: added ? AppColors.textTertiary : AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
