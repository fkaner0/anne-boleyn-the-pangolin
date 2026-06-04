import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

void main() {
  const position = Position(x: 1, y: 2, rotation: 0.5);

  group('Profile.toJson', () {
    final profile = Profile(
      userId: 7,
      name: 'Anne',
      age: 30,
      location: 'London',
      profileImageUrl: 'https://example.com/me.jpg',
      bio: 'painter',
      wallBackgroundHexARGB: 0xFF112233,
      images: const [ProfileImage(url: 'u', position: position)],
      textboxes: const [ProfileText(title: 't', body: 'b', position: position)],
      stickers: const [ProfileSticker(name: 'sun', position: position)],
    );

    test('uses the wall* keys and omits userId from the body', () {
      final json = profile.toJson();

      expect(json.containsKey('userId'), isFalse);
      expect(
        json.keys,
        containsAll(['wallImages', 'wallTextboxes', 'wallStickers']),
      );
      expect(json.containsKey('images'), isFalse);
    });

    test('includes the new top-level fields', () {
      final json = profile.toJson();

      expect(json['age'], 30);
      expect(json['profileImageUrl'], 'https://example.com/me.jpg');
      expect(json['bio'], 'painter');
      expect(json['wallBackgroundHexARGB'], 0xFF112233);
    });

    test('rotation is serialized as a double', () {
      final json = profile.toJson();
      final imagePosition =
          (json['wallImages'] as List).first['position'] as Map;

      expect(imagePosition['rotation'], isA<double>());
      expect(imagePosition['rotation'], 0.5);
    });
  });

  group('ProfileText styling', () {
    test(
      'defaults font to null, font colour to opaque black, background null',
      () {
        const text = ProfileText(title: 't', body: 'b', position: position);

        expect(text.font, isNull);
        expect(text.fontHexARGB, 0xFF000000);
        expect(text.backgroundHexARGB, isNull);
      },
    );

    test('serializes the styling fields', () {
      const text = ProfileText(
        title: 't',
        body: 'b',
        position: position,
        font: 'Roboto',
        fontHexARGB: 0xFFFF0000,
        backgroundHexARGB: 0x80000000,
      );

      final json = text.toJson();

      expect(json['font'], 'Roboto');
      expect(json['fontHexARGB'], 0xFFFF0000);
      expect(json['backgroundHexARGB'], 0x80000000);
    });
  });

  group('fromJson tolerates a backend that predates the new fields', () {
    test('Profile defaults the new fields when absent', () {
      final profile = Profile.fromJson({
        'userId': 1,
        'name': 'Anne',
        'location': 'London',
        'wallImages': [],
        'wallTextboxes': [],
        'wallStickers': [],
      });

      expect(profile.profileImageUrl, '');
      expect(profile.wallBackgroundHexARGB, 0xFFFFFFFF);
    });

    test('parses a view response that omits userId and injects it', () {
      final profile = Profile.fromJson({
        'name': 'Anne',
        'location': 'London',
        'wallImages': [],
        'wallTextboxes': [],
        'wallStickers': [],
      }, userId: 42);

      expect(profile.userId, 42);
      expect(profile.name, 'Anne');
    });

    test('ProfileText defaults the styling fields when absent', () {
      final text = ProfileText.fromJson({
        'title': 't',
        'body': 'b',
        'position': {'x': 0, 'y': 0, 'rotation': 0},
      });

      expect(text.font, isNull);
      expect(text.fontHexARGB, 0xFF000000);
      expect(text.backgroundHexARGB, isNull);
    });
  });
}
