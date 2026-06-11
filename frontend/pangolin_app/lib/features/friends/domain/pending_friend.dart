class PendingFriend {
  final int friendUserId;
  final String name;
  final String mainImage;
  final String messagePreview;
  final String location;
  final int? age;

  const PendingFriend({
    required this.friendUserId,
    required this.name,
    required this.mainImage,
    this.messagePreview = '',
    this.location = '',
    this.age,
  });

  factory PendingFriend.fromJson(Map<String, dynamic> json) {
    return PendingFriend(
      friendUserId: json['friendUserId'] as int,
      name: json['name'] as String,
      mainImage: (json['mainImage'] as String?) ?? '',
      messagePreview: (json['messagePreview'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt(),
    );
  }
}
