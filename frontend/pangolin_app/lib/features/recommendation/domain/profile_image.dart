import 'position.dart';

class ProfileImage {
  final String url;
  final Position position;

  const ProfileImage({required this.url, required this.position});

  Map<String, dynamic> toJson() => {'url': url, 'position': position.toJson()};

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      url: json['url'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
    );
  }
}
