class Recommendation {
  final String name;
  final String location;
  final String bio;
  final String imageUrl;

  const Recommendation({
    required this.name,
    required this.location,
    required this.bio,
    required this.imageUrl,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'] as String,
      location: json['location'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}