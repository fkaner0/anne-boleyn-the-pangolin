import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

class Profile {
  static const String defaultProfileImageUrl = '';
  static const String defaultBio = 'no bio provided';
  static const int defaultWallBackgroundHexARGB = 0xFFFFFFFF;
  static const int defaultAge = 0;

  final int userId;
  final String name;
  final int age;
  final String profileImageUrl;
  final String location;
  final String bio;
  final int wallBackgroundHexARGB;
  final String? hobby;
  final double? passionLevel;
  final List<String> subInterests;
  final List<String> otherInterests;
  final List<ProfileImage> images;
  final List<ProfileText> textboxes;
  final List<ProfileSticker> stickers;

  const Profile({
    required this.userId,
    required this.name,
    required this.location,
    this.age = defaultAge,
    this.profileImageUrl = defaultProfileImageUrl,
    this.bio = defaultBio, // TODO: make required
    this.wallBackgroundHexARGB = defaultWallBackgroundHexARGB,
    this.hobby,
    this.passionLevel,
    this.subInterests = const [],
    this.otherInterests = const [],
    required this.images,
    required this.textboxes,
    this.stickers = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'location': location,
    'wallBackgroundHexARGB': wallBackgroundHexARGB,
    'hobby': hobby,
    'passionLevel': passionLevel,
    'subInterests': subInterests,
    'otherInterests': otherInterests,
    'wallImages': images.map((i) => i.toJson()).toList(),
    'wallTextboxes': textboxes.map((t) => t.toJson()).toList(),
    'wallStickers': stickers.map((s) => s.toJson()).toList(),
  };

  factory Profile.fromJson(Map<String, dynamic> json, {int? userId}) {
    return Profile(
      userId: userId ?? (json['userId'] as int?) ?? 0,
      name: json['name'] as String,
      age: (json['age'] as int?) ?? defaultAge,
      profileImageUrl:
          (json['profileImageUrl'] as String?) ?? defaultProfileImageUrl,
      location: json['location'] as String,
      bio: (json['bio'] as String?) ?? defaultBio,
      wallBackgroundHexARGB:
          (json['wallBackgroundHexARGB'] as int?) ??
          defaultWallBackgroundHexARGB,
      //hobby: json['hobby'] as String?,
      //passionLevel: (json['passionLevel'] as num?)?.toDouble(),
      //subInterests:
      //    (json['subInterests'] as List<dynamic>?)
      //        ?.map((item) => item as String)
      //        .toList() ??
      //    const [],
      //otherInterests:
      //    (json['otherInterests'] as List<dynamic>?)
      //        ?.map((item) => item as String)
      //        .toList() ??
      //    const [],
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
