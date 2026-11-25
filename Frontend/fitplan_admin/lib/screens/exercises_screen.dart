import 'dart:async';

import 'package:fitplan_shared/fitplan_shared.dart';
import 'package:flutter/material.dart';

import '../core/admin_api.dart';
import 'widgets.dart';

/// 12C: fix exercise text in both languages, hide or show exercises, and check their GIF links.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key, required this.api});

  final AdminApi api;

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _filter = 'all';
  int _page = 1;
  late Future<ExercisePage> _list = _load();
  String? _selected;

  // the whole-library link check, run in batches while this screen is open
  int? _checkDone;
  int? _checkTotal;

  Future<ExercisePage> _load() => widget.api.exercises(search: _search.text.trim(), filter: _filter, page: _page);

  void _reload({bool firstPage = false}) => setState(() {
        if (firstPage) _page = 1;
        _list = _load();
      });

  Future<void> _checkAll() async {
    setState(() => _checkDone = 0);
    var offset = 0;
    var broken = 0;
    try {
      while (mounted) {
        final batch = await widget.api.checkGifBatch(offset);
        offset = batch.nextOffset;
        broken += batch.broken;
        if (!mounted) return;
        setState(() {
          _checkDone = offset;
          _checkTotal = batch.total;
        });
        if (offset >= batch.total) break;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checked every link. $broken are broken.')));
    } on AdminApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The check stopped at $offset: ${e.message}')));
    } finally {
      if (mounted) {
        setState(() => _checkDone = null);
        _reload();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1200;
    final checking = _checkDone != null;
    final list = Panel(
      title: 'Exercises',
      trailing: checking
          ? Text('Checking links ${_checkDone ?? 0} of ${_checkTotal ?? '…'}', style: AppText.caption)
          : TextButton(onPressed: _checkAll, child: const Text('Check all links')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (checking)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: LinearProgressIndicator(value: _checkTotal == null ? null : _checkDone! / _checkTotal!),
            ),
          TextField(
            controller: _search,
            decoration: const InputDecoration(hintText: 'Search in English or Arabic, or by id', prefixIcon: Icon(Icons.search), isDense: true),
            onChanged: (_) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () => _reload(firstPage: true));
            },
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder(
            future: _list,
            builder: (context, snapshot) {
              if (snapshot.hasError) return ErrorRetry(error: snapshot.error!, onRetry: _reload);
              final page = snapshot.data;
              if (page == null) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final (value, key, label) in const [
                        ('all', 'all', 'All'),
                        ('no-demo', 'noDemo', 'No demo'),
                        ('not-checked', 'notChecked', 'Not checked'),
                        ('hidden', 'hidden', 'Hidden'),
                      ])
                        ChoiceChip(
                          label: Text('$label ${page.counts[key] ?? 0}'),
                          selected: _filter == value,
                          onSelected: (_) {
                            _filter = value;
                            _reload(firstPage: true);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (page.items.isEmpty) const Text('No exercises match.', style: AppText.secondary),
                  for (final exercise in page.items)
                    _ExerciseTile(exercise: exercise, selected: exercise.id == _selected, onTap: () => setState(() => _selected = exercise.id)),
                  if (page.totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: page.page > 1
                              ? () => setState(() {
                                    _page--;
                                    _list = _load();
                                  })
                              : null,
                          child: const Text('Previous'),
                        ),
                        Text('Page ${page.page} of ${page.totalPages}', style: AppText.caption),
                        TextButton(
                          onPressed: page.page < page.totalPages
                              ? () => setState(() {
                                    _page++;
                                    _list = _load();
                                  })
                              : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );

    final editor = _selected == null
        ? const Panel(title: 'Exercise', child: Text('Pick an exercise to edit it.', style: AppText.secondary))
        : _ExerciseEditor(key: ValueKey(_selected), api: widget.api, id: _selected!, onChanged: _reload);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(flex: 2, child: list), const SizedBox(width: AppSpacing.lg), Expanded(flex: 3, child: editor)],
            )
          : Column(children: [list, const SizedBox(height: AppSpacing.lg), editor]),
    );
  }
}

Widget _gifPill(String? status) => switch (status) {
      'Works' => const Pill('Demo works'),
      'Missing' || 'NotAGif' => const Pill('No demo', color: AppColors.danger),
      'Unreachable' => const Pill('No answer', color: AppColors.success),
      _ => const Pill('Not checked', color: AppColors.textTertiary),
    };

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.selected, required this.onTap});

  final ExerciseRow exercise;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface2 : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: AppText.body, overflow: TextOverflow.ellipsis),
                    Text(
                      exercise.arabicName ?? 'No Arabic name',
                      style: AppText.caption,
                      textDirection: TextDirection.rtl,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(exercise.bodyPart, style: AppText.caption),
              const SizedBox(width: AppSpacing.sm),
              if (exercise.hidden) ...[const Pill('Hidden', color: AppColors.textSecondary), const SizedBox(width: 4)],
              _gifPill(exercise.gifStatus),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseEditor extends StatefulWidget {
  const _ExerciseEditor({super.key, required this.api, required this.id, required this.onChanged});

  final AdminApi api;
  final String id;
  final VoidCallback onChanged;

  @override
  State<_ExerciseEditor> createState() => _ExerciseEditorState();
}

class _ExerciseEditorState extends State<_ExerciseEditor> {
  late Future<ExerciseDetail> _detail = _open();
  final _englishName = TextEditingController();
  final _englishSteps = TextEditingController();
  final _arabicName = TextEditingController();
  final _arabicSteps = TextEditingController();
  bool _busy = false;

  Future<ExerciseDetail> _open() async {
    final detail = await widget.api.exercise(widget.id);
    _englishName.text = detail.englishName;
    _englishSteps.text = detail.englishSteps.join('\n');
    _arabicName.text = detail.arabicName ?? '';
    _arabicSteps.text = detail.arabicSteps.join('\n');
    return detail;
  }

  @override
  void dispose() {
    for (final c in [_englishName, _englishSteps, _arabicName, _arabicSteps]) {
      c.dispose();
    }
    super.dispose();
  }

  static List<String> _lines(String text) => [for (final l in text.split('\n')) if (l.trim().isNotEmpty) l.trim()];

  Future<void> _run(String done, Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      setState(() {
        _detail = _open();
      });
      widget.onChanged();
    } on AdminApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _save() {
    final english = _lines(_englishSteps.text);
    final arabic = _lines(_arabicSteps.text);
    if (_englishName.text.trim().length < 2 || _arabicName.text.trim().length < 2 || english.isEmpty || arabic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill in the name and at least one step in both English and Arabic.')));
      return;
    }
    _run(
      'Saved. The app shows the new text now.',
      () => widget.api.saveExerciseText(widget.id,
          englishName: _englishName.text.trim(), englishSteps: english, arabicName: _arabicName.text.trim(), arabicSteps: arabic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _detail,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Panel(
            title: 'Exercise',
            child: ErrorRetry(error: snapshot.error!, onRetry: () => setState(() { _detail = _open(); })),
          );
        }
        final ex = snapshot.data;
        if (ex == null) {
          return const Panel(title: 'Exercise', child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
        }
        return Panel(
          title: ex.englishName,
          trailing: Text('Used in ${ex.plans} plans, ${ex.workouts} workouts', style: AppText.caption),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Demo(exercise: ex, busy: _busy, onCheck: () => _run('Link checked.', () => widget.api.checkGif(ex.id))),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final english = _Language(
                    nameLabel: 'Name in English',
                    stepsLabel: 'Steps in English, one per line',
                    name: _englishName,
                    steps: _englishSteps,
                    rtl: false,
                  );
                  final arabic = _Language(
                    nameLabel: 'الاسم بالعربي',
                    stepsLabel: 'الخطوات بالعربي، كل خطوة في سطر',
                    name: _arabicName,
                    steps: _arabicSteps,
                    rtl: true,
                  );
                  return constraints.maxWidth >= 560
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Expanded(child: english), const SizedBox(width: AppSpacing.md), Expanded(child: arabic)],
                        )
                      : Column(children: [english, const SizedBox(height: AppSpacing.md), arabic]);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  OutlinedButton(
                    style: ex.hidden ? null : OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                    onPressed: _busy
                        ? null
                        : () => _run(ex.hidden ? 'Shown in the library again.' : 'Hidden from the library. Plans and workouts keep it.',
                            () => widget.api.setExerciseHidden(ex.id, !ex.hidden)),
                    child: Text(ex.hidden ? 'Show in library' : 'Hide from library'),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _busy ? null : _save, child: const Text('Save changes')),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Saving needs both languages. The Arabic text is marked as reviewed, and the change is written to the audit log.',
                style: AppText.caption,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Demo extends StatelessWidget {
  const _Demo({required this.exercise, required this.busy, required this.onCheck});

  final ExerciseDetail exercise;
  final bool busy;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final broken = exercise.gifStatus == 'Missing' || exercise.gifStatus == 'NotAGif';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 96,
              height: 96,
              color: AppColors.surface2,
              alignment: Alignment.center,
              child: broken
                  ? const Text('No demo', style: AppText.caption)
                  : Image.network(
                      exercise.gifUrl,
                      // an <img> tag, so the media host's missing CORS headers don't matter
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Text("Didn't load", style: AppText.caption),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [_gifPill(exercise.gifStatus), const SizedBox(width: AppSpacing.sm), Text(exercise.bodyPart, style: AppText.caption)]),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  broken ? 'The app shows the steps only. Uploading a replacement comes later.' : exercise.gifUrl,
                  style: AppText.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(onPressed: busy ? null : onCheck, child: const Text('Check link again')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Language extends StatelessWidget {
  const _Language({required this.nameLabel, required this.stepsLabel, required this.name, required this.steps, required this.rtl});

  final String nameLabel;
  final String stepsLabel;
  final TextEditingController name;
  final TextEditingController steps;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final direction = rtl ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: name, textDirection: direction, decoration: InputDecoration(labelText: nameLabel, isDense: true)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: steps,
            textDirection: direction,
            minLines: 6,
            maxLines: 12,
            decoration: InputDecoration(labelText: stepsLabel, alignLabelWithHint: true),
          ),
        ],
      ),
    );
  }
}
