// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatsOverview {

 int? get weeklyGoal; int get currentStreakWeeks; int get totalWorkouts; WeekStats get thisWeek; WeekStats get lastWeek; List<WeekStats> get weeks;
/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsOverviewCopyWith<StatsOverview> get copyWith => _$StatsOverviewCopyWithImpl<StatsOverview>(this as StatsOverview, _$identity);

  /// Serializes this StatsOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StatsOverview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsOverview&&(identical(other.weeklyGoal, _this.weeklyGoal) || other.weeklyGoal == _this.weeklyGoal)&&(identical(other.currentStreakWeeks, _this.currentStreakWeeks) || other.currentStreakWeeks == _this.currentStreakWeeks)&&(identical(other.totalWorkouts, _this.totalWorkouts) || other.totalWorkouts == _this.totalWorkouts)&&(identical(other.thisWeek, _this.thisWeek) || other.thisWeek == _this.thisWeek)&&(identical(other.lastWeek, _this.lastWeek) || other.lastWeek == _this.lastWeek)&&const DeepCollectionEquality().equals(other.weeks, _this.weeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StatsOverview;
  return Object.hash(runtimeType,_this.weeklyGoal,_this.currentStreakWeeks,_this.totalWorkouts,_this.thisWeek,_this.lastWeek,const DeepCollectionEquality().hash(_this.weeks));
}

@override
String toString() {
  final _this = this as StatsOverview;
  return 'StatsOverview(weeklyGoal: ${_this.weeklyGoal}, currentStreakWeeks: ${_this.currentStreakWeeks}, totalWorkouts: ${_this.totalWorkouts}, thisWeek: ${_this.thisWeek}, lastWeek: ${_this.lastWeek}, weeks: ${_this.weeks})';
}


}

/// @nodoc
abstract mixin class $StatsOverviewCopyWith<$Res>  {
  factory $StatsOverviewCopyWith(StatsOverview value, $Res Function(StatsOverview) _then) = _$StatsOverviewCopyWithImpl;
@useResult
$Res call({
 int? weeklyGoal, int currentStreakWeeks, int totalWorkouts, WeekStats thisWeek, WeekStats lastWeek, List<WeekStats> weeks
});


$WeekStatsCopyWith<$Res> get thisWeek;$WeekStatsCopyWith<$Res> get lastWeek;

}
/// @nodoc
class _$StatsOverviewCopyWithImpl<$Res>
    implements $StatsOverviewCopyWith<$Res> {
  _$StatsOverviewCopyWithImpl(this._self, this._then);

  final StatsOverview _self;
  final $Res Function(StatsOverview) _then;

/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weeklyGoal = freezed,Object? currentStreakWeeks = null,Object? totalWorkouts = null,Object? thisWeek = null,Object? lastWeek = null,Object? weeks = null,}) {
  return _then(StatsOverview(
weeklyGoal: freezed == weeklyGoal ? _self.weeklyGoal : weeklyGoal // ignore: cast_nullable_to_non_nullable
as int?,currentStreakWeeks: null == currentStreakWeeks ? _self.currentStreakWeeks : currentStreakWeeks // ignore: cast_nullable_to_non_nullable
as int,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,thisWeek: null == thisWeek ? _self.thisWeek : thisWeek // ignore: cast_nullable_to_non_nullable
as WeekStats,lastWeek: null == lastWeek ? _self.lastWeek : lastWeek // ignore: cast_nullable_to_non_nullable
as WeekStats,weeks: null == weeks ? _self.weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<WeekStats>,
  ));
}
/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekStatsCopyWith<$Res> get thisWeek {
  
  return $WeekStatsCopyWith<$Res>(_self.thisWeek, (value) {
    return _then(_self.copyWith(thisWeek: value));
  });
}/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekStatsCopyWith<$Res> get lastWeek {
  
  return $WeekStatsCopyWith<$Res>(_self.lastWeek, (value) {
    return _then(_self.copyWith(lastWeek: value));
  });
}
}


/// Adds pattern-matching-related methods to [StatsOverview].
extension StatsOverviewPatterns on StatsOverview {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsOverview() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsOverview value)  $default,){
final _that = this;
switch (_that) {
case _StatsOverview():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsOverview value)?  $default,){
final _that = this;
switch (_that) {
case _StatsOverview() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? weeklyGoal,  int currentStreakWeeks,  int totalWorkouts,  WeekStats thisWeek,  WeekStats lastWeek,  List<WeekStats> weeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsOverview() when $default != null:
return $default(_that.weeklyGoal,_that.currentStreakWeeks,_that.totalWorkouts,_that.thisWeek,_that.lastWeek,_that.weeks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? weeklyGoal,  int currentStreakWeeks,  int totalWorkouts,  WeekStats thisWeek,  WeekStats lastWeek,  List<WeekStats> weeks)  $default,) {final _that = this;
switch (_that) {
case _StatsOverview():
return $default(_that.weeklyGoal,_that.currentStreakWeeks,_that.totalWorkouts,_that.thisWeek,_that.lastWeek,_that.weeks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? weeklyGoal,  int currentStreakWeeks,  int totalWorkouts,  WeekStats thisWeek,  WeekStats lastWeek,  List<WeekStats> weeks)?  $default,) {final _that = this;
switch (_that) {
case _StatsOverview() when $default != null:
return $default(_that.weeklyGoal,_that.currentStreakWeeks,_that.totalWorkouts,_that.thisWeek,_that.lastWeek,_that.weeks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsOverview implements StatsOverview {
  const _StatsOverview({this.weeklyGoal, required this.currentStreakWeeks, required this.totalWorkouts, required this.thisWeek, required this.lastWeek,  List<WeekStats> weeks = const []}): _weeks = weeks;
  factory _StatsOverview.fromJson(Map<String, dynamic> json) => _$StatsOverviewFromJson(json);

@override final  int? weeklyGoal;
@override final  int currentStreakWeeks;
@override final  int totalWorkouts;
@override final  WeekStats thisWeek;
@override final  WeekStats lastWeek;
 final  List<WeekStats> _weeks;
@override@JsonKey() List<WeekStats> get weeks {
  if (_weeks is EqualUnmodifiableListView) return _weeks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeks);
}


/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsOverviewCopyWith<_StatsOverview> get copyWith => __$StatsOverviewCopyWithImpl<_StatsOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsOverview&&(identical(other.weeklyGoal, weeklyGoal) || other.weeklyGoal == weeklyGoal)&&(identical(other.currentStreakWeeks, currentStreakWeeks) || other.currentStreakWeeks == currentStreakWeeks)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.thisWeek, thisWeek) || other.thisWeek == thisWeek)&&(identical(other.lastWeek, lastWeek) || other.lastWeek == lastWeek)&&const DeepCollectionEquality().equals(other.weeks, _weeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,weeklyGoal,currentStreakWeeks,totalWorkouts,thisWeek,lastWeek,const DeepCollectionEquality().hash(_weeks));
}

@override
String toString() {
    return 'StatsOverview(weeklyGoal: $weeklyGoal, currentStreakWeeks: $currentStreakWeeks, totalWorkouts: $totalWorkouts, thisWeek: $thisWeek, lastWeek: $lastWeek, weeks: $weeks)';
}


}

/// @nodoc
abstract mixin class _$StatsOverviewCopyWith<$Res> implements $StatsOverviewCopyWith<$Res> {
  factory _$StatsOverviewCopyWith(_StatsOverview value, $Res Function(_StatsOverview) _then) = __$StatsOverviewCopyWithImpl;
@override @useResult
$Res call({
 int? weeklyGoal, int currentStreakWeeks, int totalWorkouts, WeekStats thisWeek, WeekStats lastWeek, List<WeekStats> weeks
});


@override $WeekStatsCopyWith<$Res> get thisWeek;@override $WeekStatsCopyWith<$Res> get lastWeek;

}
/// @nodoc
class __$StatsOverviewCopyWithImpl<$Res>
    implements _$StatsOverviewCopyWith<$Res> {
  __$StatsOverviewCopyWithImpl(this._self, this._then);

  final _StatsOverview _self;
  final $Res Function(_StatsOverview) _then;

/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weeklyGoal = freezed,Object? currentStreakWeeks = null,Object? totalWorkouts = null,Object? thisWeek = null,Object? lastWeek = null,Object? weeks = null,}) {
  return _then(_StatsOverview(
weeklyGoal: freezed == weeklyGoal ? _self.weeklyGoal : weeklyGoal // ignore: cast_nullable_to_non_nullable
as int?,currentStreakWeeks: null == currentStreakWeeks ? _self.currentStreakWeeks : currentStreakWeeks // ignore: cast_nullable_to_non_nullable
as int,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,thisWeek: null == thisWeek ? _self.thisWeek : thisWeek // ignore: cast_nullable_to_non_nullable
as WeekStats,lastWeek: null == lastWeek ? _self.lastWeek : lastWeek // ignore: cast_nullable_to_non_nullable
as WeekStats,weeks: null == weeks ? _self._weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<WeekStats>,
  ));
}

/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekStatsCopyWith<$Res> get thisWeek {
  
  return $WeekStatsCopyWith<$Res>(_self.thisWeek, (value) {
    return _then(_self.copyWith(thisWeek: value));
  });
}/// Create a copy of StatsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekStatsCopyWith<$Res> get lastWeek {
  
  return $WeekStatsCopyWith<$Res>(_self.lastWeek, (value) {
    return _then(_self.copyWith(lastWeek: value));
  });
}
}


/// @nodoc
mixin _$WeekStats {

 DateTime get weekStart; int get workouts; int get sets; double get volumeKg; int get cardioSeconds; int get estimatedCalories;
/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekStatsCopyWith<WeekStats> get copyWith => _$WeekStatsCopyWithImpl<WeekStats>(this as WeekStats, _$identity);

  /// Serializes this WeekStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WeekStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekStats&&(identical(other.weekStart, _this.weekStart) || other.weekStart == _this.weekStart)&&(identical(other.workouts, _this.workouts) || other.workouts == _this.workouts)&&(identical(other.sets, _this.sets) || other.sets == _this.sets)&&(identical(other.volumeKg, _this.volumeKg) || other.volumeKg == _this.volumeKg)&&(identical(other.cardioSeconds, _this.cardioSeconds) || other.cardioSeconds == _this.cardioSeconds)&&(identical(other.estimatedCalories, _this.estimatedCalories) || other.estimatedCalories == _this.estimatedCalories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WeekStats;
  return Object.hash(runtimeType,_this.weekStart,_this.workouts,_this.sets,_this.volumeKg,_this.cardioSeconds,_this.estimatedCalories);
}

@override
String toString() {
  final _this = this as WeekStats;
  return 'WeekStats(weekStart: ${_this.weekStart}, workouts: ${_this.workouts}, sets: ${_this.sets}, volumeKg: ${_this.volumeKg}, cardioSeconds: ${_this.cardioSeconds}, estimatedCalories: ${_this.estimatedCalories})';
}


}

/// @nodoc
abstract mixin class $WeekStatsCopyWith<$Res>  {
  factory $WeekStatsCopyWith(WeekStats value, $Res Function(WeekStats) _then) = _$WeekStatsCopyWithImpl;
@useResult
$Res call({
 DateTime weekStart, int workouts, int sets, double volumeKg, int cardioSeconds, int estimatedCalories
});




}
/// @nodoc
class _$WeekStatsCopyWithImpl<$Res>
    implements $WeekStatsCopyWith<$Res> {
  _$WeekStatsCopyWithImpl(this._self, this._then);

  final WeekStats _self;
  final $Res Function(WeekStats) _then;

/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekStart = null,Object? workouts = null,Object? sets = null,Object? volumeKg = null,Object? cardioSeconds = null,Object? estimatedCalories = null,}) {
  return _then(WeekStats(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,cardioSeconds: null == cardioSeconds ? _self.cardioSeconds : cardioSeconds // ignore: cast_nullable_to_non_nullable
as int,estimatedCalories: null == estimatedCalories ? _self.estimatedCalories : estimatedCalories // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekStats].
extension WeekStatsPatterns on WeekStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekStats value)  $default,){
final _that = this;
switch (_that) {
case _WeekStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekStats value)?  $default,){
final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime weekStart,  int workouts,  int sets,  double volumeKg,  int cardioSeconds,  int estimatedCalories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
return $default(_that.weekStart,_that.workouts,_that.sets,_that.volumeKg,_that.cardioSeconds,_that.estimatedCalories);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime weekStart,  int workouts,  int sets,  double volumeKg,  int cardioSeconds,  int estimatedCalories)  $default,) {final _that = this;
switch (_that) {
case _WeekStats():
return $default(_that.weekStart,_that.workouts,_that.sets,_that.volumeKg,_that.cardioSeconds,_that.estimatedCalories);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime weekStart,  int workouts,  int sets,  double volumeKg,  int cardioSeconds,  int estimatedCalories)?  $default,) {final _that = this;
switch (_that) {
case _WeekStats() when $default != null:
return $default(_that.weekStart,_that.workouts,_that.sets,_that.volumeKg,_that.cardioSeconds,_that.estimatedCalories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeekStats implements WeekStats {
  const _WeekStats({required this.weekStart, required this.workouts, required this.sets, required this.volumeKg, required this.cardioSeconds, required this.estimatedCalories});
  factory _WeekStats.fromJson(Map<String, dynamic> json) => _$WeekStatsFromJson(json);

@override final  DateTime weekStart;
@override final  int workouts;
@override final  int sets;
@override final  double volumeKg;
@override final  int cardioSeconds;
@override final  int estimatedCalories;

/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekStatsCopyWith<_WeekStats> get copyWith => __$WeekStatsCopyWithImpl<_WeekStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeekStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekStats&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.workouts, workouts) || other.workouts == workouts)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.cardioSeconds, cardioSeconds) || other.cardioSeconds == cardioSeconds)&&(identical(other.estimatedCalories, estimatedCalories) || other.estimatedCalories == estimatedCalories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,weekStart,workouts,sets,volumeKg,cardioSeconds,estimatedCalories);
}

@override
String toString() {
    return 'WeekStats(weekStart: $weekStart, workouts: $workouts, sets: $sets, volumeKg: $volumeKg, cardioSeconds: $cardioSeconds, estimatedCalories: $estimatedCalories)';
}


}

/// @nodoc
abstract mixin class _$WeekStatsCopyWith<$Res> implements $WeekStatsCopyWith<$Res> {
  factory _$WeekStatsCopyWith(_WeekStats value, $Res Function(_WeekStats) _then) = __$WeekStatsCopyWithImpl;
@override @useResult
$Res call({
 DateTime weekStart, int workouts, int sets, double volumeKg, int cardioSeconds, int estimatedCalories
});




}
/// @nodoc
class __$WeekStatsCopyWithImpl<$Res>
    implements _$WeekStatsCopyWith<$Res> {
  __$WeekStatsCopyWithImpl(this._self, this._then);

  final _WeekStats _self;
  final $Res Function(_WeekStats) _then;

/// Create a copy of WeekStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekStart = null,Object? workouts = null,Object? sets = null,Object? volumeKg = null,Object? cardioSeconds = null,Object? estimatedCalories = null,}) {
  return _then(_WeekStats(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,cardioSeconds: null == cardioSeconds ? _self.cardioSeconds : cardioSeconds // ignore: cast_nullable_to_non_nullable
as int,estimatedCalories: null == estimatedCalories ? _self.estimatedCalories : estimatedCalories // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExerciseRecords {

 String get exerciseId; String get name; String get gifUrl; String get bodyPart; DateTime get lastPerformedAt; int get sessionCount; RecordSet? get heaviestWeight; RecordSet? get bestEstimated1Rm; RecordSet get mostReps; RecordSet? get bestSetVolume;
/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseRecordsCopyWith<ExerciseRecords> get copyWith => _$ExerciseRecordsCopyWithImpl<ExerciseRecords>(this as ExerciseRecords, _$identity);

  /// Serializes this ExerciseRecords to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseRecords;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseRecords&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.gifUrl, _this.gifUrl) || other.gifUrl == _this.gifUrl)&&(identical(other.bodyPart, _this.bodyPart) || other.bodyPart == _this.bodyPart)&&(identical(other.lastPerformedAt, _this.lastPerformedAt) || other.lastPerformedAt == _this.lastPerformedAt)&&(identical(other.sessionCount, _this.sessionCount) || other.sessionCount == _this.sessionCount)&&(identical(other.heaviestWeight, _this.heaviestWeight) || other.heaviestWeight == _this.heaviestWeight)&&(identical(other.bestEstimated1Rm, _this.bestEstimated1Rm) || other.bestEstimated1Rm == _this.bestEstimated1Rm)&&(identical(other.mostReps, _this.mostReps) || other.mostReps == _this.mostReps)&&(identical(other.bestSetVolume, _this.bestSetVolume) || other.bestSetVolume == _this.bestSetVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseRecords;
  return Object.hash(runtimeType,_this.exerciseId,_this.name,_this.gifUrl,_this.bodyPart,_this.lastPerformedAt,_this.sessionCount,_this.heaviestWeight,_this.bestEstimated1Rm,_this.mostReps,_this.bestSetVolume);
}

@override
String toString() {
  final _this = this as ExerciseRecords;
  return 'ExerciseRecords(exerciseId: ${_this.exerciseId}, name: ${_this.name}, gifUrl: ${_this.gifUrl}, bodyPart: ${_this.bodyPart}, lastPerformedAt: ${_this.lastPerformedAt}, sessionCount: ${_this.sessionCount}, heaviestWeight: ${_this.heaviestWeight}, bestEstimated1Rm: ${_this.bestEstimated1Rm}, mostReps: ${_this.mostReps}, bestSetVolume: ${_this.bestSetVolume})';
}


}

/// @nodoc
abstract mixin class $ExerciseRecordsCopyWith<$Res>  {
  factory $ExerciseRecordsCopyWith(ExerciseRecords value, $Res Function(ExerciseRecords) _then) = _$ExerciseRecordsCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String name, String gifUrl, String bodyPart, DateTime lastPerformedAt, int sessionCount, RecordSet? heaviestWeight, RecordSet? bestEstimated1Rm, RecordSet mostReps, RecordSet? bestSetVolume
});


$RecordSetCopyWith<$Res>? get heaviestWeight;$RecordSetCopyWith<$Res>? get bestEstimated1Rm;$RecordSetCopyWith<$Res> get mostReps;$RecordSetCopyWith<$Res>? get bestSetVolume;

}
/// @nodoc
class _$ExerciseRecordsCopyWithImpl<$Res>
    implements $ExerciseRecordsCopyWith<$Res> {
  _$ExerciseRecordsCopyWithImpl(this._self, this._then);

  final ExerciseRecords _self;
  final $Res Function(ExerciseRecords) _then;

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? name = null,Object? gifUrl = null,Object? bodyPart = null,Object? lastPerformedAt = null,Object? sessionCount = null,Object? heaviestWeight = freezed,Object? bestEstimated1Rm = freezed,Object? mostReps = null,Object? bestSetVolume = freezed,}) {
  return _then(ExerciseRecords(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gifUrl: null == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String,bodyPart: null == bodyPart ? _self.bodyPart : bodyPart // ignore: cast_nullable_to_non_nullable
as String,lastPerformedAt: null == lastPerformedAt ? _self.lastPerformedAt : lastPerformedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,heaviestWeight: freezed == heaviestWeight ? _self.heaviestWeight : heaviestWeight // ignore: cast_nullable_to_non_nullable
as RecordSet?,bestEstimated1Rm: freezed == bestEstimated1Rm ? _self.bestEstimated1Rm : bestEstimated1Rm // ignore: cast_nullable_to_non_nullable
as RecordSet?,mostReps: null == mostReps ? _self.mostReps : mostReps // ignore: cast_nullable_to_non_nullable
as RecordSet,bestSetVolume: freezed == bestSetVolume ? _self.bestSetVolume : bestSetVolume // ignore: cast_nullable_to_non_nullable
as RecordSet?,
  ));
}
/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res>? get heaviestWeight {
    if (_self.heaviestWeight == null) {
    return null;
  }

  return $RecordSetCopyWith<$Res>(_self.heaviestWeight!, (value) {
    return _then(_self.copyWith(heaviestWeight: value));
  });
}/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res>? get bestEstimated1Rm {
    if (_self.bestEstimated1Rm == null) {
    return null;
  }

  return $RecordSetCopyWith<$Res>(_self.bestEstimated1Rm!, (value) {
    return _then(_self.copyWith(bestEstimated1Rm: value));
  });
}/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res> get mostReps {
  
  return $RecordSetCopyWith<$Res>(_self.mostReps, (value) {
    return _then(_self.copyWith(mostReps: value));
  });
}/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res>? get bestSetVolume {
    if (_self.bestSetVolume == null) {
    return null;
  }

  return $RecordSetCopyWith<$Res>(_self.bestSetVolume!, (value) {
    return _then(_self.copyWith(bestSetVolume: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExerciseRecords].
extension ExerciseRecordsPatterns on ExerciseRecords {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseRecords value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseRecords value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseRecords():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseRecords value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String name,  String gifUrl,  String bodyPart,  DateTime lastPerformedAt,  int sessionCount,  RecordSet? heaviestWeight,  RecordSet? bestEstimated1Rm,  RecordSet mostReps,  RecordSet? bestSetVolume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
return $default(_that.exerciseId,_that.name,_that.gifUrl,_that.bodyPart,_that.lastPerformedAt,_that.sessionCount,_that.heaviestWeight,_that.bestEstimated1Rm,_that.mostReps,_that.bestSetVolume);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String name,  String gifUrl,  String bodyPart,  DateTime lastPerformedAt,  int sessionCount,  RecordSet? heaviestWeight,  RecordSet? bestEstimated1Rm,  RecordSet mostReps,  RecordSet? bestSetVolume)  $default,) {final _that = this;
switch (_that) {
case _ExerciseRecords():
return $default(_that.exerciseId,_that.name,_that.gifUrl,_that.bodyPart,_that.lastPerformedAt,_that.sessionCount,_that.heaviestWeight,_that.bestEstimated1Rm,_that.mostReps,_that.bestSetVolume);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String name,  String gifUrl,  String bodyPart,  DateTime lastPerformedAt,  int sessionCount,  RecordSet? heaviestWeight,  RecordSet? bestEstimated1Rm,  RecordSet mostReps,  RecordSet? bestSetVolume)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
return $default(_that.exerciseId,_that.name,_that.gifUrl,_that.bodyPart,_that.lastPerformedAt,_that.sessionCount,_that.heaviestWeight,_that.bestEstimated1Rm,_that.mostReps,_that.bestSetVolume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseRecords implements ExerciseRecords {
  const _ExerciseRecords({required this.exerciseId, required this.name, required this.gifUrl, required this.bodyPart, required this.lastPerformedAt, required this.sessionCount, this.heaviestWeight, this.bestEstimated1Rm, required this.mostReps, this.bestSetVolume});
  factory _ExerciseRecords.fromJson(Map<String, dynamic> json) => _$ExerciseRecordsFromJson(json);

@override final  String exerciseId;
@override final  String name;
@override final  String gifUrl;
@override final  String bodyPart;
@override final  DateTime lastPerformedAt;
@override final  int sessionCount;
@override final  RecordSet? heaviestWeight;
@override final  RecordSet? bestEstimated1Rm;
@override final  RecordSet mostReps;
@override final  RecordSet? bestSetVolume;

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseRecordsCopyWith<_ExerciseRecords> get copyWith => __$ExerciseRecordsCopyWithImpl<_ExerciseRecords>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseRecordsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseRecords&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&(identical(other.bodyPart, bodyPart) || other.bodyPart == bodyPart)&&(identical(other.lastPerformedAt, lastPerformedAt) || other.lastPerformedAt == lastPerformedAt)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.heaviestWeight, heaviestWeight) || other.heaviestWeight == heaviestWeight)&&(identical(other.bestEstimated1Rm, bestEstimated1Rm) || other.bestEstimated1Rm == bestEstimated1Rm)&&(identical(other.mostReps, mostReps) || other.mostReps == mostReps)&&(identical(other.bestSetVolume, bestSetVolume) || other.bestSetVolume == bestSetVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,exerciseId,name,gifUrl,bodyPart,lastPerformedAt,sessionCount,heaviestWeight,bestEstimated1Rm,mostReps,bestSetVolume);
}

@override
String toString() {
    return 'ExerciseRecords(exerciseId: $exerciseId, name: $name, gifUrl: $gifUrl, bodyPart: $bodyPart, lastPerformedAt: $lastPerformedAt, sessionCount: $sessionCount, heaviestWeight: $heaviestWeight, bestEstimated1Rm: $bestEstimated1Rm, mostReps: $mostReps, bestSetVolume: $bestSetVolume)';
}


}

/// @nodoc
abstract mixin class _$ExerciseRecordsCopyWith<$Res> implements $ExerciseRecordsCopyWith<$Res> {
  factory _$ExerciseRecordsCopyWith(_ExerciseRecords value, $Res Function(_ExerciseRecords) _then) = __$ExerciseRecordsCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String name, String gifUrl, String bodyPart, DateTime lastPerformedAt, int sessionCount, RecordSet? heaviestWeight, RecordSet? bestEstimated1Rm, RecordSet mostReps, RecordSet? bestSetVolume
});


@override $RecordSetCopyWith<$Res>? get heaviestWeight;@override $RecordSetCopyWith<$Res>? get bestEstimated1Rm;@override $RecordSetCopyWith<$Res> get mostReps;@override $RecordSetCopyWith<$Res>? get bestSetVolume;

}
/// @nodoc
class __$ExerciseRecordsCopyWithImpl<$Res>
    implements _$ExerciseRecordsCopyWith<$Res> {
  __$ExerciseRecordsCopyWithImpl(this._self, this._then);

  final _ExerciseRecords _self;
  final $Res Function(_ExerciseRecords) _then;

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? name = null,Object? gifUrl = null,Object? bodyPart = null,Object? lastPerformedAt = null,Object? sessionCount = null,Object? heaviestWeight = freezed,Object? bestEstimated1Rm = freezed,Object? mostReps = null,Object? bestSetVolume = freezed,}) {
  return _then(_ExerciseRecords(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gifUrl: null == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String,bodyPart: null == bodyPart ? _self.bodyPart : bodyPart // ignore: cast_nullable_to_non_nullable
as String,lastPerformedAt: null == lastPerformedAt ? _self.lastPerformedAt : lastPerformedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,heaviestWeight: freezed == heaviestWeight ? _self.heaviestWeight : heaviestWeight // ignore: cast_nullable_to_non_nullable
as RecordSet?,bestEstimated1Rm: freezed == bestEstimated1Rm ? _self.bestEstimated1Rm : bestEstimated1Rm // ignore: cast_nullable_to_non_nullable
as RecordSet?,mostReps: null == mostReps ? _self.mostReps : mostReps // ignore: cast_nullable_to_non_nullable
as RecordSet,bestSetVolume: freezed == bestSetVolume ? _self.bestSetVolume : bestSetVolume // ignore: cast_nullable_to_non_nullable
as RecordSet?,
  ));
}

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res>? get heaviestWeight {
    if (_self.heaviestWeight == null) {
    return null;
  }

  return $RecordSetCopyWith<$Res>(_self.heaviestWeight!, (value) {
    return _then(_self.copyWith(heaviestWeight: value));
  });
}/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res>? get bestEstimated1Rm {
    if (_self.bestEstimated1Rm == null) {
    return null;
  }

  return $RecordSetCopyWith<$Res>(_self.bestEstimated1Rm!, (value) {
    return _then(_self.copyWith(bestEstimated1Rm: value));
  });
}/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res> get mostReps {
  
  return $RecordSetCopyWith<$Res>(_self.mostReps, (value) {
    return _then(_self.copyWith(mostReps: value));
  });
}/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecordSetCopyWith<$Res>? get bestSetVolume {
    if (_self.bestSetVolume == null) {
    return null;
  }

  return $RecordSetCopyWith<$Res>(_self.bestSetVolume!, (value) {
    return _then(_self.copyWith(bestSetVolume: value));
  });
}
}


/// @nodoc
mixin _$RecordSet {

 double get value; double? get weightKg; int get reps; String get sessionId; DateTime get achievedAt;
/// Create a copy of RecordSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordSetCopyWith<RecordSet> get copyWith => _$RecordSetCopyWithImpl<RecordSet>(this as RecordSet, _$identity);

  /// Serializes this RecordSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecordSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordSet&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.achievedAt, _this.achievedAt) || other.achievedAt == _this.achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecordSet;
  return Object.hash(runtimeType,_this.value,_this.weightKg,_this.reps,_this.sessionId,_this.achievedAt);
}

@override
String toString() {
  final _this = this as RecordSet;
  return 'RecordSet(value: ${_this.value}, weightKg: ${_this.weightKg}, reps: ${_this.reps}, sessionId: ${_this.sessionId}, achievedAt: ${_this.achievedAt})';
}


}

/// @nodoc
abstract mixin class $RecordSetCopyWith<$Res>  {
  factory $RecordSetCopyWith(RecordSet value, $Res Function(RecordSet) _then) = _$RecordSetCopyWithImpl;
@useResult
$Res call({
 double value, double? weightKg, int reps, String sessionId, DateTime achievedAt
});




}
/// @nodoc
class _$RecordSetCopyWithImpl<$Res>
    implements $RecordSetCopyWith<$Res> {
  _$RecordSetCopyWithImpl(this._self, this._then);

  final RecordSet _self;
  final $Res Function(RecordSet) _then;

/// Create a copy of RecordSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? weightKg = freezed,Object? reps = null,Object? sessionId = null,Object? achievedAt = null,}) {
  return _then(RecordSet(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordSet].
extension RecordSetPatterns on RecordSet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordSet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordSet value)  $default,){
final _that = this;
switch (_that) {
case _RecordSet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordSet value)?  $default,){
final _that = this;
switch (_that) {
case _RecordSet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double value,  double? weightKg,  int reps,  String sessionId,  DateTime achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordSet() when $default != null:
return $default(_that.value,_that.weightKg,_that.reps,_that.sessionId,_that.achievedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double value,  double? weightKg,  int reps,  String sessionId,  DateTime achievedAt)  $default,) {final _that = this;
switch (_that) {
case _RecordSet():
return $default(_that.value,_that.weightKg,_that.reps,_that.sessionId,_that.achievedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double value,  double? weightKg,  int reps,  String sessionId,  DateTime achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecordSet() when $default != null:
return $default(_that.value,_that.weightKg,_that.reps,_that.sessionId,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecordSet implements RecordSet {
  const _RecordSet({required this.value, this.weightKg, required this.reps, required this.sessionId, required this.achievedAt});
  factory _RecordSet.fromJson(Map<String, dynamic> json) => _$RecordSetFromJson(json);

@override final  double value;
@override final  double? weightKg;
@override final  int reps;
@override final  String sessionId;
@override final  DateTime achievedAt;

/// Create a copy of RecordSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordSetCopyWith<_RecordSet> get copyWith => __$RecordSetCopyWithImpl<_RecordSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecordSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordSet&&(identical(other.value, value) || other.value == value)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value,weightKg,reps,sessionId,achievedAt);
}

@override
String toString() {
    return 'RecordSet(value: $value, weightKg: $weightKg, reps: $reps, sessionId: $sessionId, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$RecordSetCopyWith<$Res> implements $RecordSetCopyWith<$Res> {
  factory _$RecordSetCopyWith(_RecordSet value, $Res Function(_RecordSet) _then) = __$RecordSetCopyWithImpl;
@override @useResult
$Res call({
 double value, double? weightKg, int reps, String sessionId, DateTime achievedAt
});




}
/// @nodoc
class __$RecordSetCopyWithImpl<$Res>
    implements _$RecordSetCopyWith<$Res> {
  __$RecordSetCopyWithImpl(this._self, this._then);

  final _RecordSet _self;
  final $Res Function(_RecordSet) _then;

/// Create a copy of RecordSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? weightKg = freezed,Object? reps = null,Object? sessionId = null,Object? achievedAt = null,}) {
  return _then(_RecordSet(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,achievedAt: null == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ExerciseProgress {

 ExerciseRecords get records; List<ExerciseSessionPoint> get sessions;
/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseProgressCopyWith<ExerciseProgress> get copyWith => _$ExerciseProgressCopyWithImpl<ExerciseProgress>(this as ExerciseProgress, _$identity);

  /// Serializes this ExerciseProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseProgress&&(identical(other.records, _this.records) || other.records == _this.records)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseProgress;
  return Object.hash(runtimeType,_this.records,const DeepCollectionEquality().hash(_this.sessions));
}

@override
String toString() {
  final _this = this as ExerciseProgress;
  return 'ExerciseProgress(records: ${_this.records}, sessions: ${_this.sessions})';
}


}

/// @nodoc
abstract mixin class $ExerciseProgressCopyWith<$Res>  {
  factory $ExerciseProgressCopyWith(ExerciseProgress value, $Res Function(ExerciseProgress) _then) = _$ExerciseProgressCopyWithImpl;
@useResult
$Res call({
 ExerciseRecords records, List<ExerciseSessionPoint> sessions
});


$ExerciseRecordsCopyWith<$Res> get records;

}
/// @nodoc
class _$ExerciseProgressCopyWithImpl<$Res>
    implements $ExerciseProgressCopyWith<$Res> {
  _$ExerciseProgressCopyWithImpl(this._self, this._then);

  final ExerciseProgress _self;
  final $Res Function(ExerciseProgress) _then;

/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,Object? sessions = null,}) {
  return _then(ExerciseProgress(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as ExerciseRecords,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ExerciseSessionPoint>,
  ));
}
/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseRecordsCopyWith<$Res> get records {
  
  return $ExerciseRecordsCopyWith<$Res>(_self.records, (value) {
    return _then(_self.copyWith(records: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExerciseProgress].
extension ExerciseProgressPatterns on ExerciseProgress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseProgress value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseProgress():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExerciseRecords records,  List<ExerciseSessionPoint> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
return $default(_that.records,_that.sessions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExerciseRecords records,  List<ExerciseSessionPoint> sessions)  $default,) {final _that = this;
switch (_that) {
case _ExerciseProgress():
return $default(_that.records,_that.sessions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExerciseRecords records,  List<ExerciseSessionPoint> sessions)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseProgress() when $default != null:
return $default(_that.records,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseProgress implements ExerciseProgress {
  const _ExerciseProgress({required this.records,  List<ExerciseSessionPoint> sessions = const []}): _sessions = sessions;
  factory _ExerciseProgress.fromJson(Map<String, dynamic> json) => _$ExerciseProgressFromJson(json);

@override final  ExerciseRecords records;
 final  List<ExerciseSessionPoint> _sessions;
@override@JsonKey() List<ExerciseSessionPoint> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}


/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseProgressCopyWith<_ExerciseProgress> get copyWith => __$ExerciseProgressCopyWithImpl<_ExerciseProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseProgress&&(identical(other.records, records) || other.records == records)&&const DeepCollectionEquality().equals(other.sessions, _sessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,records,const DeepCollectionEquality().hash(_sessions));
}

@override
String toString() {
    return 'ExerciseProgress(records: $records, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$ExerciseProgressCopyWith<$Res> implements $ExerciseProgressCopyWith<$Res> {
  factory _$ExerciseProgressCopyWith(_ExerciseProgress value, $Res Function(_ExerciseProgress) _then) = __$ExerciseProgressCopyWithImpl;
@override @useResult
$Res call({
 ExerciseRecords records, List<ExerciseSessionPoint> sessions
});


@override $ExerciseRecordsCopyWith<$Res> get records;

}
/// @nodoc
class __$ExerciseProgressCopyWithImpl<$Res>
    implements _$ExerciseProgressCopyWith<$Res> {
  __$ExerciseProgressCopyWithImpl(this._self, this._then);

  final _ExerciseProgress _self;
  final $Res Function(_ExerciseProgress) _then;

/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,Object? sessions = null,}) {
  return _then(_ExerciseProgress(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as ExerciseRecords,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ExerciseSessionPoint>,
  ));
}

/// Create a copy of ExerciseProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseRecordsCopyWith<$Res> get records {
  
  return $ExerciseRecordsCopyWith<$Res>(_self.records, (value) {
    return _then(_self.copyWith(records: value));
  });
}
}


/// @nodoc
mixin _$ExerciseSessionPoint {

 String get sessionId; DateTime get performedAt; double? get topSetWeightKg; int get topSetReps; double? get estimated1Rm; double get volumeKg; int get sets;
/// Create a copy of ExerciseSessionPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseSessionPointCopyWith<ExerciseSessionPoint> get copyWith => _$ExerciseSessionPointCopyWithImpl<ExerciseSessionPoint>(this as ExerciseSessionPoint, _$identity);

  /// Serializes this ExerciseSessionPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseSessionPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseSessionPoint&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.performedAt, _this.performedAt) || other.performedAt == _this.performedAt)&&(identical(other.topSetWeightKg, _this.topSetWeightKg) || other.topSetWeightKg == _this.topSetWeightKg)&&(identical(other.topSetReps, _this.topSetReps) || other.topSetReps == _this.topSetReps)&&(identical(other.estimated1Rm, _this.estimated1Rm) || other.estimated1Rm == _this.estimated1Rm)&&(identical(other.volumeKg, _this.volumeKg) || other.volumeKg == _this.volumeKg)&&(identical(other.sets, _this.sets) || other.sets == _this.sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseSessionPoint;
  return Object.hash(runtimeType,_this.sessionId,_this.performedAt,_this.topSetWeightKg,_this.topSetReps,_this.estimated1Rm,_this.volumeKg,_this.sets);
}

@override
String toString() {
  final _this = this as ExerciseSessionPoint;
  return 'ExerciseSessionPoint(sessionId: ${_this.sessionId}, performedAt: ${_this.performedAt}, topSetWeightKg: ${_this.topSetWeightKg}, topSetReps: ${_this.topSetReps}, estimated1Rm: ${_this.estimated1Rm}, volumeKg: ${_this.volumeKg}, sets: ${_this.sets})';
}


}

/// @nodoc
abstract mixin class $ExerciseSessionPointCopyWith<$Res>  {
  factory $ExerciseSessionPointCopyWith(ExerciseSessionPoint value, $Res Function(ExerciseSessionPoint) _then) = _$ExerciseSessionPointCopyWithImpl;
@useResult
$Res call({
 String sessionId, DateTime performedAt, double? topSetWeightKg, int topSetReps, double? estimated1Rm, double volumeKg, int sets
});




}
/// @nodoc
class _$ExerciseSessionPointCopyWithImpl<$Res>
    implements $ExerciseSessionPointCopyWith<$Res> {
  _$ExerciseSessionPointCopyWithImpl(this._self, this._then);

  final ExerciseSessionPoint _self;
  final $Res Function(ExerciseSessionPoint) _then;

/// Create a copy of ExerciseSessionPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? performedAt = null,Object? topSetWeightKg = freezed,Object? topSetReps = null,Object? estimated1Rm = freezed,Object? volumeKg = null,Object? sets = null,}) {
  return _then(ExerciseSessionPoint(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,topSetWeightKg: freezed == topSetWeightKg ? _self.topSetWeightKg : topSetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,topSetReps: null == topSetReps ? _self.topSetReps : topSetReps // ignore: cast_nullable_to_non_nullable
as int,estimated1Rm: freezed == estimated1Rm ? _self.estimated1Rm : estimated1Rm // ignore: cast_nullable_to_non_nullable
as double?,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseSessionPoint].
extension ExerciseSessionPointPatterns on ExerciseSessionPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseSessionPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseSessionPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseSessionPoint value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseSessionPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseSessionPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseSessionPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  DateTime performedAt,  double? topSetWeightKg,  int topSetReps,  double? estimated1Rm,  double volumeKg,  int sets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseSessionPoint() when $default != null:
return $default(_that.sessionId,_that.performedAt,_that.topSetWeightKg,_that.topSetReps,_that.estimated1Rm,_that.volumeKg,_that.sets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  DateTime performedAt,  double? topSetWeightKg,  int topSetReps,  double? estimated1Rm,  double volumeKg,  int sets)  $default,) {final _that = this;
switch (_that) {
case _ExerciseSessionPoint():
return $default(_that.sessionId,_that.performedAt,_that.topSetWeightKg,_that.topSetReps,_that.estimated1Rm,_that.volumeKg,_that.sets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  DateTime performedAt,  double? topSetWeightKg,  int topSetReps,  double? estimated1Rm,  double volumeKg,  int sets)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseSessionPoint() when $default != null:
return $default(_that.sessionId,_that.performedAt,_that.topSetWeightKg,_that.topSetReps,_that.estimated1Rm,_that.volumeKg,_that.sets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseSessionPoint implements ExerciseSessionPoint {
  const _ExerciseSessionPoint({required this.sessionId, required this.performedAt, this.topSetWeightKg, required this.topSetReps, this.estimated1Rm, required this.volumeKg, required this.sets});
  factory _ExerciseSessionPoint.fromJson(Map<String, dynamic> json) => _$ExerciseSessionPointFromJson(json);

@override final  String sessionId;
@override final  DateTime performedAt;
@override final  double? topSetWeightKg;
@override final  int topSetReps;
@override final  double? estimated1Rm;
@override final  double volumeKg;
@override final  int sets;

/// Create a copy of ExerciseSessionPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseSessionPointCopyWith<_ExerciseSessionPoint> get copyWith => __$ExerciseSessionPointCopyWithImpl<_ExerciseSessionPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseSessionPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseSessionPoint&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.topSetWeightKg, topSetWeightKg) || other.topSetWeightKg == topSetWeightKg)&&(identical(other.topSetReps, topSetReps) || other.topSetReps == topSetReps)&&(identical(other.estimated1Rm, estimated1Rm) || other.estimated1Rm == estimated1Rm)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.sets, sets) || other.sets == sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,performedAt,topSetWeightKg,topSetReps,estimated1Rm,volumeKg,sets);
}

@override
String toString() {
    return 'ExerciseSessionPoint(sessionId: $sessionId, performedAt: $performedAt, topSetWeightKg: $topSetWeightKg, topSetReps: $topSetReps, estimated1Rm: $estimated1Rm, volumeKg: $volumeKg, sets: $sets)';
}


}

/// @nodoc
abstract mixin class _$ExerciseSessionPointCopyWith<$Res> implements $ExerciseSessionPointCopyWith<$Res> {
  factory _$ExerciseSessionPointCopyWith(_ExerciseSessionPoint value, $Res Function(_ExerciseSessionPoint) _then) = __$ExerciseSessionPointCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, DateTime performedAt, double? topSetWeightKg, int topSetReps, double? estimated1Rm, double volumeKg, int sets
});




}
/// @nodoc
class __$ExerciseSessionPointCopyWithImpl<$Res>
    implements _$ExerciseSessionPointCopyWith<$Res> {
  __$ExerciseSessionPointCopyWithImpl(this._self, this._then);

  final _ExerciseSessionPoint _self;
  final $Res Function(_ExerciseSessionPoint) _then;

/// Create a copy of ExerciseSessionPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? performedAt = null,Object? topSetWeightKg = freezed,Object? topSetReps = null,Object? estimated1Rm = freezed,Object? volumeKg = null,Object? sets = null,}) {
  return _then(_ExerciseSessionPoint(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,topSetWeightKg: freezed == topSetWeightKg ? _self.topSetWeightKg : topSetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,topSetReps: null == topSetReps ? _self.topSetReps : topSetReps // ignore: cast_nullable_to_non_nullable
as int,estimated1Rm: freezed == estimated1Rm ? _self.estimated1Rm : estimated1Rm // ignore: cast_nullable_to_non_nullable
as double?,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SessionComparison {

 String get sessionId; String? get previousSessionId; DateTime? get previousPerformedAt; ComparedValue get volumeKg; ComparedValue get sets; ComparedValue get durationSeconds; List<ExerciseComparison> get exercises; List<NewRecord> get newRecords;
/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionComparisonCopyWith<SessionComparison> get copyWith => _$SessionComparisonCopyWithImpl<SessionComparison>(this as SessionComparison, _$identity);

  /// Serializes this SessionComparison to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionComparison;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionComparison&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.previousSessionId, _this.previousSessionId) || other.previousSessionId == _this.previousSessionId)&&(identical(other.previousPerformedAt, _this.previousPerformedAt) || other.previousPerformedAt == _this.previousPerformedAt)&&(identical(other.volumeKg, _this.volumeKg) || other.volumeKg == _this.volumeKg)&&(identical(other.sets, _this.sets) || other.sets == _this.sets)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&const DeepCollectionEquality().equals(other.newRecords, _this.newRecords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionComparison;
  return Object.hash(runtimeType,_this.sessionId,_this.previousSessionId,_this.previousPerformedAt,_this.volumeKg,_this.sets,_this.durationSeconds,const DeepCollectionEquality().hash(_this.exercises),const DeepCollectionEquality().hash(_this.newRecords));
}

@override
String toString() {
  final _this = this as SessionComparison;
  return 'SessionComparison(sessionId: ${_this.sessionId}, previousSessionId: ${_this.previousSessionId}, previousPerformedAt: ${_this.previousPerformedAt}, volumeKg: ${_this.volumeKg}, sets: ${_this.sets}, durationSeconds: ${_this.durationSeconds}, exercises: ${_this.exercises}, newRecords: ${_this.newRecords})';
}


}

/// @nodoc
abstract mixin class $SessionComparisonCopyWith<$Res>  {
  factory $SessionComparisonCopyWith(SessionComparison value, $Res Function(SessionComparison) _then) = _$SessionComparisonCopyWithImpl;
@useResult
$Res call({
 String sessionId, String? previousSessionId, DateTime? previousPerformedAt, ComparedValue volumeKg, ComparedValue sets, ComparedValue durationSeconds, List<ExerciseComparison> exercises, List<NewRecord> newRecords
});


$ComparedValueCopyWith<$Res> get volumeKg;$ComparedValueCopyWith<$Res> get sets;$ComparedValueCopyWith<$Res> get durationSeconds;

}
/// @nodoc
class _$SessionComparisonCopyWithImpl<$Res>
    implements $SessionComparisonCopyWith<$Res> {
  _$SessionComparisonCopyWithImpl(this._self, this._then);

  final SessionComparison _self;
  final $Res Function(SessionComparison) _then;

/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? previousSessionId = freezed,Object? previousPerformedAt = freezed,Object? volumeKg = null,Object? sets = null,Object? durationSeconds = null,Object? exercises = null,Object? newRecords = null,}) {
  return _then(SessionComparison(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,previousSessionId: freezed == previousSessionId ? _self.previousSessionId : previousSessionId // ignore: cast_nullable_to_non_nullable
as String?,previousPerformedAt: freezed == previousPerformedAt ? _self.previousPerformedAt : previousPerformedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as ComparedValue,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as ComparedValue,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as ComparedValue,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExerciseComparison>,newRecords: null == newRecords ? _self.newRecords : newRecords // ignore: cast_nullable_to_non_nullable
as List<NewRecord>,
  ));
}
/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<$Res> get volumeKg {
  
  return $ComparedValueCopyWith<$Res>(_self.volumeKg, (value) {
    return _then(_self.copyWith(volumeKg: value));
  });
}/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<$Res> get sets {
  
  return $ComparedValueCopyWith<$Res>(_self.sets, (value) {
    return _then(_self.copyWith(sets: value));
  });
}/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<$Res> get durationSeconds {
  
  return $ComparedValueCopyWith<$Res>(_self.durationSeconds, (value) {
    return _then(_self.copyWith(durationSeconds: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionComparison].
extension SessionComparisonPatterns on SessionComparison {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionComparison() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionComparison value)  $default,){
final _that = this;
switch (_that) {
case _SessionComparison():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionComparison value)?  $default,){
final _that = this;
switch (_that) {
case _SessionComparison() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String? previousSessionId,  DateTime? previousPerformedAt,  ComparedValue volumeKg,  ComparedValue sets,  ComparedValue durationSeconds,  List<ExerciseComparison> exercises,  List<NewRecord> newRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionComparison() when $default != null:
return $default(_that.sessionId,_that.previousSessionId,_that.previousPerformedAt,_that.volumeKg,_that.sets,_that.durationSeconds,_that.exercises,_that.newRecords);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String? previousSessionId,  DateTime? previousPerformedAt,  ComparedValue volumeKg,  ComparedValue sets,  ComparedValue durationSeconds,  List<ExerciseComparison> exercises,  List<NewRecord> newRecords)  $default,) {final _that = this;
switch (_that) {
case _SessionComparison():
return $default(_that.sessionId,_that.previousSessionId,_that.previousPerformedAt,_that.volumeKg,_that.sets,_that.durationSeconds,_that.exercises,_that.newRecords);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String? previousSessionId,  DateTime? previousPerformedAt,  ComparedValue volumeKg,  ComparedValue sets,  ComparedValue durationSeconds,  List<ExerciseComparison> exercises,  List<NewRecord> newRecords)?  $default,) {final _that = this;
switch (_that) {
case _SessionComparison() when $default != null:
return $default(_that.sessionId,_that.previousSessionId,_that.previousPerformedAt,_that.volumeKg,_that.sets,_that.durationSeconds,_that.exercises,_that.newRecords);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionComparison implements SessionComparison {
  const _SessionComparison({required this.sessionId, this.previousSessionId, this.previousPerformedAt, required this.volumeKg, required this.sets, required this.durationSeconds,  List<ExerciseComparison> exercises = const [],  List<NewRecord> newRecords = const []}): _exercises = exercises,_newRecords = newRecords;
  factory _SessionComparison.fromJson(Map<String, dynamic> json) => _$SessionComparisonFromJson(json);

@override final  String sessionId;
@override final  String? previousSessionId;
@override final  DateTime? previousPerformedAt;
@override final  ComparedValue volumeKg;
@override final  ComparedValue sets;
@override final  ComparedValue durationSeconds;
 final  List<ExerciseComparison> _exercises;
@override@JsonKey() List<ExerciseComparison> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

 final  List<NewRecord> _newRecords;
@override@JsonKey() List<NewRecord> get newRecords {
  if (_newRecords is EqualUnmodifiableListView) return _newRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newRecords);
}


/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionComparisonCopyWith<_SessionComparison> get copyWith => __$SessionComparisonCopyWithImpl<_SessionComparison>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionComparisonToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionComparison&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.previousSessionId, previousSessionId) || other.previousSessionId == previousSessionId)&&(identical(other.previousPerformedAt, previousPerformedAt) || other.previousPerformedAt == previousPerformedAt)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&const DeepCollectionEquality().equals(other.newRecords, _newRecords));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,previousSessionId,previousPerformedAt,volumeKg,sets,durationSeconds,const DeepCollectionEquality().hash(_exercises),const DeepCollectionEquality().hash(_newRecords));
}

@override
String toString() {
    return 'SessionComparison(sessionId: $sessionId, previousSessionId: $previousSessionId, previousPerformedAt: $previousPerformedAt, volumeKg: $volumeKg, sets: $sets, durationSeconds: $durationSeconds, exercises: $exercises, newRecords: $newRecords)';
}


}

/// @nodoc
abstract mixin class _$SessionComparisonCopyWith<$Res> implements $SessionComparisonCopyWith<$Res> {
  factory _$SessionComparisonCopyWith(_SessionComparison value, $Res Function(_SessionComparison) _then) = __$SessionComparisonCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String? previousSessionId, DateTime? previousPerformedAt, ComparedValue volumeKg, ComparedValue sets, ComparedValue durationSeconds, List<ExerciseComparison> exercises, List<NewRecord> newRecords
});


@override $ComparedValueCopyWith<$Res> get volumeKg;@override $ComparedValueCopyWith<$Res> get sets;@override $ComparedValueCopyWith<$Res> get durationSeconds;

}
/// @nodoc
class __$SessionComparisonCopyWithImpl<$Res>
    implements _$SessionComparisonCopyWith<$Res> {
  __$SessionComparisonCopyWithImpl(this._self, this._then);

  final _SessionComparison _self;
  final $Res Function(_SessionComparison) _then;

/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? previousSessionId = freezed,Object? previousPerformedAt = freezed,Object? volumeKg = null,Object? sets = null,Object? durationSeconds = null,Object? exercises = null,Object? newRecords = null,}) {
  return _then(_SessionComparison(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,previousSessionId: freezed == previousSessionId ? _self.previousSessionId : previousSessionId // ignore: cast_nullable_to_non_nullable
as String?,previousPerformedAt: freezed == previousPerformedAt ? _self.previousPerformedAt : previousPerformedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as ComparedValue,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as ComparedValue,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as ComparedValue,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExerciseComparison>,newRecords: null == newRecords ? _self._newRecords : newRecords // ignore: cast_nullable_to_non_nullable
as List<NewRecord>,
  ));
}

/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<$Res> get volumeKg {
  
  return $ComparedValueCopyWith<$Res>(_self.volumeKg, (value) {
    return _then(_self.copyWith(volumeKg: value));
  });
}/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<$Res> get sets {
  
  return $ComparedValueCopyWith<$Res>(_self.sets, (value) {
    return _then(_self.copyWith(sets: value));
  });
}/// Create a copy of SessionComparison
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<$Res> get durationSeconds {
  
  return $ComparedValueCopyWith<$Res>(_self.durationSeconds, (value) {
    return _then(_self.copyWith(durationSeconds: value));
  });
}
}


/// @nodoc
mixin _$ComparedValue {

 double get current; double? get previous;
/// Create a copy of ComparedValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparedValueCopyWith<ComparedValue> get copyWith => _$ComparedValueCopyWithImpl<ComparedValue>(this as ComparedValue, _$identity);

  /// Serializes this ComparedValue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ComparedValue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparedValue&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.previous, _this.previous) || other.previous == _this.previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ComparedValue;
  return Object.hash(runtimeType,_this.current,_this.previous);
}

@override
String toString() {
  final _this = this as ComparedValue;
  return 'ComparedValue(current: ${_this.current}, previous: ${_this.previous})';
}


}

/// @nodoc
abstract mixin class $ComparedValueCopyWith<$Res>  {
  factory $ComparedValueCopyWith(ComparedValue value, $Res Function(ComparedValue) _then) = _$ComparedValueCopyWithImpl;
@useResult
$Res call({
 double current, double? previous
});




}
/// @nodoc
class _$ComparedValueCopyWithImpl<$Res>
    implements $ComparedValueCopyWith<$Res> {
  _$ComparedValueCopyWithImpl(this._self, this._then);

  final ComparedValue _self;
  final $Res Function(ComparedValue) _then;

/// Create a copy of ComparedValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? previous = freezed,}) {
  return _then(ComparedValue(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparedValue].
extension ComparedValuePatterns on ComparedValue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparedValue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparedValue() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparedValue value)  $default,){
final _that = this;
switch (_that) {
case _ComparedValue():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparedValue value)?  $default,){
final _that = this;
switch (_that) {
case _ComparedValue() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double current,  double? previous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparedValue() when $default != null:
return $default(_that.current,_that.previous);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double current,  double? previous)  $default,) {final _that = this;
switch (_that) {
case _ComparedValue():
return $default(_that.current,_that.previous);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double current,  double? previous)?  $default,) {final _that = this;
switch (_that) {
case _ComparedValue() when $default != null:
return $default(_that.current,_that.previous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComparedValue extends ComparedValue {
  const _ComparedValue({required this.current, this.previous}): super._();
  factory _ComparedValue.fromJson(Map<String, dynamic> json) => _$ComparedValueFromJson(json);

@override final  double current;
@override final  double? previous;

/// Create a copy of ComparedValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparedValueCopyWith<_ComparedValue> get copyWith => __$ComparedValueCopyWithImpl<_ComparedValue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComparedValueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparedValue&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,current,previous);
}

@override
String toString() {
    return 'ComparedValue(current: $current, previous: $previous)';
}


}

/// @nodoc
abstract mixin class _$ComparedValueCopyWith<$Res> implements $ComparedValueCopyWith<$Res> {
  factory _$ComparedValueCopyWith(_ComparedValue value, $Res Function(_ComparedValue) _then) = __$ComparedValueCopyWithImpl;
@override @useResult
$Res call({
 double current, double? previous
});




}
/// @nodoc
class __$ComparedValueCopyWithImpl<$Res>
    implements _$ComparedValueCopyWith<$Res> {
  __$ComparedValueCopyWithImpl(this._self, this._then);

  final _ComparedValue _self;
  final $Res Function(_ComparedValue) _then;

/// Create a copy of ComparedValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? previous = freezed,}) {
  return _then(_ComparedValue(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ExerciseComparison {

 String get exerciseId; String get name; double? get topSetWeightKg; int get topSetReps; double? get previousTopSetWeightKg; int? get previousTopSetReps; double get volumeKg; double? get previousVolumeKg;
/// Create a copy of ExerciseComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseComparisonCopyWith<ExerciseComparison> get copyWith => _$ExerciseComparisonCopyWithImpl<ExerciseComparison>(this as ExerciseComparison, _$identity);

  /// Serializes this ExerciseComparison to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseComparison;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseComparison&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.topSetWeightKg, _this.topSetWeightKg) || other.topSetWeightKg == _this.topSetWeightKg)&&(identical(other.topSetReps, _this.topSetReps) || other.topSetReps == _this.topSetReps)&&(identical(other.previousTopSetWeightKg, _this.previousTopSetWeightKg) || other.previousTopSetWeightKg == _this.previousTopSetWeightKg)&&(identical(other.previousTopSetReps, _this.previousTopSetReps) || other.previousTopSetReps == _this.previousTopSetReps)&&(identical(other.volumeKg, _this.volumeKg) || other.volumeKg == _this.volumeKg)&&(identical(other.previousVolumeKg, _this.previousVolumeKg) || other.previousVolumeKg == _this.previousVolumeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseComparison;
  return Object.hash(runtimeType,_this.exerciseId,_this.name,_this.topSetWeightKg,_this.topSetReps,_this.previousTopSetWeightKg,_this.previousTopSetReps,_this.volumeKg,_this.previousVolumeKg);
}

@override
String toString() {
  final _this = this as ExerciseComparison;
  return 'ExerciseComparison(exerciseId: ${_this.exerciseId}, name: ${_this.name}, topSetWeightKg: ${_this.topSetWeightKg}, topSetReps: ${_this.topSetReps}, previousTopSetWeightKg: ${_this.previousTopSetWeightKg}, previousTopSetReps: ${_this.previousTopSetReps}, volumeKg: ${_this.volumeKg}, previousVolumeKg: ${_this.previousVolumeKg})';
}


}

/// @nodoc
abstract mixin class $ExerciseComparisonCopyWith<$Res>  {
  factory $ExerciseComparisonCopyWith(ExerciseComparison value, $Res Function(ExerciseComparison) _then) = _$ExerciseComparisonCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String name, double? topSetWeightKg, int topSetReps, double? previousTopSetWeightKg, int? previousTopSetReps, double volumeKg, double? previousVolumeKg
});




}
/// @nodoc
class _$ExerciseComparisonCopyWithImpl<$Res>
    implements $ExerciseComparisonCopyWith<$Res> {
  _$ExerciseComparisonCopyWithImpl(this._self, this._then);

  final ExerciseComparison _self;
  final $Res Function(ExerciseComparison) _then;

/// Create a copy of ExerciseComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? name = null,Object? topSetWeightKg = freezed,Object? topSetReps = null,Object? previousTopSetWeightKg = freezed,Object? previousTopSetReps = freezed,Object? volumeKg = null,Object? previousVolumeKg = freezed,}) {
  return _then(ExerciseComparison(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,topSetWeightKg: freezed == topSetWeightKg ? _self.topSetWeightKg : topSetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,topSetReps: null == topSetReps ? _self.topSetReps : topSetReps // ignore: cast_nullable_to_non_nullable
as int,previousTopSetWeightKg: freezed == previousTopSetWeightKg ? _self.previousTopSetWeightKg : previousTopSetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,previousTopSetReps: freezed == previousTopSetReps ? _self.previousTopSetReps : previousTopSetReps // ignore: cast_nullable_to_non_nullable
as int?,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,previousVolumeKg: freezed == previousVolumeKg ? _self.previousVolumeKg : previousVolumeKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseComparison].
extension ExerciseComparisonPatterns on ExerciseComparison {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseComparison() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseComparison value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseComparison():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseComparison value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseComparison() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String name,  double? topSetWeightKg,  int topSetReps,  double? previousTopSetWeightKg,  int? previousTopSetReps,  double volumeKg,  double? previousVolumeKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseComparison() when $default != null:
return $default(_that.exerciseId,_that.name,_that.topSetWeightKg,_that.topSetReps,_that.previousTopSetWeightKg,_that.previousTopSetReps,_that.volumeKg,_that.previousVolumeKg);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String name,  double? topSetWeightKg,  int topSetReps,  double? previousTopSetWeightKg,  int? previousTopSetReps,  double volumeKg,  double? previousVolumeKg)  $default,) {final _that = this;
switch (_that) {
case _ExerciseComparison():
return $default(_that.exerciseId,_that.name,_that.topSetWeightKg,_that.topSetReps,_that.previousTopSetWeightKg,_that.previousTopSetReps,_that.volumeKg,_that.previousVolumeKg);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String name,  double? topSetWeightKg,  int topSetReps,  double? previousTopSetWeightKg,  int? previousTopSetReps,  double volumeKg,  double? previousVolumeKg)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseComparison() when $default != null:
return $default(_that.exerciseId,_that.name,_that.topSetWeightKg,_that.topSetReps,_that.previousTopSetWeightKg,_that.previousTopSetReps,_that.volumeKg,_that.previousVolumeKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseComparison implements ExerciseComparison {
  const _ExerciseComparison({required this.exerciseId, required this.name, this.topSetWeightKg, required this.topSetReps, this.previousTopSetWeightKg, this.previousTopSetReps, required this.volumeKg, this.previousVolumeKg});
  factory _ExerciseComparison.fromJson(Map<String, dynamic> json) => _$ExerciseComparisonFromJson(json);

@override final  String exerciseId;
@override final  String name;
@override final  double? topSetWeightKg;
@override final  int topSetReps;
@override final  double? previousTopSetWeightKg;
@override final  int? previousTopSetReps;
@override final  double volumeKg;
@override final  double? previousVolumeKg;

/// Create a copy of ExerciseComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseComparisonCopyWith<_ExerciseComparison> get copyWith => __$ExerciseComparisonCopyWithImpl<_ExerciseComparison>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseComparisonToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseComparison&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.topSetWeightKg, topSetWeightKg) || other.topSetWeightKg == topSetWeightKg)&&(identical(other.topSetReps, topSetReps) || other.topSetReps == topSetReps)&&(identical(other.previousTopSetWeightKg, previousTopSetWeightKg) || other.previousTopSetWeightKg == previousTopSetWeightKg)&&(identical(other.previousTopSetReps, previousTopSetReps) || other.previousTopSetReps == previousTopSetReps)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.previousVolumeKg, previousVolumeKg) || other.previousVolumeKg == previousVolumeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,exerciseId,name,topSetWeightKg,topSetReps,previousTopSetWeightKg,previousTopSetReps,volumeKg,previousVolumeKg);
}

@override
String toString() {
    return 'ExerciseComparison(exerciseId: $exerciseId, name: $name, topSetWeightKg: $topSetWeightKg, topSetReps: $topSetReps, previousTopSetWeightKg: $previousTopSetWeightKg, previousTopSetReps: $previousTopSetReps, volumeKg: $volumeKg, previousVolumeKg: $previousVolumeKg)';
}


}

/// @nodoc
abstract mixin class _$ExerciseComparisonCopyWith<$Res> implements $ExerciseComparisonCopyWith<$Res> {
  factory _$ExerciseComparisonCopyWith(_ExerciseComparison value, $Res Function(_ExerciseComparison) _then) = __$ExerciseComparisonCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String name, double? topSetWeightKg, int topSetReps, double? previousTopSetWeightKg, int? previousTopSetReps, double volumeKg, double? previousVolumeKg
});




}
/// @nodoc
class __$ExerciseComparisonCopyWithImpl<$Res>
    implements _$ExerciseComparisonCopyWith<$Res> {
  __$ExerciseComparisonCopyWithImpl(this._self, this._then);

  final _ExerciseComparison _self;
  final $Res Function(_ExerciseComparison) _then;

/// Create a copy of ExerciseComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? name = null,Object? topSetWeightKg = freezed,Object? topSetReps = null,Object? previousTopSetWeightKg = freezed,Object? previousTopSetReps = freezed,Object? volumeKg = null,Object? previousVolumeKg = freezed,}) {
  return _then(_ExerciseComparison(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,topSetWeightKg: freezed == topSetWeightKg ? _self.topSetWeightKg : topSetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,topSetReps: null == topSetReps ? _self.topSetReps : topSetReps // ignore: cast_nullable_to_non_nullable
as int,previousTopSetWeightKg: freezed == previousTopSetWeightKg ? _self.previousTopSetWeightKg : previousTopSetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,previousTopSetReps: freezed == previousTopSetReps ? _self.previousTopSetReps : previousTopSetReps // ignore: cast_nullable_to_non_nullable
as int?,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,previousVolumeKg: freezed == previousVolumeKg ? _self.previousVolumeKg : previousVolumeKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$NewRecord {

 String get exerciseId; String get name; RecordType get type; double get value; double get previousBest;
/// Create a copy of NewRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewRecordCopyWith<NewRecord> get copyWith => _$NewRecordCopyWithImpl<NewRecord>(this as NewRecord, _$identity);

  /// Serializes this NewRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NewRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewRecord&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.previousBest, _this.previousBest) || other.previousBest == _this.previousBest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NewRecord;
  return Object.hash(runtimeType,_this.exerciseId,_this.name,_this.type,_this.value,_this.previousBest);
}

@override
String toString() {
  final _this = this as NewRecord;
  return 'NewRecord(exerciseId: ${_this.exerciseId}, name: ${_this.name}, type: ${_this.type}, value: ${_this.value}, previousBest: ${_this.previousBest})';
}


}

/// @nodoc
abstract mixin class $NewRecordCopyWith<$Res>  {
  factory $NewRecordCopyWith(NewRecord value, $Res Function(NewRecord) _then) = _$NewRecordCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String name, RecordType type, double value, double previousBest
});




}
/// @nodoc
class _$NewRecordCopyWithImpl<$Res>
    implements $NewRecordCopyWith<$Res> {
  _$NewRecordCopyWithImpl(this._self, this._then);

  final NewRecord _self;
  final $Res Function(NewRecord) _then;

/// Create a copy of NewRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? name = null,Object? type = null,Object? value = null,Object? previousBest = null,}) {
  return _then(NewRecord(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,previousBest: null == previousBest ? _self.previousBest : previousBest // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NewRecord].
extension NewRecordPatterns on NewRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewRecord value)  $default,){
final _that = this;
switch (_that) {
case _NewRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewRecord value)?  $default,){
final _that = this;
switch (_that) {
case _NewRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String name,  RecordType type,  double value,  double previousBest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewRecord() when $default != null:
return $default(_that.exerciseId,_that.name,_that.type,_that.value,_that.previousBest);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String name,  RecordType type,  double value,  double previousBest)  $default,) {final _that = this;
switch (_that) {
case _NewRecord():
return $default(_that.exerciseId,_that.name,_that.type,_that.value,_that.previousBest);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String name,  RecordType type,  double value,  double previousBest)?  $default,) {final _that = this;
switch (_that) {
case _NewRecord() when $default != null:
return $default(_that.exerciseId,_that.name,_that.type,_that.value,_that.previousBest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NewRecord implements NewRecord {
  const _NewRecord({required this.exerciseId, required this.name, required this.type, required this.value, required this.previousBest});
  factory _NewRecord.fromJson(Map<String, dynamic> json) => _$NewRecordFromJson(json);

@override final  String exerciseId;
@override final  String name;
@override final  RecordType type;
@override final  double value;
@override final  double previousBest;

/// Create a copy of NewRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewRecordCopyWith<_NewRecord> get copyWith => __$NewRecordCopyWithImpl<_NewRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewRecord&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.previousBest, previousBest) || other.previousBest == previousBest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,exerciseId,name,type,value,previousBest);
}

@override
String toString() {
    return 'NewRecord(exerciseId: $exerciseId, name: $name, type: $type, value: $value, previousBest: $previousBest)';
}


}

/// @nodoc
abstract mixin class _$NewRecordCopyWith<$Res> implements $NewRecordCopyWith<$Res> {
  factory _$NewRecordCopyWith(_NewRecord value, $Res Function(_NewRecord) _then) = __$NewRecordCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String name, RecordType type, double value, double previousBest
});




}
/// @nodoc
class __$NewRecordCopyWithImpl<$Res>
    implements _$NewRecordCopyWith<$Res> {
  __$NewRecordCopyWithImpl(this._self, this._then);

  final _NewRecord _self;
  final $Res Function(_NewRecord) _then;

/// Create a copy of NewRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? name = null,Object? type = null,Object? value = null,Object? previousBest = null,}) {
  return _then(_NewRecord(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecordType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,previousBest: null == previousBest ? _self.previousBest : previousBest // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$BodyWeightEntry {

 String get id; double get weightKg; DateTime get recordedAt;
/// Create a copy of BodyWeightEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyWeightEntryCopyWith<BodyWeightEntry> get copyWith => _$BodyWeightEntryCopyWithImpl<BodyWeightEntry>(this as BodyWeightEntry, _$identity);

  /// Serializes this BodyWeightEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BodyWeightEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyWeightEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.recordedAt, _this.recordedAt) || other.recordedAt == _this.recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BodyWeightEntry;
  return Object.hash(runtimeType,_this.id,_this.weightKg,_this.recordedAt);
}

@override
String toString() {
  final _this = this as BodyWeightEntry;
  return 'BodyWeightEntry(id: ${_this.id}, weightKg: ${_this.weightKg}, recordedAt: ${_this.recordedAt})';
}


}

/// @nodoc
abstract mixin class $BodyWeightEntryCopyWith<$Res>  {
  factory $BodyWeightEntryCopyWith(BodyWeightEntry value, $Res Function(BodyWeightEntry) _then) = _$BodyWeightEntryCopyWithImpl;
@useResult
$Res call({
 String id, double weightKg, DateTime recordedAt
});




}
/// @nodoc
class _$BodyWeightEntryCopyWithImpl<$Res>
    implements $BodyWeightEntryCopyWith<$Res> {
  _$BodyWeightEntryCopyWithImpl(this._self, this._then);

  final BodyWeightEntry _self;
  final $Res Function(BodyWeightEntry) _then;

/// Create a copy of BodyWeightEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? weightKg = null,Object? recordedAt = null,}) {
  return _then(BodyWeightEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyWeightEntry].
extension BodyWeightEntryPatterns on BodyWeightEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyWeightEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyWeightEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyWeightEntry value)  $default,){
final _that = this;
switch (_that) {
case _BodyWeightEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyWeightEntry value)?  $default,){
final _that = this;
switch (_that) {
case _BodyWeightEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double weightKg,  DateTime recordedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyWeightEntry() when $default != null:
return $default(_that.id,_that.weightKg,_that.recordedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double weightKg,  DateTime recordedAt)  $default,) {final _that = this;
switch (_that) {
case _BodyWeightEntry():
return $default(_that.id,_that.weightKg,_that.recordedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double weightKg,  DateTime recordedAt)?  $default,) {final _that = this;
switch (_that) {
case _BodyWeightEntry() when $default != null:
return $default(_that.id,_that.weightKg,_that.recordedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyWeightEntry implements BodyWeightEntry {
  const _BodyWeightEntry({required this.id, required this.weightKg, required this.recordedAt});
  factory _BodyWeightEntry.fromJson(Map<String, dynamic> json) => _$BodyWeightEntryFromJson(json);

@override final  String id;
@override final  double weightKg;
@override final  DateTime recordedAt;

/// Create a copy of BodyWeightEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyWeightEntryCopyWith<_BodyWeightEntry> get copyWith => __$BodyWeightEntryCopyWithImpl<_BodyWeightEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyWeightEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyWeightEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,weightKg,recordedAt);
}

@override
String toString() {
    return 'BodyWeightEntry(id: $id, weightKg: $weightKg, recordedAt: $recordedAt)';
}


}

/// @nodoc
abstract mixin class _$BodyWeightEntryCopyWith<$Res> implements $BodyWeightEntryCopyWith<$Res> {
  factory _$BodyWeightEntryCopyWith(_BodyWeightEntry value, $Res Function(_BodyWeightEntry) _then) = __$BodyWeightEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, double weightKg, DateTime recordedAt
});




}
/// @nodoc
class __$BodyWeightEntryCopyWithImpl<$Res>
    implements _$BodyWeightEntryCopyWith<$Res> {
  __$BodyWeightEntryCopyWithImpl(this._self, this._then);

  final _BodyWeightEntry _self;
  final $Res Function(_BodyWeightEntry) _then;

/// Create a copy of BodyWeightEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? weightKg = null,Object? recordedAt = null,}) {
  return _then(_BodyWeightEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
