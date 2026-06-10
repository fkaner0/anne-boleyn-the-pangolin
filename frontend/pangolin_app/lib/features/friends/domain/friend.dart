class Friend {
  final int friendUserId;
  final String name;
  final List<String> coverImages;
  final String mainImage;

  const Friend({
    required this.friendUserId,
    required this.name,
    required this.coverImages,
    required this.mainImage,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      friendUserId: json['friendUserId'] as int,
      name: json['name'] as String,
      coverImages:
          (json['coverImages'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      mainImage: (json['mainImage'] as String?) ?? '',
    );
  }
}
