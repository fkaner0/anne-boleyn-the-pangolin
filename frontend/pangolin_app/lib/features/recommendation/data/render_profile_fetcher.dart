import 'package:pangolin_app/features/recommendation/data/api_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';

class RenderProfileFetcher implements ProfileFetcher {
  final ApiProfileFetcher _delegate = const ApiProfileFetcher(
    host: 'anne-boleyn-the-pangolin-huqk.onrender.com',
  );

  @override
  Future<Profile> fetchProfile(int userId) {
    return _delegate.fetchProfile(userId);
  }
}
