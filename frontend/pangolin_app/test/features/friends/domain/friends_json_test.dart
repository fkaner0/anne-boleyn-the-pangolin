import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';

void main() {
  test('CurrentFriends.fromJson parses friends and the pending count', () {
    final current = CurrentFriends.fromJson({
      'friends': [
        {
          'friendUserId': 1,
          'name': 'Tim',
          'coverImages': ['a.jpg', 'b.jpg'],
          'mainImage': 'main.jpg',
        },
      ],
      'pendingFriends': 5,
    });

    expect(current.pendingCount, 5);
    expect(current.friends, hasLength(1));
    final friend = current.friends.single;
    expect(friend.friendUserId, 1);
    expect(friend.name, 'Tim');
    expect(friend.coverImages, ['a.jpg', 'b.jpg']);
    expect(friend.mainImage, 'main.jpg');
  });

  test('CurrentFriends.fromJson tolerates missing fields', () {
    final current = CurrentFriends.fromJson({'friends': []});

    expect(current.friends, isEmpty);
    expect(current.pendingCount, 0);
  });

  test('PendingFriend.fromJson parses its fields', () {
    final pending = PendingFriend.fromJson({
      'friendUserId': 9,
      'name': 'Mei',
      'mainImage': 'mei.jpg',
      'messagePreview': 'Hi there!',
      'age': 22,
    });

    expect(pending.friendUserId, 9);
    expect(pending.name, 'Mei');
    expect(pending.mainImage, 'mei.jpg');
    expect(pending.messagePreview, 'Hi there!');
    expect(pending.age, 22);
  });

  test('PendingFriend.fromJson defaults a missing message preview', () {
    final pending = PendingFriend.fromJson({
      'friendUserId': 9,
      'name': 'Mei',
      'mainImage': 'mei.jpg',
    });

    expect(pending.messagePreview, '');
  });
}
