import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import '../../data/profile_fetcher.dart';
import '../../domain/profile.dart';
import '../pages/bedroom_wall_detail_page.dart';
import '../widgets/bedroom_wall_view.dart';
import '../widgets/profile_header_bar.dart';

class RecommendationProfilePage extends StatelessWidget {
  final ProfileFetcher profileFetcher;
  final int userId;

  const RecommendationProfilePage({
    super.key,
    required this.profileFetcher,
    required this.userId,
  });

  Future<(Profile, StickerCatalog)> _load() async {
    final profileFuture = profileFetcher.fetchProfile(userId);
    final catalogFuture = StickerCatalog.load().catchError(
      (_) => StickerCatalog.fromAssetKeys(const <String>[]),
    );
    return (await profileFuture, await catalogFuture);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Profile, StickerCatalog)>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ProfileHeaderBar(
                    name: 'Profile',
                    location: 'Error',
                    onBackPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                ],
              ),
            ),
          );
        }

        final (profile, stickerCatalog) = snapshot.data!;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                ProfileHeaderBar(
                  name: profile.name,
                  location: profile.location,
                  onBackPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BedroomWallView(
                      profile: profile,
                      stickerCatalog: stickerCatalog,
                      onImageTap: (image) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BedroomWallDetailPage(
                              profile: profile,
                              image: image,
                            ),
                          ),
                        );
                      },
                      onTextTap: (textbox) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BedroomWallDetailPage(
                              profile: profile,
                              textbox: textbox,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
