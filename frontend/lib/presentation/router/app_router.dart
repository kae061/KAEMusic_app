import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/player/player_screen.dart';
import '../screens/album/album_detail_screen.dart';
import '../screens/artist/artist_detail_screen.dart';
import '../screens/playlist/playlist_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/my_account_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  static const String profile = '/profile';
  static const String myAccount = '/my-account';
  static const String player = '/player';
  static String album(String id) => '/album/$id';
  static String artist(String id) => '/artist/$id';
  static String playlist(String id) => '/playlist/$id';

  static GoRouter createRouter(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        final status = authProvider.status;
        final onSplash = state.matchedLocation == splash;
        final onAuthPage = state.matchedLocation == login ||
            state.matchedLocation == register;

        if (status == AuthStatus.initial) {
          return null; // Stay on splash while checking auth
        }

        if (status == AuthStatus.unauthenticated) {
          if (!onAuthPage) {
            return login;
          }
        }

        if (status == AuthStatus.authenticated) {
          if (onSplash || onAuthPage) {
            return home;
          }
        }

        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: splash,
          builder: (ctx, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          builder: (ctx, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (ctx, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (ctx, state, child) => AppScaffold(child: child),
          routes: [
            GoRoute(
              path: home,
              builder: (ctx, state) => const CatalogScreen(),
            ),
            GoRoute(
              path: search,
              builder: (ctx, state) => const SearchScreen(),
            ),
            GoRoute(
              path: library,
              builder: (ctx, state) => const LibraryScreen(),
            ),
            GoRoute(
              path: profile,
              builder: (ctx, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: myAccount,
              builder: (ctx, state) => const MyAccountScreen(),
            ),
          ],
        ),
        GoRoute(
          path: player,
          builder: (ctx, state) => const PlayerScreen(),
        ),
        GoRoute(
          path: '/album/:id',
          builder: (ctx, state) => AlbumDetailScreen(
            albumId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/artist/:id',
          builder: (ctx, state) => ArtistDetailScreen(
            artistId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/playlist/:id',
          builder: (ctx, state) => PlaylistDetailScreen(
            playlistId: state.pathParameters['id']!,
          ),
        ),
      ],
      errorBuilder: (ctx, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }
}
