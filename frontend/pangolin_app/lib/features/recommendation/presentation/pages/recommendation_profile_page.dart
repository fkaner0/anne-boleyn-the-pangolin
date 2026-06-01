import 'package:flutter/material.dart';
import '../../data/profile_fetcher.dart';
import '../../domain/profile.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile>(
      future: profileFetcher.fetchProfile(userId),
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

        final profile = snapshot.data!;

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
                    child: BedroomWallView(profile: profile),
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
