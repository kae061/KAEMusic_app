import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/song_provider.dart';
import 'presentation/providers/player_provider.dart';
import 'presentation/providers/album_provider.dart';
import 'presentation/providers/artist_provider.dart';
import 'presentation/providers/playlist_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/router/app_router.dart';

import 'presentation/providers/music_catalog_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'data/datasources/track_remote_datasource.dart';
import 'core/network/dio_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(),
          update: (_, auth, favorites) {
            if (auth.isAuthenticated) {
              favorites?.loadFavorites();
            }
            return favorites ?? FavoritesProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) => SongProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AlbumProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ArtistProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MusicCatalogProvider(TrackRemoteDataSource(DioClient())),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(TrackRemoteDataSource(DioClient())),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(context);
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp.router(
            title: 'KAEMusic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
