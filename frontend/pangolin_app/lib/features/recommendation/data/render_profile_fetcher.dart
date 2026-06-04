import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/features/recommendation/data/api_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';

class RenderProfileFetcher implements ProfileFetcher {
  final ApiProfileFetcher _delegate;

  RenderProfileFetcher({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiProfileFetcher(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Future<Profile> fetchProfile(int userId) {
    return _delegate.fetchProfile(userId);
  }
}
