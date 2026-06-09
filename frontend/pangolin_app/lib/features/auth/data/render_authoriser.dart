import 'package:pangolin_app/config/env.dart';

import 'api_authoriser.dart';
import 'authoriser.dart';

class RenderAuthoriser implements Authoriser {
  final ApiAuthoriser _delegate;

  RenderAuthoriser({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiAuthoriser(host: host, port: port, useHttps: useHttps);

  @override
  Future<int> getExistingUserId(String username) =>
      _delegate.getExistingUserId(username);

  @override
  Future<int> getNewUserId(String username) => _delegate.getNewUserId(username);
}
