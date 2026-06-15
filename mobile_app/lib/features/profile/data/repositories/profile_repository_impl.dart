import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _dataSource;
  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<UserProfile?> getProfile() => _dataSource.getProfile();

  @override
  Future<void> saveProfile(UserProfile profile) => _dataSource.saveProfile(profile);
}