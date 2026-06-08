import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import '../../data/profile_fetcher.dart';
import '../../domain/profile.dart';
import '../pages/bedroom_wall_detail_page.dart';
import '../widgets/bedroom_wall_view.dart';
import '../widgets/profile_header_bar.dart';

class RecommendationProfilePage extends StatelessWidget {
  final int viewerUserId;
  final ProfileFetcher profileFetcher;
  final int userId;
  final ButtonClickLogger? logger;

  const RecommendationProfilePage({
    super.key,
    required this.viewerUserId,
    required this.profileFetcher,
    required this.userId,
    this.logger,
  });

  void _log(String buttonId) {
    unawaited(
      (logger ?? getIt<ButtonClickLogger>()).logButtonClick(
        userId: viewerUserId,
        buttonId: buttonId,
      ),
    );
  }

  Future<(Profile, StickerCatalog, FontCatalog)> _load() async {
    final profileFuture = profileFetcher.fetchProfile(userId);
    final stickerCatalogFuture = StickerCatalog.load().catchError(
      (_) => StickerCatalog.fromAssetKeys(const <String>[]),
    );
    final fontCatalog = FontCatalog(); // TODO: is this right?
    return (await profileFuture, await stickerCatalogFuture, fontCatalog);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(Profile, StickerCatalog, FontCatalog)>(
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
                      _log(ButtonIds.bedroomWallBack);
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

        final (profile, stickerCatalog, fontCatalog) = snapshot.data!;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                ProfileHeaderBar(
                  name: profile.name,
                  location: profile.location,
                  onBackPressed: () {
                    _log(ButtonIds.bedroomWallBack);
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BedroomWallView(
                      profile: profile,
                      stickerCatalog: stickerCatalog,
                      fontCatalog: fontCatalog,
                      onImageTap: (image) {
                        _log(ButtonIds.bedroomWall);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BedroomWallDetailPage(
                              viewerUserId: viewerUserId,
                              logger: logger,
                              profile: profile,
                              image: image,
                            ),
                          ),
                        );
                      },
                      onTextTap: (textbox) {
                        _log(ButtonIds.bedroomWall);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BedroomWallDetailPage(
                              viewerUserId: viewerUserId,
                              logger: logger,
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
