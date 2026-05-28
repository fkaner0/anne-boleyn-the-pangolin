import '../domain/profile.dart';

abstract class ProfileFetcher {
  Future<Profile> fetchProfile(int userId);
}
