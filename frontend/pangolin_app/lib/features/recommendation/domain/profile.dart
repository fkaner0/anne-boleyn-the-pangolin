import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

class Profile {
  final int userId;
  final String name;
  final String profileImageUrl;
  final String location;
  final String bio;
  final int wallBackgroundHexARGB;
  final List<ProfileImage> images;
  final List<ProfileText> textboxes;
  final List<ProfileSticker> stickers;

  const Profile({
    required this.userId,
    required this.name,
    required this.location,
    this.profileImageUrl = '',
    this.bio = "no bio provided", // TODO: make required
    this.wallBackgroundHexARGB = 0xFFFFFFFF,
    required this.images,
    required this.textboxes,
    this.stickers = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'location': location,
    'wallBackgroundHexARGB': wallBackgroundHexARGB,
    'wallImages': images.map((i) => i.toJson()).toList(),
    'wallTextboxes': textboxes.map((t) => t.toJson()).toList(),
    'wallStickers': stickers.map((s) => s.toJson()).toList(),
  };

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] as int,
      name: json['name'] as String,
      profileImageUrl: (json['profileImageUrl'] as String?) ?? '',
      location: json['location'] as String,
      bio: (json['bio'] as String?) ?? 'no bio provided',
      wallBackgroundHexARGB:
          (json['wallBackgroundHexARGB'] as int?) ?? 0xFFFFFFFF,
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
