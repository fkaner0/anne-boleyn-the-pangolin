import 'position.dart';

class ProfileText {
  final String title;
  final String body;
  final String? font;
  final int? fontHexARGB;
  final int? backgroundHexARGB;
  final Position position;

  const ProfileText({
    required this.title,
    required this.body,
    required this.position,
    this.font,
    this.fontHexARGB = 0xFF000000,
    this.backgroundHexARGB,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'font': font,
    'fontHexARGB': fontHexARGB,
    'backgroundHexARGB': backgroundHexARGB,
    'position': position.toJson(),
  };

  factory ProfileText.fromJson(Map<String, dynamic> json) {
    return ProfileText(
      title: json['title'] as String,
      body: json['body'] as String,
      font: json['font'] as String?,
      fontHexARGB: (json['fontHexARGB'] as int?) ?? 0xFF000000,
      backgroundHexARGB: json['backgroundHexARGB'] as int?,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
    );
  }
}
