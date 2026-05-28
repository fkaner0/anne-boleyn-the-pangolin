class Profile {
  final int userId;
  final String name;
  final String location;
  final String bio;
  final String profileImageUrl;
  final List<String> imageUrls;

  const Profile({
    required this.userId,
    required this.name,
    required this.location,
    required this.bio,
    required this.profileImageUrl,
    required this.imageUrls,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      bio: json['bio'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>).map((url) => url as String).toList(),
    );
  }
}
