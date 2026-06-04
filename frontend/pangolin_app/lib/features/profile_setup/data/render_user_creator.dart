import 'package:pangolin_app/config/env.dart';

import 'api_user_creator.dart';
import 'user_creator.dart';

class RenderUserCreator implements UserCreator {
  final ApiUserCreator _delegate;

  RenderUserCreator({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiUserCreator(host: host, port: port, useHttps: useHttps);

  @override
  Future<int> createUser() => _delegate.createUser();
}
