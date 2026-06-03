import '../domain/profile.dart';
import 'profile_updater.dart';

class MockProfileUpdater implements ProfileUpdater {
  Profile? lastUpdated;

  @override
  Future<void> updateProfile(Profile profile) async {
    lastUpdated = profile;
  }
}
