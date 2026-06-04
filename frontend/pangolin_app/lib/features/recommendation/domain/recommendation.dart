class Recommendation {
  final int userId;
  final String name;
  final int age;
  final String location;
  final String bio;
  final String imageUrl;

  const Recommendation({
    required this.userId,
    required this.name,
    required this.age,
    required this.location,
    required this.bio,
    required this.imageUrl,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      userId: json['userId'] as int,
      name: json['name'] as String,
      age: (json['age'] as int?) ?? 0,
      location: json['location'] as String,
      bio: json['bio'] as String,
      imageUrl: json['profileImageUrl'] as String,
    );
  }
}
