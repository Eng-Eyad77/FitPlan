import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/application/auth_controller.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

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

  Future<void> uploadPicture(XFile image) async {
    state = AsyncData(await _repository.uploadPicture(image));
  }

  Future<void> removePicture() async {
    state = AsyncData(await _repository.deletePicture());
  }

  Future<void> addBodyWeight(double weightKg) async {
    await _repository.addBodyWeight(weightKg);
    // the profile carries currentWeightKg, reload it
    state = AsyncData(await _repository.getProfile());
  }
}
