import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

class Profile {
  final int userId;
  final String name;
  final String location;
  final List<ProfileImage> images;
  final List<ProfileText> textboxes;

  const Profile({
    required this.userId,
    required this.name,
    required this.location,
    required this.images,
    required this.textboxes,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      images: (json['images'] as List<dynamic>)
          .map((item) => ProfileImage.fromJson(item as Map<String, dynamic>))
          .toList(),
      textboxes: (json['textBoxes'] as List<dynamic>)
          .map((item) => ProfileText.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
