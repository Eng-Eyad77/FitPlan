// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  id: json['id'] as String,
  username: json['username'] as String,
  accessToken: json['accessToken'] as String,
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'accessToken': instance.accessToken,
    };
