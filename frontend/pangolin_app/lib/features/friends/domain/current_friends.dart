import 'friend.dart';

class CurrentFriends {
  final List<Friend> friends;
  final int pendingCount;

  const CurrentFriends({required this.friends, required this.pendingCount});

  factory CurrentFriends.fromJson(Map<String, dynamic> json) {
    return CurrentFriends(
      friends:
          (json['friends'] as List<dynamic>?)
              ?.map((item) => Friend.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      pendingCount: (json['pendingFriends'] as int?) ?? 0,
    );
  }
}
