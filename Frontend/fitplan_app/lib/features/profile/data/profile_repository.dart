import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);

/// /api/profile/me and /api/body-weight. Throws ApiException on failure.
class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<Profile> getProfile() async {
    final response = await apiCall(() => _dio.get<Map<String, dynamic>>('/api/profile/me'));
    return Profile.fromJson(response.data!);
  }

  Future<Profile> updateBio(String? bio) async {
    final response = await apiCall(
      () => _dio.put<Map<String, dynamic>>('/api/profile/me', data: {'bio': bio}),
    );
    return Profile.fromJson(response.data!);
  }

  /// [goal] null removes it.
  Future<Profile> updateWeeklyGoal(int? goal) async {
    final response = await apiCall(
      () => _dio.put<Map<String, dynamic>>('/api/profile/me/weekly-goal', data: {'weeklyGoal': goal}),
    );
    return Profile.fromJson(response.data!);
  }

  Future<Profile> uploadPicture(XFile image) async {
    // bytes (not a file path) so the same code works on the web too
    final bytes = await image.readAsBytes();
    final isPng = image.name.toLowerCase().endsWith('.png');

    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: isPng ? 'profile.png' : 'profile.jpg',
        contentType: DioMediaType('image', isPng ? 'png' : 'jpeg'),
      ),
    });

    final response = await apiCall(
      () => _dio.post<Map<String, dynamic>>('/api/profile/me/picture', data: form),
    );
    return Profile.fromJson(response.data!);
  }

  Future<Profile> deletePicture() async {
    final response =
        await apiCall(() => _dio.delete<Map<String, dynamic>>('/api/profile/me/picture'));
    return Profile.fromJson(response.data!);
  }

  Future<void> addBodyWeight(double weightKg) async {
    await apiCall(() => _dio.post<void>('/api/body-weight', data: {'weightKg': weightKg}));
  }
}
