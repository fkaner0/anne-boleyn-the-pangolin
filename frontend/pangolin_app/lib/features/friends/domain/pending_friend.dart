class PendingFriend {
  final int friendUserId;
  final String name;
  final String mainImage;
  final int? age;

  const PendingFriend({
    required this.friendUserId,
    required this.name,
    required this.mainImage,
    this.age,
  });

  factory PendingFriend.fromJson(Map<String, dynamic> json) {
    return PendingFriend(
      friendUserId: json['friendUserId'] as int,
      name: json['name'] as String,
      mainImage: (json['mainImage'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt(),
    );
  }
}
