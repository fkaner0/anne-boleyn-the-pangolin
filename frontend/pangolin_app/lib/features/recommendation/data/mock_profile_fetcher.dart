import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

class MockProfileFetcher implements ProfileFetcher {
  @override
  Future<Profile> fetchProfile(int userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return switch (userId) {
      0 => Profile(
        userId: 0,
        name: 'Tim Johnson',
        location: 'Harrow, London',
        images: [
          _image('Tim+1', 40, 40, -8),
          _image('Tim+2', 250, 90, 6),
          _image('Tim+3', 110, 260, -3),
        ],
        textboxes: [
          _textbox(
            'About my work',
            'Budding watercolour artist, been enjoying painting ponds.',
            420,
            60,
            2,
          ),
          _textbox(
            'Current focus',
            'Trying to capture reflections and soft greens in nature.',
            360,
            250,
            -4,
          ),
        ],
        stickers: [
          _sticker('pangolin', 200, 420, 8),
          _sticker('heart', 320, 180, -6),
        ],
      ),

      1 => Profile(
        userId: 1,
        name: 'Sally Parks',
        location: 'Hammersmith, London',
        images: [
          _image('Sally+1', 60, 70, -5),
          _image('Sally+2', 290, 50, 8),
          _image('Sally+3', 180, 260, -2),
          _image('Sally+4', 460, 220, 5),
        ],
        textboxes: [
          _textbox(
            'Still life obsession',
            'I love apples. I love still life. I love drawing apples in still life.',
            500,
            40,
            -3,
          ),
          _textbox(
            'Favourite subjects',
            'Fruit bowls, table cloth folds, and afternoon window light.',
            390,
            340,
            4,
          ),
        ],
        stickers: [_sticker('star', 150, 200, 4)],
      ),

      2 => Profile(
        userId: 2,
        name: 'Selena Davis',
        location: 'Richmond, London',
        images: [
          _image('Selena+1', 50, 40, 7),
          _image('Selena+2', 240, 130, -6),
          _image('Selena+3', 430, 70, 3),
        ],
        textboxes: [
          _textbox(
            'Pangolin series',
            'Finger painting fanatic, check out my pangolin art.',
            390,
            250,
            -5,
          ),
          _textbox(
            'Materials',
            'Mostly poster paint, fingers, cardboard, and lots of mess.',
            110,
            320,
            3,
          ),
        ],
        stickers: [
          _sticker('pangolin', 470, 300, -10),
          _sticker('sun', 60, 150, 6),
        ],
      ),

      _ => throw Exception('No mock profile found for userId: $userId'),
    };
  }

  ProfileImage _image(String label, int x, int y, int rotation) {
    return ProfileImage(
      url: 'https://via.placeholder.com/300?text=$label',
      position: Position(
        x: x,
        y: y,
        rotation: rotation,
        aspectRatio: 1.0,
        scale: 1.0,
      ),
    );
  }

  ProfileText _textbox(String title, String body, int x, int y, int rotation) {
    return ProfileText(
      title: title,
      body: body,
      position: Position(
        x: x,
        y: y,
        rotation: rotation,
        aspectRatio: 1.0,
        scale: 1.0,
      ),
    );
  }

  ProfileSticker _sticker(String name, int x, int y, int rotation) {
    return ProfileSticker(
      name: name,
      position: Position(
        x: x,
        y: y,
        rotation: rotation,
        aspectRatio: 1.0,
        scale: 1.0,
      ),
    );
  }
}
