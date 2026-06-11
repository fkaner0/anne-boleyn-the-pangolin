abstract interface class FriendActionSender {
  Future<void> report({required int currentUserId, required int targetUserId});

  Future<void> remove({required int currentUserId, required int targetUserId});

  Future<void> reject({required int currentUserId, required int targetUserId});
}
