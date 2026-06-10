import '../domain/current_friends.dart';
import '../domain/friend.dart';
import '../domain/pending_friend.dart';
import 'friends_fetcher.dart';

class MockFriendsFetcher implements FriendsFetcher {
  @override
  Future<CurrentFriends> fetchCurrentFriends(int userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return CurrentFriends(
      pendingCount: 3,
      friends: [
        _friend('Tim Johnson', 'Tim', 4),
        _friend('Sally Parks', 'Sally', 3),
        _friend('Selena Davis', 'Selena', 5),
        _friend('Marcus Lee', 'Marcus', 2),
        _friend('Priya Patel', 'Priya', 4),
        _friend('Omar Haddad', 'Omar', 3),
      ],
    );
  }

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      PendingFriend(
        friendUserId: 101,
        name: 'Jess Wong',
        mainImage: 'https://via.placeholder.com/200?text=Jess',
      ),
      PendingFriend(
        friendUserId: 102,
        name: 'Diego Alvarez',
        mainImage: 'https://via.placeholder.com/200?text=Diego',
      ),
      PendingFriend(
        friendUserId: 103,
        name: 'Mei Tan',
        mainImage: 'https://via.placeholder.com/200?text=Mei',
      ),
    ];
  }

  Friend _friend(String name, String label, int coverCount) {
    return Friend(
      friendUserId: name.hashCode,
      name: name,
      mainImage: 'https://via.placeholder.com/200?text=$label',
      coverImages: [
        for (var i = 1; i <= coverCount; i++)
          'https://via.placeholder.com/300?text=$label+$i',
      ],
    );
  }
}
