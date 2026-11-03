// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSession {

 String get id; String get name; String? get workoutPlanId; DateTime get startedAt; DateTime? get completedAt; String? get notes; List<SessionExercise> get exercises; List<CardioEntry> get cardio;
/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<WorkoutSession> get copyWith => _$WorkoutSessionCopyWithImpl<WorkoutSession>(this as WorkoutSession, _$identity);

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.workoutPlanId, _this.workoutPlanId) || other.workoutPlanId == _this.workoutPlanId)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&const DeepCollectionEquality().equals(other.cardio, _this.cardio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutSession;
  return Object.hash(runtimeType,_this.id,_this.name,_this.workoutPlanId,_this.startedAt,_this.completedAt,_this.notes,const DeepCollectionEquality().hash(_this.exercises),const DeepCollectionEquality().hash(_this.cardio));
}

@override
String toString() {
  final _this = this as WorkoutSession;
  return 'WorkoutSession(id: ${_this.id}, name: ${_this.name}, workoutPlanId: ${_this.workoutPlanId}, startedAt: ${_this.startedAt}, completedAt: ${_this.completedAt}, notes: ${_this.notes}, exercises: ${_this.exercises}, cardio: ${_this.cardio})';
}


}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res>  {
  factory $WorkoutSessionCopyWith(WorkoutSession value, $Res Function(WorkoutSession) _then) = _$WorkoutSessionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? workoutPlanId, DateTime startedAt, DateTime? completedAt, String? notes, List<SessionExercise> exercises, List<CardioEntry> cardio
});




}
/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? workoutPlanId = freezed,Object? startedAt = null,Object? completedAt = freezed,Object? notes = freezed,Object? exercises = null,Object? cardio = null,}) {
  return _then(WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,workoutPlanId: freezed == workoutPlanId ? _self.workoutPlanId : workoutPlanId // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,cardio: null == cardio ? _self.cardio : cardio // ignore: cast_nullable_to_non_nullable
as List<CardioEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSession value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSession value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? workoutPlanId,  DateTime startedAt,  DateTime? completedAt,  String? notes,  List<SessionExercise> exercises,  List<CardioEntry> cardio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.name,_that.workoutPlanId,_that.startedAt,_that.completedAt,_that.notes,_that.exercises,_that.cardio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? workoutPlanId,  DateTime startedAt,  DateTime? completedAt,  String? notes,  List<SessionExercise> exercises,  List<CardioEntry> cardio)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession():
return $default(_that.id,_that.name,_that.workoutPlanId,_that.startedAt,_that.completedAt,_that.notes,_that.exercises,_that.cardio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? workoutPlanId,  DateTime startedAt,  DateTime? completedAt,  String? notes,  List<SessionExercise> exercises,  List<CardioEntry> cardio)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.name,_that.workoutPlanId,_that.startedAt,_that.completedAt,_that.notes,_that.exercises,_that.cardio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSession extends WorkoutSession {
  const _WorkoutSession({required this.id, required this.name, this.workoutPlanId, required this.startedAt, this.completedAt, this.notes,  List<SessionExercise> exercises = const [],  List<CardioEntry> cardio = const []}): _exercises = exercises,_cardio = cardio,super._();
  factory _WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? workoutPlanId;
@override final  DateTime startedAt;
@override final  DateTime? completedAt;
@override final  String? notes;
 final  List<SessionExercise> _exercises;
@override@JsonKey() List<SessionExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

 final  List<CardioEntry> _cardio;
@override@JsonKey() List<CardioEntry> get cardio {
  if (_cardio is EqualUnmodifiableListView) return _cardio;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cardio);
}


/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSessionCopyWith<_WorkoutSession> get copyWith => __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSession&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.workoutPlanId, workoutPlanId) || other.workoutPlanId == workoutPlanId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&const DeepCollectionEquality().equals(other.cardio, _cardio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,workoutPlanId,startedAt,completedAt,notes,const DeepCollectionEquality().hash(_exercises),const DeepCollectionEquality().hash(_cardio));
}

@override
String toString() {
    return 'WorkoutSession(id: $id, name: $name, workoutPlanId: $workoutPlanId, startedAt: $startedAt, completedAt: $completedAt, notes: $notes, exercises: $exercises, cardio: $cardio)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res> implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(_WorkoutSession value, $Res Function(_WorkoutSession) _then) = __$WorkoutSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? workoutPlanId, DateTime startedAt, DateTime? completedAt, String? notes, List<SessionExercise> exercises, List<CardioEntry> cardio
});




}
/// @nodoc
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? workoutPlanId = freezed,Object? startedAt = null,Object? completedAt = freezed,Object? notes = freezed,Object? exercises = null,Object? cardio = null,}) {
  return _then(_WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,workoutPlanId: freezed == workoutPlanId ? _self.workoutPlanId : workoutPlanId // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,cardio: null == cardio ? _self._cardio : cardio // ignore: cast_nullable_to_non_nullable
as List<CardioEntry>,
  ));
}


}


/// @nodoc
mixin _$SessionExercise {

 String get id; String get exerciseId; String get name; String get gifUrl; String get bodyPart; int get order; int? get targetSets; int? get targetReps; List<SessionSet> get sets; LastPerformance? get lastPerformance; Suggestion? get suggestion;
/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionExerciseCopyWith<SessionExercise> get copyWith => _$SessionExerciseCopyWithImpl<SessionExercise>(this as SessionExercise, _$identity);

  /// Serializes this SessionExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionExercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.gifUrl, _this.gifUrl) || other.gifUrl == _this.gifUrl)&&(identical(other.bodyPart, _this.bodyPart) || other.bodyPart == _this.bodyPart)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.targetSets, _this.targetSets) || other.targetSets == _this.targetSets)&&(identical(other.targetReps, _this.targetReps) || other.targetReps == _this.targetReps)&&const DeepCollectionEquality().equals(other.sets, _this.sets)&&(identical(other.lastPerformance, _this.lastPerformance) || other.lastPerformance == _this.lastPerformance)&&(identical(other.suggestion, _this.suggestion) || other.suggestion == _this.suggestion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionExercise;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.name,_this.gifUrl,_this.bodyPart,_this.order,_this.targetSets,_this.targetReps,const DeepCollectionEquality().hash(_this.sets),_this.lastPerformance,_this.suggestion);
}

@override
String toString() {
  final _this = this as SessionExercise;
  return 'SessionExercise(id: ${_this.id}, exerciseId: ${_this.exerciseId}, name: ${_this.name}, gifUrl: ${_this.gifUrl}, bodyPart: ${_this.bodyPart}, order: ${_this.order}, targetSets: ${_this.targetSets}, targetReps: ${_this.targetReps}, sets: ${_this.sets}, lastPerformance: ${_this.lastPerformance}, suggestion: ${_this.suggestion})';
}


}

/// @nodoc
abstract mixin class $SessionExerciseCopyWith<$Res>  {
  factory $SessionExerciseCopyWith(SessionExercise value, $Res Function(SessionExercise) _then) = _$SessionExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String name, String gifUrl, String bodyPart, int order, int? targetSets, int? targetReps, List<SessionSet> sets, LastPerformance? lastPerformance, Suggestion? suggestion
});


$LastPerformanceCopyWith<$Res>? get lastPerformance;$SuggestionCopyWith<$Res>? get suggestion;

}
/// @nodoc
class _$SessionExerciseCopyWithImpl<$Res>
    implements $SessionExerciseCopyWith<$Res> {
  _$SessionExerciseCopyWithImpl(this._self, this._then);

  final SessionExercise _self;
  final $Res Function(SessionExercise) _then;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? gifUrl = null,Object? bodyPart = null,Object? order = null,Object? targetSets = freezed,Object? targetReps = freezed,Object? sets = null,Object? lastPerformance = freezed,Object? suggestion = freezed,}) {
  return _then(SessionExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gifUrl: null == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String,bodyPart: null == bodyPart ? _self.bodyPart : bodyPart // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,targetSets: freezed == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int?,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSet>,lastPerformance: freezed == lastPerformance ? _self.lastPerformance : lastPerformance // ignore: cast_nullable_to_non_nullable
as LastPerformance?,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as Suggestion?,
  ));
}
/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastPerformanceCopyWith<$Res>? get lastPerformance {
    if (_self.lastPerformance == null) {
    return null;
  }

  return $LastPerformanceCopyWith<$Res>(_self.lastPerformance!, (value) {
    return _then(_self.copyWith(lastPerformance: value));
  });
}/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SuggestionCopyWith<$Res>? get suggestion {
    if (_self.suggestion == null) {
    return null;
  }

  return $SuggestionCopyWith<$Res>(_self.suggestion!, (value) {
    return _then(_self.copyWith(suggestion: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionExercise].
extension SessionExercisePatterns on SessionExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionExercise value)  $default,){
final _that = this;
switch (_that) {
case _SessionExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionExercise value)?  $default,){
final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  String gifUrl,  String bodyPart,  int order,  int? targetSets,  int? targetReps,  List<SessionSet> sets,  LastPerformance? lastPerformance,  Suggestion? suggestion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.gifUrl,_that.bodyPart,_that.order,_that.targetSets,_that.targetReps,_that.sets,_that.lastPerformance,_that.suggestion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  String gifUrl,  String bodyPart,  int order,  int? targetSets,  int? targetReps,  List<SessionSet> sets,  LastPerformance? lastPerformance,  Suggestion? suggestion)  $default,) {final _that = this;
switch (_that) {
case _SessionExercise():
return $default(_that.id,_that.exerciseId,_that.name,_that.gifUrl,_that.bodyPart,_that.order,_that.targetSets,_that.targetReps,_that.sets,_that.lastPerformance,_that.suggestion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String name,  String gifUrl,  String bodyPart,  int order,  int? targetSets,  int? targetReps,  List<SessionSet> sets,  LastPerformance? lastPerformance,  Suggestion? suggestion)?  $default,) {final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.gifUrl,_that.bodyPart,_that.order,_that.targetSets,_that.targetReps,_that.sets,_that.lastPerformance,_that.suggestion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionExercise extends SessionExercise {
  const _SessionExercise({required this.id, required this.exerciseId, required this.name, required this.gifUrl, required this.bodyPart, required this.order, this.targetSets, this.targetReps,  List<SessionSet> sets = const [], this.lastPerformance, this.suggestion}): _sets = sets,super._();
  factory _SessionExercise.fromJson(Map<String, dynamic> json) => _$SessionExerciseFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String name;
@override final  String gifUrl;
@override final  String bodyPart;
@override final  int order;
@override final  int? targetSets;
@override final  int? targetReps;
 final  List<SessionSet> _sets;
@override@JsonKey() List<SessionSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override final  LastPerformance? lastPerformance;
@override final  Suggestion? suggestion;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionExerciseCopyWith<_SessionExercise> get copyWith => __$SessionExerciseCopyWithImpl<_SessionExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&(identical(other.bodyPart, bodyPart) || other.bodyPart == bodyPart)&&(identical(other.order, order) || other.order == order)&&(identical(other.targetSets, targetSets) || other.targetSets == targetSets)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&const DeepCollectionEquality().equals(other.sets, _sets)&&(identical(other.lastPerformance, lastPerformance) || other.lastPerformance == lastPerformance)&&(identical(other.suggestion, suggestion) || other.suggestion == suggestion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,name,gifUrl,bodyPart,order,targetSets,targetReps,const DeepCollectionEquality().hash(_sets),lastPerformance,suggestion);
}

@override
String toString() {
    return 'SessionExercise(id: $id, exerciseId: $exerciseId, name: $name, gifUrl: $gifUrl, bodyPart: $bodyPart, order: $order, targetSets: $targetSets, targetReps: $targetReps, sets: $sets, lastPerformance: $lastPerformance, suggestion: $suggestion)';
}


}

/// @nodoc
abstract mixin class _$SessionExerciseCopyWith<$Res> implements $SessionExerciseCopyWith<$Res> {
  factory _$SessionExerciseCopyWith(_SessionExercise value, $Res Function(_SessionExercise) _then) = __$SessionExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String name, String gifUrl, String bodyPart, int order, int? targetSets, int? targetReps, List<SessionSet> sets, LastPerformance? lastPerformance, Suggestion? suggestion
});


@override $LastPerformanceCopyWith<$Res>? get lastPerformance;@override $SuggestionCopyWith<$Res>? get suggestion;

}
/// @nodoc
class __$SessionExerciseCopyWithImpl<$Res>
    implements _$SessionExerciseCopyWith<$Res> {
  __$SessionExerciseCopyWithImpl(this._self, this._then);

  final _SessionExercise _self;
  final $Res Function(_SessionExercise) _then;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? gifUrl = null,Object? bodyPart = null,Object? order = null,Object? targetSets = freezed,Object? targetReps = freezed,Object? sets = null,Object? lastPerformance = freezed,Object? suggestion = freezed,}) {
  return _then(_SessionExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gifUrl: null == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String,bodyPart: null == bodyPart ? _self.bodyPart : bodyPart // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,targetSets: freezed == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int?,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSet>,lastPerformance: freezed == lastPerformance ? _self.lastPerformance : lastPerformance // ignore: cast_nullable_to_non_nullable
as LastPerformance?,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as Suggestion?,
  ));
}

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastPerformanceCopyWith<$Res>? get lastPerformance {
    if (_self.lastPerformance == null) {
    return null;
  }

  return $LastPerformanceCopyWith<$Res>(_self.lastPerformance!, (value) {
    return _then(_self.copyWith(lastPerformance: value));
  });
}/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SuggestionCopyWith<$Res>? get suggestion {
    if (_self.suggestion == null) {
    return null;
  }

  return $SuggestionCopyWith<$Res>(_self.suggestion!, (value) {
    return _then(_self.copyWith(suggestion: value));
  });
}
}


/// @nodoc
mixin _$SessionSet {

 String get id; int get setNumber; int get reps; double? get weightKg;
/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSetCopyWith<SessionSet> get copyWith => _$SessionSetCopyWithImpl<SessionSet>(this as SessionSet, _$identity);

  /// Serializes this SessionSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionSet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.setNumber, _this.setNumber) || other.setNumber == _this.setNumber)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionSet;
  return Object.hash(runtimeType,_this.id,_this.setNumber,_this.reps,_this.weightKg);
}

@override
String toString() {
  final _this = this as SessionSet;
  return 'SessionSet(id: ${_this.id}, setNumber: ${_this.setNumber}, reps: ${_this.reps}, weightKg: ${_this.weightKg})';
}


}

/// @nodoc
abstract mixin class $SessionSetCopyWith<$Res>  {
  factory $SessionSetCopyWith(SessionSet value, $Res Function(SessionSet) _then) = _$SessionSetCopyWithImpl;
@useResult
$Res call({
 String id, int setNumber, int reps, double? weightKg
});




}
/// @nodoc
class _$SessionSetCopyWithImpl<$Res>
    implements $SessionSetCopyWith<$Res> {
  _$SessionSetCopyWithImpl(this._self, this._then);

  final SessionSet _self;
  final $Res Function(SessionSet) _then;

/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? setNumber = null,Object? reps = null,Object? weightKg = freezed,}) {
  return _then(SessionSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSet].
extension SessionSetPatterns on SessionSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSet value)  $default,){
final _that = this;
switch (_that) {
case _SessionSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSet value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int setNumber,  int reps,  double? weightKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
return $default(_that.id,_that.setNumber,_that.reps,_that.weightKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int setNumber,  int reps,  double? weightKg)  $default,) {final _that = this;
switch (_that) {
case _SessionSet():
return $default(_that.id,_that.setNumber,_that.reps,_that.weightKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int setNumber,  int reps,  double? weightKg)?  $default,) {final _that = this;
switch (_that) {
case _SessionSet() when $default != null:
return $default(_that.id,_that.setNumber,_that.reps,_that.weightKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionSet implements SessionSet {
  const _SessionSet({required this.id, required this.setNumber, required this.reps, this.weightKg});
  factory _SessionSet.fromJson(Map<String, dynamic> json) => _$SessionSetFromJson(json);

@override final  String id;
@override final  int setNumber;
@override final  int reps;
@override final  double? weightKg;

/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSetCopyWith<_SessionSet> get copyWith => __$SessionSetCopyWithImpl<_SessionSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionSetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSet&&(identical(other.id, id) || other.id == id)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,setNumber,reps,weightKg);
}

@override
String toString() {
    return 'SessionSet(id: $id, setNumber: $setNumber, reps: $reps, weightKg: $weightKg)';
}


}

/// @nodoc
abstract mixin class _$SessionSetCopyWith<$Res> implements $SessionSetCopyWith<$Res> {
  factory _$SessionSetCopyWith(_SessionSet value, $Res Function(_SessionSet) _then) = __$SessionSetCopyWithImpl;
@override @useResult
$Res call({
 String id, int setNumber, int reps, double? weightKg
});




}
/// @nodoc
class __$SessionSetCopyWithImpl<$Res>
    implements _$SessionSetCopyWith<$Res> {
  __$SessionSetCopyWithImpl(this._self, this._then);

  final _SessionSet _self;
  final $Res Function(_SessionSet) _then;

/// Create a copy of SessionSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? setNumber = null,Object? reps = null,Object? weightKg = freezed,}) {
  return _then(_SessionSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$LastPerformance {

 DateTime get performedAt; List<SessionSet> get sets;
/// Create a copy of LastPerformance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastPerformanceCopyWith<LastPerformance> get copyWith => _$LastPerformanceCopyWithImpl<LastPerformance>(this as LastPerformance, _$identity);

  /// Serializes this LastPerformance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LastPerformance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastPerformance&&(identical(other.performedAt, _this.performedAt) || other.performedAt == _this.performedAt)&&const DeepCollectionEquality().equals(other.sets, _this.sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LastPerformance;
  return Object.hash(runtimeType,_this.performedAt,const DeepCollectionEquality().hash(_this.sets));
}

@override
String toString() {
  final _this = this as LastPerformance;
  return 'LastPerformance(performedAt: ${_this.performedAt}, sets: ${_this.sets})';
}


}

/// @nodoc
abstract mixin class $LastPerformanceCopyWith<$Res>  {
  factory $LastPerformanceCopyWith(LastPerformance value, $Res Function(LastPerformance) _then) = _$LastPerformanceCopyWithImpl;
@useResult
$Res call({
 DateTime performedAt, List<SessionSet> sets
});




}
/// @nodoc
class _$LastPerformanceCopyWithImpl<$Res>
    implements $LastPerformanceCopyWith<$Res> {
  _$LastPerformanceCopyWithImpl(this._self, this._then);

  final LastPerformance _self;
  final $Res Function(LastPerformance) _then;

/// Create a copy of LastPerformance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? performedAt = null,Object? sets = null,}) {
  return _then(LastPerformance(
performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSet>,
  ));
}

}


/// Adds pattern-matching-related methods to [LastPerformance].
extension LastPerformancePatterns on LastPerformance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastPerformance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastPerformance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastPerformance value)  $default,){
final _that = this;
switch (_that) {
case _LastPerformance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastPerformance value)?  $default,){
final _that = this;
switch (_that) {
case _LastPerformance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime performedAt,  List<SessionSet> sets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastPerformance() when $default != null:
return $default(_that.performedAt,_that.sets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime performedAt,  List<SessionSet> sets)  $default,) {final _that = this;
switch (_that) {
case _LastPerformance():
return $default(_that.performedAt,_that.sets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime performedAt,  List<SessionSet> sets)?  $default,) {final _that = this;
switch (_that) {
case _LastPerformance() when $default != null:
return $default(_that.performedAt,_that.sets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastPerformance implements LastPerformance {
  const _LastPerformance({required this.performedAt,  List<SessionSet> sets = const []}): _sets = sets;
  factory _LastPerformance.fromJson(Map<String, dynamic> json) => _$LastPerformanceFromJson(json);

@override final  DateTime performedAt;
 final  List<SessionSet> _sets;
@override@JsonKey() List<SessionSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}


/// Create a copy of LastPerformance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastPerformanceCopyWith<_LastPerformance> get copyWith => __$LastPerformanceCopyWithImpl<_LastPerformance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastPerformanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastPerformance&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&const DeepCollectionEquality().equals(other.sets, _sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,performedAt,const DeepCollectionEquality().hash(_sets));
}

@override
String toString() {
    return 'LastPerformance(performedAt: $performedAt, sets: $sets)';
}


}

/// @nodoc
abstract mixin class _$LastPerformanceCopyWith<$Res> implements $LastPerformanceCopyWith<$Res> {
  factory _$LastPerformanceCopyWith(_LastPerformance value, $Res Function(_LastPerformance) _then) = __$LastPerformanceCopyWithImpl;
@override @useResult
$Res call({
 DateTime performedAt, List<SessionSet> sets
});




}
/// @nodoc
class __$LastPerformanceCopyWithImpl<$Res>
    implements _$LastPerformanceCopyWith<$Res> {
  __$LastPerformanceCopyWithImpl(this._self, this._then);

  final _LastPerformance _self;
  final $Res Function(_LastPerformance) _then;

/// Create a copy of LastPerformance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? performedAt = null,Object? sets = null,}) {
  return _then(_LastPerformance(
performedAt: null == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<SessionSet>,
  ));
}


}


/// @nodoc
mixin _$Suggestion {

 double? get weightKg; int get reps; SuggestionReason get reason;
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestionCopyWith<Suggestion> get copyWith => _$SuggestionCopyWithImpl<Suggestion>(this as Suggestion, _$identity);

  /// Serializes this Suggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Suggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Suggestion&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Suggestion;
  return Object.hash(runtimeType,_this.weightKg,_this.reps,_this.reason);
}

@override
String toString() {
  final _this = this as Suggestion;
  return 'Suggestion(weightKg: ${_this.weightKg}, reps: ${_this.reps}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $SuggestionCopyWith<$Res>  {
  factory $SuggestionCopyWith(Suggestion value, $Res Function(Suggestion) _then) = _$SuggestionCopyWithImpl;
@useResult
$Res call({
 double? weightKg, int reps, SuggestionReason reason
});




}
/// @nodoc
class _$SuggestionCopyWithImpl<$Res>
    implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._self, this._then);

  final Suggestion _self;
  final $Res Function(Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weightKg = freezed,Object? reps = null,Object? reason = null,}) {
  return _then(Suggestion(
weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as SuggestionReason,
  ));
}

}


/// Adds pattern-matching-related methods to [Suggestion].
extension SuggestionPatterns on Suggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Suggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Suggestion value)  $default,){
final _that = this;
switch (_that) {
case _Suggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Suggestion value)?  $default,){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? weightKg,  int reps,  SuggestionReason reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.weightKg,_that.reps,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? weightKg,  int reps,  SuggestionReason reason)  $default,) {final _that = this;
switch (_that) {
case _Suggestion():
return $default(_that.weightKg,_that.reps,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? weightKg,  int reps,  SuggestionReason reason)?  $default,) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.weightKg,_that.reps,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Suggestion extends Suggestion {
  const _Suggestion({this.weightKg, required this.reps, required this.reason}): super._();
  factory _Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

@override final  double? weightKg;
@override final  int reps;
@override final  SuggestionReason reason;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestionCopyWith<_Suggestion> get copyWith => __$SuggestionCopyWithImpl<_Suggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suggestion&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,weightKg,reps,reason);
}

@override
String toString() {
    return 'Suggestion(weightKg: $weightKg, reps: $reps, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$SuggestionCopyWith<$Res> implements $SuggestionCopyWith<$Res> {
  factory _$SuggestionCopyWith(_Suggestion value, $Res Function(_Suggestion) _then) = __$SuggestionCopyWithImpl;
@override @useResult
$Res call({
 double? weightKg, int reps, SuggestionReason reason
});




}
/// @nodoc
class __$SuggestionCopyWithImpl<$Res>
    implements _$SuggestionCopyWith<$Res> {
  __$SuggestionCopyWithImpl(this._self, this._then);

  final _Suggestion _self;
  final $Res Function(_Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weightKg = freezed,Object? reps = null,Object? reason = null,}) {
  return _then(_Suggestion(
weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as SuggestionReason,
  ));
}


}


/// @nodoc
mixin _$CardioEntry {

 String get id; CardioMachine get machine; int get durationSeconds; double? get speedKmh; double? get inclinePercent; double? get distanceKm; int? get estimatedCalories;
/// Create a copy of CardioEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardioEntryCopyWith<CardioEntry> get copyWith => _$CardioEntryCopyWithImpl<CardioEntry>(this as CardioEntry, _$identity);

  /// Serializes this CardioEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardioEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardioEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.machine, _this.machine) || other.machine == _this.machine)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.speedKmh, _this.speedKmh) || other.speedKmh == _this.speedKmh)&&(identical(other.inclinePercent, _this.inclinePercent) || other.inclinePercent == _this.inclinePercent)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.estimatedCalories, _this.estimatedCalories) || other.estimatedCalories == _this.estimatedCalories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardioEntry;
  return Object.hash(runtimeType,_this.id,_this.machine,_this.durationSeconds,_this.speedKmh,_this.inclinePercent,_this.distanceKm,_this.estimatedCalories);
}

@override
String toString() {
  final _this = this as CardioEntry;
  return 'CardioEntry(id: ${_this.id}, machine: ${_this.machine}, durationSeconds: ${_this.durationSeconds}, speedKmh: ${_this.speedKmh}, inclinePercent: ${_this.inclinePercent}, distanceKm: ${_this.distanceKm}, estimatedCalories: ${_this.estimatedCalories})';
}


}

/// @nodoc
abstract mixin class $CardioEntryCopyWith<$Res>  {
  factory $CardioEntryCopyWith(CardioEntry value, $Res Function(CardioEntry) _then) = _$CardioEntryCopyWithImpl;
@useResult
$Res call({
 String id, CardioMachine machine, int durationSeconds, double? speedKmh, double? inclinePercent, double? distanceKm, int? estimatedCalories
});




}
/// @nodoc
class _$CardioEntryCopyWithImpl<$Res>
    implements $CardioEntryCopyWith<$Res> {
  _$CardioEntryCopyWithImpl(this._self, this._then);

  final CardioEntry _self;
  final $Res Function(CardioEntry) _then;

/// Create a copy of CardioEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? machine = null,Object? durationSeconds = null,Object? speedKmh = freezed,Object? inclinePercent = freezed,Object? distanceKm = freezed,Object? estimatedCalories = freezed,}) {
  return _then(CardioEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,machine: null == machine ? _self.machine : machine // ignore: cast_nullable_to_non_nullable
as CardioMachine,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,inclinePercent: freezed == inclinePercent ? _self.inclinePercent : inclinePercent // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,estimatedCalories: freezed == estimatedCalories ? _self.estimatedCalories : estimatedCalories // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardioEntry].
extension CardioEntryPatterns on CardioEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardioEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardioEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardioEntry value)  $default,){
final _that = this;
switch (_that) {
case _CardioEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardioEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CardioEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CardioMachine machine,  int durationSeconds,  double? speedKmh,  double? inclinePercent,  double? distanceKm,  int? estimatedCalories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardioEntry() when $default != null:
return $default(_that.id,_that.machine,_that.durationSeconds,_that.speedKmh,_that.inclinePercent,_that.distanceKm,_that.estimatedCalories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CardioMachine machine,  int durationSeconds,  double? speedKmh,  double? inclinePercent,  double? distanceKm,  int? estimatedCalories)  $default,) {final _that = this;
switch (_that) {
case _CardioEntry():
return $default(_that.id,_that.machine,_that.durationSeconds,_that.speedKmh,_that.inclinePercent,_that.distanceKm,_that.estimatedCalories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CardioMachine machine,  int durationSeconds,  double? speedKmh,  double? inclinePercent,  double? distanceKm,  int? estimatedCalories)?  $default,) {final _that = this;
switch (_that) {
case _CardioEntry() when $default != null:
return $default(_that.id,_that.machine,_that.durationSeconds,_that.speedKmh,_that.inclinePercent,_that.distanceKm,_that.estimatedCalories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardioEntry implements CardioEntry {
  const _CardioEntry({required this.id, required this.machine, required this.durationSeconds, this.speedKmh, this.inclinePercent, this.distanceKm, this.estimatedCalories});
  factory _CardioEntry.fromJson(Map<String, dynamic> json) => _$CardioEntryFromJson(json);

@override final  String id;
@override final  CardioMachine machine;
@override final  int durationSeconds;
@override final  double? speedKmh;
@override final  double? inclinePercent;
@override final  double? distanceKm;
@override final  int? estimatedCalories;

/// Create a copy of CardioEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardioEntryCopyWith<_CardioEntry> get copyWith => __$CardioEntryCopyWithImpl<_CardioEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardioEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardioEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.machine, machine) || other.machine == machine)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.inclinePercent, inclinePercent) || other.inclinePercent == inclinePercent)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.estimatedCalories, estimatedCalories) || other.estimatedCalories == estimatedCalories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,machine,durationSeconds,speedKmh,inclinePercent,distanceKm,estimatedCalories);
}

@override
String toString() {
    return 'CardioEntry(id: $id, machine: $machine, durationSeconds: $durationSeconds, speedKmh: $speedKmh, inclinePercent: $inclinePercent, distanceKm: $distanceKm, estimatedCalories: $estimatedCalories)';
}


}

/// @nodoc
abstract mixin class _$CardioEntryCopyWith<$Res> implements $CardioEntryCopyWith<$Res> {
  factory _$CardioEntryCopyWith(_CardioEntry value, $Res Function(_CardioEntry) _then) = __$CardioEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, CardioMachine machine, int durationSeconds, double? speedKmh, double? inclinePercent, double? distanceKm, int? estimatedCalories
});




}
/// @nodoc
class __$CardioEntryCopyWithImpl<$Res>
    implements _$CardioEntryCopyWith<$Res> {
  __$CardioEntryCopyWithImpl(this._self, this._then);

  final _CardioEntry _self;
  final $Res Function(_CardioEntry) _then;

/// Create a copy of CardioEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? machine = null,Object? durationSeconds = null,Object? speedKmh = freezed,Object? inclinePercent = freezed,Object? distanceKm = freezed,Object? estimatedCalories = freezed,}) {
  return _then(_CardioEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,machine: null == machine ? _self.machine : machine // ignore: cast_nullable_to_non_nullable
as CardioMachine,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,speedKmh: freezed == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double?,inclinePercent: freezed == inclinePercent ? _self.inclinePercent : inclinePercent // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,estimatedCalories: freezed == estimatedCalories ? _self.estimatedCalories : estimatedCalories // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SessionSummary {

 String get id; String get name; DateTime get startedAt; DateTime get completedAt; int get durationSeconds; int get exerciseCount; int get setCount; double get totalVolumeKg; int get cardioDurationSeconds; int get estimatedCalories;
/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSummaryCopyWith<SessionSummary> get copyWith => _$SessionSummaryCopyWithImpl<SessionSummary>(this as SessionSummary, _$identity);

  /// Serializes this SessionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.exerciseCount, _this.exerciseCount) || other.exerciseCount == _this.exerciseCount)&&(identical(other.setCount, _this.setCount) || other.setCount == _this.setCount)&&(identical(other.totalVolumeKg, _this.totalVolumeKg) || other.totalVolumeKg == _this.totalVolumeKg)&&(identical(other.cardioDurationSeconds, _this.cardioDurationSeconds) || other.cardioDurationSeconds == _this.cardioDurationSeconds)&&(identical(other.estimatedCalories, _this.estimatedCalories) || other.estimatedCalories == _this.estimatedCalories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionSummary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.startedAt,_this.completedAt,_this.durationSeconds,_this.exerciseCount,_this.setCount,_this.totalVolumeKg,_this.cardioDurationSeconds,_this.estimatedCalories);
}

@override
String toString() {
  final _this = this as SessionSummary;
  return 'SessionSummary(id: ${_this.id}, name: ${_this.name}, startedAt: ${_this.startedAt}, completedAt: ${_this.completedAt}, durationSeconds: ${_this.durationSeconds}, exerciseCount: ${_this.exerciseCount}, setCount: ${_this.setCount}, totalVolumeKg: ${_this.totalVolumeKg}, cardioDurationSeconds: ${_this.cardioDurationSeconds}, estimatedCalories: ${_this.estimatedCalories})';
}


}

/// @nodoc
abstract mixin class $SessionSummaryCopyWith<$Res>  {
  factory $SessionSummaryCopyWith(SessionSummary value, $Res Function(SessionSummary) _then) = _$SessionSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime startedAt, DateTime completedAt, int durationSeconds, int exerciseCount, int setCount, double totalVolumeKg, int cardioDurationSeconds, int estimatedCalories
});




}
/// @nodoc
class _$SessionSummaryCopyWithImpl<$Res>
    implements $SessionSummaryCopyWith<$Res> {
  _$SessionSummaryCopyWithImpl(this._self, this._then);

  final SessionSummary _self;
  final $Res Function(SessionSummary) _then;

/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? startedAt = null,Object? completedAt = null,Object? durationSeconds = null,Object? exerciseCount = null,Object? setCount = null,Object? totalVolumeKg = null,Object? cardioDurationSeconds = null,Object? estimatedCalories = null,}) {
  return _then(SessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,setCount: null == setCount ? _self.setCount : setCount // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,cardioDurationSeconds: null == cardioDurationSeconds ? _self.cardioDurationSeconds : cardioDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,estimatedCalories: null == estimatedCalories ? _self.estimatedCalories : estimatedCalories // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSummary].
extension SessionSummaryPatterns on SessionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSummary value)  $default,){
final _that = this;
switch (_that) {
case _SessionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startedAt,  DateTime completedAt,  int durationSeconds,  int exerciseCount,  int setCount,  double totalVolumeKg,  int cardioDurationSeconds,  int estimatedCalories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
return $default(_that.id,_that.name,_that.startedAt,_that.completedAt,_that.durationSeconds,_that.exerciseCount,_that.setCount,_that.totalVolumeKg,_that.cardioDurationSeconds,_that.estimatedCalories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime startedAt,  DateTime completedAt,  int durationSeconds,  int exerciseCount,  int setCount,  double totalVolumeKg,  int cardioDurationSeconds,  int estimatedCalories)  $default,) {final _that = this;
switch (_that) {
case _SessionSummary():
return $default(_that.id,_that.name,_that.startedAt,_that.completedAt,_that.durationSeconds,_that.exerciseCount,_that.setCount,_that.totalVolumeKg,_that.cardioDurationSeconds,_that.estimatedCalories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime startedAt,  DateTime completedAt,  int durationSeconds,  int exerciseCount,  int setCount,  double totalVolumeKg,  int cardioDurationSeconds,  int estimatedCalories)?  $default,) {final _that = this;
switch (_that) {
case _SessionSummary() when $default != null:
return $default(_that.id,_that.name,_that.startedAt,_that.completedAt,_that.durationSeconds,_that.exerciseCount,_that.setCount,_that.totalVolumeKg,_that.cardioDurationSeconds,_that.estimatedCalories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionSummary implements SessionSummary {
  const _SessionSummary({required this.id, required this.name, required this.startedAt, required this.completedAt, required this.durationSeconds, required this.exerciseCount, required this.setCount, required this.totalVolumeKg, required this.cardioDurationSeconds, required this.estimatedCalories});
  factory _SessionSummary.fromJson(Map<String, dynamic> json) => _$SessionSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime startedAt;
@override final  DateTime completedAt;
@override final  int durationSeconds;
@override final  int exerciseCount;
@override final  int setCount;
@override final  double totalVolumeKg;
@override final  int cardioDurationSeconds;
@override final  int estimatedCalories;

/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSummaryCopyWith<_SessionSummary> get copyWith => __$SessionSummaryCopyWithImpl<_SessionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.setCount, setCount) || other.setCount == setCount)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.cardioDurationSeconds, cardioDurationSeconds) || other.cardioDurationSeconds == cardioDurationSeconds)&&(identical(other.estimatedCalories, estimatedCalories) || other.estimatedCalories == estimatedCalories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,startedAt,completedAt,durationSeconds,exerciseCount,setCount,totalVolumeKg,cardioDurationSeconds,estimatedCalories);
}

@override
String toString() {
    return 'SessionSummary(id: $id, name: $name, startedAt: $startedAt, completedAt: $completedAt, durationSeconds: $durationSeconds, exerciseCount: $exerciseCount, setCount: $setCount, totalVolumeKg: $totalVolumeKg, cardioDurationSeconds: $cardioDurationSeconds, estimatedCalories: $estimatedCalories)';
}


}

/// @nodoc
abstract mixin class _$SessionSummaryCopyWith<$Res> implements $SessionSummaryCopyWith<$Res> {
  factory _$SessionSummaryCopyWith(_SessionSummary value, $Res Function(_SessionSummary) _then) = __$SessionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime startedAt, DateTime completedAt, int durationSeconds, int exerciseCount, int setCount, double totalVolumeKg, int cardioDurationSeconds, int estimatedCalories
});




}
/// @nodoc
class __$SessionSummaryCopyWithImpl<$Res>
    implements _$SessionSummaryCopyWith<$Res> {
  __$SessionSummaryCopyWithImpl(this._self, this._then);

  final _SessionSummary _self;
  final $Res Function(_SessionSummary) _then;

/// Create a copy of SessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? startedAt = null,Object? completedAt = null,Object? durationSeconds = null,Object? exerciseCount = null,Object? setCount = null,Object? totalVolumeKg = null,Object? cardioDurationSeconds = null,Object? estimatedCalories = null,}) {
  return _then(_SessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,setCount: null == setCount ? _self.setCount : setCount // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,cardioDurationSeconds: null == cardioDurationSeconds ? _self.cardioDurationSeconds : cardioDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,estimatedCalories: null == estimatedCalories ? _self.estimatedCalories : estimatedCalories // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
