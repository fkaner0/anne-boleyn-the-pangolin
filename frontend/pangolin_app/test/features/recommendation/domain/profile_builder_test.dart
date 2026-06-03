import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

void main() {
  const position = Position(x: 0, y: 0, rotation: 0);
  const image = ProfileImage(
    url: 'https://example.com/a.jpg',
    position: position,
  );
  const textbox = ProfileText(
    title: 'About',
    body: 'Hello',
    position: position,
  );

  ProfileBuilder validBuilder() =>
      ProfileBuilder().setUserId(1).setName('Alice').setLocation('London');

  group('ProfileBuilder', () {
    test('builds a profile from the configured fields', () {
      final profile = validBuilder()
          .addImage(image)
          .addTextBox(textbox)
          .build();

      expect(profile.userId, 1);
      expect(profile.name, 'Alice');
      expect(profile.location, 'London');
      expect(profile.images, [image]);
      expect(profile.textboxes, [textbox]);
    });

    test('defaults images and textboxes to empty lists', () {
      final profile = validBuilder().build();

      expect(profile.images, isEmpty);
      expect(profile.textboxes, isEmpty);
    });

    test('addImages and addTextBoxes preserve order', () {
      const image2 = ProfileImage(
        url: 'https://example.com/b.jpg',
        position: position,
      );

      final profile = validBuilder().addImages([image, image2]).addTextBoxes([
        textbox,
      ]).build();

      expect(profile.images, [image, image2]);
      expect(profile.textboxes, [textbox]);
    });

    test('throws StateError listing every missing required field', () {
      expect(
        () => ProfileBuilder().build(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('userId'), contains('name'), contains('location')),
          ),
        ),
      );
    });

    test(
      'mutating the builder after build does not affect the built profile',
      () {
        final builder = validBuilder().addImage(image);
        final profile = builder.build();

        builder.addImage(image);

        expect(profile.images, hasLength(1));
      },
    );

    test('from seeds the builder from an existing profile', () {
      final original = Profile(
        userId: 7,
        name: 'Bob',
        location: 'Paris',
        images: const [image],
        textboxes: const [textbox],
      );

      final rebuilt = ProfileBuilder.from(original).setName('Bobby').build();

      expect(rebuilt.userId, 7);
      expect(rebuilt.name, 'Bobby');
      expect(rebuilt.location, 'Paris');
      expect(rebuilt.images, [image]);
      expect(rebuilt.textboxes, [textbox]);
    });
  });
}
