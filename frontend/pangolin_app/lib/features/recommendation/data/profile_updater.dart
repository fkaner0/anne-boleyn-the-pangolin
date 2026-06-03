import '../domain/profile.dart';

abstract interface class ProfileUpdater {
  Future<void> updateProfile(Profile profile);
}
