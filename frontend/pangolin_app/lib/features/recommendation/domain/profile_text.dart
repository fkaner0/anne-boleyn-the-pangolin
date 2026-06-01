import 'position.dart';

class ProfileText {
  final String title;
  final String body;
  final Position position;

  const ProfileText({
    required this.title,
    required this.body,
    required this.position,
  });

  factory ProfileText.fromJson(Map<String, dynamic> json) {
    return ProfileText(
      title: json['title'] as String,
      body: json['body'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
    );
  }
}
