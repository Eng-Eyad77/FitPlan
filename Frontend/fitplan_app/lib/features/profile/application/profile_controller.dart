import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/application/recovery_code.dart';
import '../../progress/application/progress_providers.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

/// The bytes of a profile picture, kept per picture URL: the URL changes with each upload,
/// so a new picture is loaded once and an old one is never shown again.
final profilePictureProvider = FutureProvider.family<Uint8List, String>((ref, pictureUrl) {
  // a different user logs in -> never reuse the previous user's picture
  ref.watch(authControllerProvider.select((auth) => auth.value?.id));
  return ref.read(profileRepositoryProvider).getPictureBytes();
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);

/// The current user's profile. Every action returns the updated profile from the API,
/// so the screen always shows what the server saved.
/// Each action throws ApiException on failure; the screen shows the message.
class ProfileController extends AsyncNotifier<Profile> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<Profile> build() {
    // a different user logs in -> load their profile, not the previous one
    ref.watch(authControllerProvider.select((auth) => auth.value?.id));
    return _repository.getProfile();
  }

  Future<void> updateBio(String bio) async {
    final trimmed = bio.trim();
    state = AsyncData(await _repository.updateBio(trimmed.isEmpty ? null : trimmed));
  }

  Future<void> setWeeklyGoal(int? goal) async {
    state = AsyncData(await _repository.updateWeeklyGoal(goal));
    ref.invalidate(statsOverviewProvider); // the streak depends on the goal
  }

  Future<void> uploadPicture(XFile image) async {
    state = AsyncData(await _repository.uploadPicture(image));
  }

  Future<void> removePicture() async {
    state = AsyncData(await _repository.deletePicture());
  }

  /// The new code shows over the app until the user confirms saving it.
  Future<void> createRecoveryCode(String password) async {
    final code = await _repository.createRecoveryCode(password);
    ref.read(recoveryCodeToShowProvider.notifier).show(code);
    state = AsyncData(await _repository.getProfile());
  }

  /// Ends the session on this device once the server has deleted everything.
  Future<void> deleteAccount(String password) async {
    await _repository.deleteAccount(password);
    await ref.read(authControllerProvider.notifier).forgetDeletedAccount();
  }

  Future<void> addBodyWeight(double weightKg) async {
    await _repository.addBodyWeight(weightKg);
    ref.invalidate(bodyWeightHistoryProvider);
    // the profile carries currentWeightKg, reload it
    state = AsyncData(await _repository.getProfile());
  }
}
