import '../domain/current_friends.dart';
import '../domain/pending_friend.dart';

abstract interface class FriendsFetcher {
  Future<CurrentFriends> fetchCurrentFriends(int userId);

  Future<List<PendingFriend>> fetchPendingFriends(int userId);
}
