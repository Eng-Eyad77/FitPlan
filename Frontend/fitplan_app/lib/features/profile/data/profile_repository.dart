import 'dart:typed_data';

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

  /// The picture itself. Only its signed-in owner can load it (D12), so it goes through the API
  /// client with the session, not an image URL.
  Future<Uint8List> getPictureBytes() async {
    final response = await apiCall(
      () => _dio.get<List<int>>('/api/profile/me/picture', options: Options(responseType: ResponseType.bytes)),
    );
    return Uint8List.fromList(response.data!);
  }

  /// Email change, step 1: a code goes to the new address. Throws ApiException "WrongPassword".
  Future<void> sendEmailChangeCode({required String newEmail, required String password}) => apiCall(
        () => _dio.post<void>('/api/profile/me/email/code', data: {'newEmail': newEmail.trim(), 'password': password}),
      );

  /// Step 2: the code changes the email. Throws ApiException "InvalidEmailCode".
  Future<Profile> confirmEmailChange(String code) async {
    final response = await apiCall(
      () => _dio.put<Map<String, dynamic>>('/api/profile/me/email', data: {'code': code.trim()}),
    );
    return Profile.fromJson(response.data!);
  }

  /// Deletes the account and everything in it. Throws ApiException "WrongPassword".
  Future<void> deleteAccount(String password) =>
      apiCall(() => _dio.post<void>('/api/profile/me/delete', data: {'password': password}));

  Future<void> addBodyWeight(double weightKg) async {
    await apiCall(() => _dio.post<void>('/api/body-weight', data: {'weightKg': weightKg}));
  }
}
