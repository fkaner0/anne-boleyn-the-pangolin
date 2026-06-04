import 'package:pangolin_app/config/env.dart';

import '../domain/profile.dart';
import 'api_profile_updater.dart';
import 'profile_updater.dart';

class RenderProfileUpdater implements ProfileUpdater {
  final ApiProfileUpdater _delegate;

  RenderProfileUpdater({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiProfileUpdater(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Future<void> updateProfile(Profile profile) {
    return _delegate.updateProfile(profile);
  }
}
