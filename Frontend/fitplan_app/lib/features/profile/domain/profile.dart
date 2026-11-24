import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// GET /api/profile/me
@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required String username,
    required String email,
    String? bio,
    String? profilePictureUrl,
    double? currentWeightKg,
    int? weeklyGoal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  String get initial => username.isEmpty ? '?' : username[0].toUpperCase();
}
