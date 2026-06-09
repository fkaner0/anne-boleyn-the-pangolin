import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/profile_view/profile_viewer_page.dart';
import 'tmp_fake_page.dart';
import '../features/profile_setup/presentation/pages/login_page.dart';

/// Named route constants — use these everywhere instead of raw strings.
class AppRoutes {
  AppRoutes._();
  static const String login = '/';
  static const String signup = '/signup';
  static const String mainShell = '/main';
  static const String recommendations = '/main/recommendations';
  static const String connections = '/main/connections';
  static const String editProfile = '/main/edit-profile';
  static const String profile = '/main/profile';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // initialLocation: AppRoutes.login,
    initialLocation: AppRoutes.signup,
    routes: [
      // Login page
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const TmpFakePage(pageName: 'LoginPage()'),
      ),

      // Profile Setup section (manages its own internal step state)
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const LoginPage(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        builder: (context, state, child) =>
            const TmpFakePage(pageName: 'MainScaffold(child: child)'),
        routes: [
          GoRoute(
            path: AppRoutes.editProfile,
            builder: (context, state) =>
                const TmpFakePage(pageName: 'EditProfilePage()'),
          ),
          GoRoute(
            path: AppRoutes.recommendations,
            builder: (context, state) =>
                const TmpFakePage(pageName: 'RecommendationsPage()'),
          ),
          GoRoute(
            path: AppRoutes.connections,
            builder: (context, state) =>
                const TmpFakePage(pageName: 'ConnectionsPage()'),
          ),
        ],
      ),

      // Selected user profile
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          /// TODO: what on eart is this userId thing?
          // final userId = state.extra as String? ?? '';
          final userId = 1;
          return ProfileViewerPage(userId: userId);
        },
      ),
    ],

    // Redirect /main to /main/recommendations by default
    redirect: (context, state) {
      if (state.matchedLocation == '/main') {
        return AppRoutes.recommendations;
      }
      return null;
    },
  );
});
