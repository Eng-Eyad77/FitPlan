import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';

/// GET /api/stats/volume: the lifetime volume and its milestones (Phase 10).
class VolumeStats {
  const VolumeStats({required this.totalVolumeKg, required this.milestones});

  /// reps × weight of every set in every finished workout. Bodyweight sets count as 0.
  final double totalVolumeKg;

  /// Smallest first. Only the ones the app knows, so an older app ignores new keys.
  final List<ReachedMilestone> milestones;

  factory VolumeStats.fromJson(Map<String, dynamic> json) => VolumeStats(
    totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
    milestones: [
      for (final item in json['milestones'] as List<dynamic>)
        if (Milestone.byKey((item as Map<String, dynamic>)['key'] as String) case final milestone?)
          ReachedMilestone(
            milestone: milestone,
            reachedAt: switch (item['reachedAt']) {
              final String at => DateTime.parse(at),
              _ => null,
            },
          ),
    ],
  );

  /// The first one not reached yet, or null when all are.
  ReachedMilestone? get next => milestones.where((m) => m.reachedAt == null).firstOrNull;

  /// The total as a share of [next] (0 to 1), 1 when all are reached.
  double get progressToNext {
    final target = next?.milestone.weightKg;
    if (target == null) return 1;
    return (totalVolumeKg / target).clamp(0, 1);
  }
}

class ReachedMilestone {
  const ReachedMilestone({required this.milestone, this.reachedAt});

  final Milestone milestone;

  /// Null = not reached yet. Once reached it stays, even after a workout is deleted.
  final DateTime? reachedAt;
}

/// What the icon of a milestone shows.
enum MilestoneArt { piano, car, elephant, bus, truck, whale, jet }

/// The objects the volume is compared with. The weights are approximate and sourced
/// (docs/PHASE-10-PROPOSAL.md); the server has the same keys and thresholds.
class Milestone {
  const Milestone(this.key, this.weightKg, this.art);

  final String key;

  /// Also the threshold that unlocks it.
  final double weightKg;

  final MilestoneArt art;

  static const all = [
    Milestone('grand-piano', 500, MilestoneArt.piano),
    Milestone('small-car', 1000, MilestoneArt.car),
    Milestone('elephant', 6000, MilestoneArt.elephant),
    Milestone('city-bus', 12000, MilestoneArt.bus),
    Milestone('loaded-truck', 40000, MilestoneArt.truck),
    Milestone('blue-whale', 150000, MilestoneArt.whale),
    // the London Eye (2,100 t) and the Eiffel Tower (10,100 t) were dropped: years out of reach (2026-11-25)
    Milestone('jumbo-jet', 450000, MilestoneArt.jet),
  ];

  /// "a small car", "سيارة صغيرة"
  String get name => switch (key) {
        'grand-piano' => l10n.msPiano,
        'small-car' => l10n.msCar,
        'elephant' => l10n.msElephant,
        'city-bus' => l10n.msBus,
        'loaded-truck' => l10n.msTruck,
        'blue-whale' => l10n.msWhale,
        _ => l10n.msJet,
      };

  /// "small cars", "سيارات صغيرة"
  String get plural => switch (key) {
        'grand-piano' => l10n.msPianoPlural,
        'small-car' => l10n.msCarPlural,
        'elephant' => l10n.msElephantPlural,
        'city-bus' => l10n.msBusPlural,
        'loaded-truck' => l10n.msTruckPlural,
        'blue-whale' => l10n.msWhalePlural,
        _ => l10n.msJetPlural,
      };

  static Milestone? byKey(String key) => all.where((m) => m.key == key).firstOrNull;

  /// "A small car"
  String get title => isArabic ? name : '${name[0].toUpperCase()}${name.substring(1)}';

  /// The biggest object [kg] reaches, or null under the smallest one.
  static Milestone? biggestWithin(double kg) => all.where((m) => m.weightKg <= kg).lastOrNull;

  /// "About 1.4 elephants", "About 6 small cars", "About a small car". Null under the smallest object.
  /// One decimal under 10, whole numbers above it: never a fake precision.
  static String? compare(double kg) {
    final object = biggestWithin(kg);
    if (object == null) return null;
    final times = kg / object.weightKg;
    final count = times < 10 ? NumberFormat('0.#').format(times) : NumberFormat.decimalPattern().format(times.floor());
    if (count == '1') return l10n.aboutOne(object.name);
    // Arabic counts a fraction or 11 and up with the singular ("1.4 فيل", "15 فيل"), 2 to 10 with the plural
    final whole = times < 10 ? times == times.roundToDouble() : true;
    final useSingular = isArabic && (!whole || times >= 11);
    return l10n.aboutMany(count, useSingular ? object.name : object.plural);
  }
}

/// 840 -> ("840", "kg"), 8420 -> ("8.4", "t"), 2100000 -> ("2,100", "t"). Tonnes from 1 t, so
/// 6 t and 12 t read as the same unit.
(String, String) volumeParts(double kg) => kg < 1000
    ? (NumberFormat.decimalPattern().format(kg.round()), l10n.kg)
    : (NumberFormat('#,##0.#').format(kg / 1000), l10n.tonnes(kg / 1000));

/// "3,580 kg", "27.6 t"
String formatVolumeAmount(double kg) {
  final (number, unit) = volumeParts(kg);
  return '$number $unit';
}
