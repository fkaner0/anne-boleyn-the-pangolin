import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';

import '../domain/profile.dart';

class MockProfileFetcher implements ProfileFetcher {
  final String placeholderProfile = 'https://via.placeholder.com/150';

  final List<String> placeholderImages = [
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
  ];

  @override
  Future<Profile> fetchProfile(int userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return switch (userId) {
      0 => Profile(
          userId: 0,
          name: 'Tim Johnson',
          location: 'Harrow, London',
          bio: 'Budding watercolour artist, been enjoying painting ponds.',
          profileImageUrl: placeholderProfile,
          imageUrls: placeholderImages,
        ),
      1 => Profile(
          userId: 1,
          name: 'Sally Parks',
          location: 'Hammersmith, London',
          bio:
              'I love apples. I love still life. I love drawing apples in still life.',
          profileImageUrl: placeholderProfile,
          imageUrls: placeholderImages,
        ),
      2 => Profile(
          userId: 2,
          name: 'Selena Davis',
          location: 'Richmond, London',
          bio: 'Finger painting fanatic, check out my pangolin art.',
          profileImageUrl: placeholderProfile,
          imageUrls: placeholderImages,
        ),
      _ => throw Exception('No mock profile found for userId: $userId'),
    };
  }
}