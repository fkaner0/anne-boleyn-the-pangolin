import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

class Profile {
  final int userId;
  final String name;
  final String location;
  final String bio;
  final List<ProfileImage> images;
  final List<ProfileText> textboxes;
  final List<ProfileSticker> stickers;

  const Profile({
    required this.userId,
    required this.name,
    required this.location,
    this.bio = "no bio provided", // TODO: make required
    required this.images,
    required this.textboxes,
    this.stickers = const [],
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      bio: json['bio'] as String,
      images: (json['wallImages'] as List<dynamic>)
          .map((item) => ProfileImage.fromJson(item as Map<String, dynamic>))
          .toList(),
      textboxes: (json['wallTextboxes'] as List<dynamic>)
          .map((item) => ProfileText.fromJson(item as Map<String, dynamic>))
          .toList(),
      stickers:
          (json['wallStickers'] as List<dynamic>?)
              ?.map(
                (item) => ProfileSticker.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}
