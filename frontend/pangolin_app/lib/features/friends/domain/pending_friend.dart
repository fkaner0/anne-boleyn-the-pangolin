class PendingFriend {
  final int friendUserId;
  final String name;
  final String mainImage;

  const PendingFriend({
    required this.friendUserId,
    required this.name,
    required this.mainImage,
  });

  factory PendingFriend.fromJson(Map<String, dynamic> json) {
    return PendingFriend(
      friendUserId: json['friendUserId'] as int,
      name: json['name'] as String,
      mainImage: (json['mainImage'] as String?) ?? '',
    );
  }
}
