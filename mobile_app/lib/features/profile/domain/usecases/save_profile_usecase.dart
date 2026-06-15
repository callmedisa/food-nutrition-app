import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository _repository;
  SaveProfileUseCase(this._repository);

  Future<void> call(UserProfile profile) => _repository.saveProfile(profile);
}