import 'package:pangolin_app/config/env.dart';

import '../domain/current_friends.dart';
import '../domain/pending_friend.dart';
import 'api_friends_fetcher.dart';
import 'friends_fetcher.dart';

class RenderFriendsFetcher implements FriendsFetcher {
  final ApiFriendsFetcher _delegate;

  RenderFriendsFetcher({
    String host = defaultRenderHost,
    int? port,
    bool useHttps = true,
  }) : _delegate = ApiFriendsFetcher(
         host: host,
         port: port,
         useHttps: useHttps,
       );

  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) =>
      _delegate.fetchCurrentFriends(userId);

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) =>
      _delegate.fetchPendingFriends(userId);
}
