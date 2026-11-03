import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/env.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// GET /api/profile/me
@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required String username,
    String? bio,
    String? profilePictureUrl,
    double? currentWeightKg,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// The API returns a relative path ("/uploads/profile-pictures/x.jpg").
  String? get pictureFullUrl =>
      profilePictureUrl == null ? null : '${Env.apiBaseUrl}$profilePictureUrl';

  String get initial => username.isEmpty ? '?' : username[0].toUpperCase();
}
