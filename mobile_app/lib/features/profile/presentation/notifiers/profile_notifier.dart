import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core_providers.dart';
import '../../domain/entities/user_profile.dart';

// ProfileNotifier — управляет профилем пользователя (MVVM ViewModel).
// Паттерн: AsyncNotifier<T> из Riverpod 2.x.
class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() =>
      ref.read(getProfileUseCaseProvider).call();

  Future<void> saveProfile(UserProfile profile) async {
    await ref.read(saveProfileUseCaseProvider).call(profile);
    state = AsyncValue.data(profile);
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);