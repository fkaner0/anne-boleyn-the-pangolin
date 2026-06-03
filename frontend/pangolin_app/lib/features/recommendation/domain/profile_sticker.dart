import 'position.dart';

class ProfileSticker {
  final String name;
  final Position position;

  const ProfileSticker({required this.name, required this.position});

  Map<String, dynamic> toJson() => {
    'name': name,
    'position': position.toJson(),
  };

  factory ProfileSticker.fromJson(Map<String, dynamic> json) {
    return ProfileSticker(
      name: json['name'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
    );
  }
}
