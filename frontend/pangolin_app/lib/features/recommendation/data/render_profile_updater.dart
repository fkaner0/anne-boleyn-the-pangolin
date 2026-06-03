import 'package:pangolin_app/config/env.dart';

import '../domain/profile.dart';
import 'api_profile_updater.dart';
import 'profile_updater.dart';

class RenderProfileUpdater implements ProfileUpdater {
  final ApiProfileUpdater _delegate;

  RenderProfileUpdater({String host = defaultRenderHost, bool useHttps = true})
    : _delegate = ApiProfileUpdater(host: host, useHttps: useHttps);

  @override
  Future<void> updateProfile(Profile profile) {
    return _delegate.updateProfile(profile);
  }
}
