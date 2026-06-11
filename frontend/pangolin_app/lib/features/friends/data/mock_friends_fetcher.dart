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
        _friend(1, 'Tim Johnson', 'Tim', 4),
        _friend(2, 'Sally Parks', 'Sally', 3),
        _friend(3, 'Selena Davis', 'Selena', 5),
        _friend(4, 'Marcus Lee', 'Marcus', 2),
      ],
    );
  }

  @override
  Future<List<PendingFriend>> fetchPendingFriends(int userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      PendingFriend(
        friendUserId: 5,
        name: 'Jess Wong',
        mainImage: 'https://via.placeholder.com/200?text=Jess',
        age: 24,
      ),
      PendingFriend(
        friendUserId: 6,
        name: 'Diego Alvarez',
        mainImage: 'https://via.placeholder.com/200?text=Diego',
        age: 29,
      ),
      PendingFriend(
        friendUserId: 7,
        name: 'Mei Tan',
        mainImage: 'https://via.placeholder.com/200?text=Mei',
        age: 22,
      ),
    ];
  }

  Friend _friend(int id, String name, String label, int coverCount) {
    return Friend(
      friendUserId: id,
      name: name,
      mainImage: 'https://via.placeholder.com/200?text=$label',
      coverImages: [
        for (var i = 1; i <= coverCount; i++)
          'https://via.placeholder.com/300?text=$label+$i',
      ],
    );
  }
}
