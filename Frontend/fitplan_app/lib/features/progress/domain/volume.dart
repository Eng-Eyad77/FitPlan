import 'package:intl/intl.dart';

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
enum MilestoneArt { piano, car, elephant, bus, truck, whale, jet, wheel, tower }

/// The objects the volume is compared with. The weights are approximate and sourced
/// (docs/PHASE-10-PROPOSAL.md); the server has the same keys and thresholds.
class Milestone {
  const Milestone(this.key, this.weightKg, this.name, this.plural, this.art);

  final String key;

  /// Also the threshold that unlocks it.
  final double weightKg;

  /// "a small car"
  final String name;

  /// "small cars"
  final String plural;
  final MilestoneArt art;

  static const all = [
    Milestone('grand-piano', 500, 'a grand piano', 'grand pianos', MilestoneArt.piano),
    Milestone('small-car', 1000, 'a small car', 'small cars', MilestoneArt.car),
    Milestone('elephant', 6000, 'an elephant', 'elephants', MilestoneArt.elephant),
    Milestone('city-bus', 12000, 'a city bus', 'city buses', MilestoneArt.bus),
    Milestone('loaded-truck', 40000, 'a loaded truck', 'loaded trucks', MilestoneArt.truck),
    Milestone('blue-whale', 150000, 'a blue whale', 'blue whales', MilestoneArt.whale),
    Milestone('jumbo-jet', 450000, 'a jumbo jet at takeoff', 'jumbo jets', MilestoneArt.jet),
    Milestone('london-eye', 2100000, 'the London Eye', 'London Eyes', MilestoneArt.wheel),
    Milestone('eiffel-tower', 10100000, 'the Eiffel Tower', 'Eiffel Towers', MilestoneArt.tower),
  ];

  static Milestone? byKey(String key) => all.where((m) => m.key == key).firstOrNull;

  /// "A small car"
  String get title => '${name[0].toUpperCase()}${name.substring(1)}';

  /// The biggest object [kg] reaches, or null under the smallest one.
  static Milestone? biggestWithin(double kg) => all.where((m) => m.weightKg <= kg).lastOrNull;

  /// "About 1.4 elephants", "About 6 small cars", "About a small car". Null under the smallest object.
  /// One decimal under 10, whole numbers above it: never a fake precision.
  static String? compare(double kg) {
    final object = biggestWithin(kg);
    if (object == null) return null;
    final times = kg / object.weightKg;
    final count = times < 10 ? NumberFormat('0.#').format(times) : NumberFormat.decimalPattern().format(times.floor());
    return count == '1' ? 'About ${object.name}' : 'About $count ${object.plural}';
  }
}

/// 8420 -> ("8,420", "kg"), 12400 -> ("12.4", "t"), 2100000 -> ("2,100", "t")
(String, String) volumeParts(double kg) => kg < 10000
    ? (NumberFormat.decimalPattern().format(kg.round()), 'kg')
    : (NumberFormat('#,##0.#').format(kg / 1000), 't');

/// "3,580 kg", "27.6 t"
String formatVolumeAmount(double kg) {
  final (number, unit) = volumeParts(kg);
  return '$number $unit';
}
