import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/song_tile.dart';
import '../playlist/playlist_list_screen.dart';
import '../../../data/models/track_model.dart';
import '../../../domain/entities/song.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
      context.read<PlaylistProvider>().loadPlaylists();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Song _trackToSong(Track track) {
    return Song(
      id: track.id,
      title: track.title,
      artistId: '',
      artistName: track.artist,
      albumTitle: track.album,
      audioUrl: track.streamUrl,
      coverUrl: track.coverArtUrl,
      duration: Duration(seconds: track.durationSeconds ?? 0),
      releasedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProv = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Library',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Playlists'),
            Tab(text: 'Liked Songs'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            const PlaylistListScreen(),
            _buildLikedSongsTab(favoritesProv),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedSongsTab(FavoritesProvider favoritesProv) {
    if (favoritesProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoritesProv.favoritesTracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No liked songs yet. Tap the heart on any track to add it here.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final songs = favoritesProv.favoritesTracks.map(_trackToSong).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: songs.length,
      itemBuilder: (ctx, index) {
        final song = songs[index];
        return Consumer<FavoritesProvider>(
          builder: (context, favProv, _) => SongTile(
            song: song,
            queue: songs,
            indexInQueue: index,
            isLikedOverride: favProv.isFavorited(song.id),
            onLikeTap: () => favProv.toggleFavorite(song.id),
          ),
        );
      },
    );
  }
}
