// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  gifUrl: json['gifUrl'] as String,
  bodyPart: json['bodyPart'] as String,
  instructions:
      (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'gifUrl': instance.gifUrl,
  'bodyPart': instance.bodyPart,
  'instructions': instance.instructions,
};

_ExercisePage _$ExercisePageFromJson(Map<String, dynamic> json) =>
    _ExercisePage(
      items: (json['items'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$ExercisePageToJson(_ExercisePage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'page': instance.page,
      'totalPages': instance.totalPages,
      'totalCount': instance.totalCount,
    };
