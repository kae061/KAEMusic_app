import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/album_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;
  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlbumProvider>().loadAlbumDetail(widget.albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final albumProv = context.watch<AlbumProvider>();
    final player = context.read<PlayerProvider>();

    final album = albumProv.selectedAlbum;
    final songs = albumProv.albumSongs;

    if (albumProv.isLoadingSongs) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (albumProv.error != null || album == null) {
      return Scaffold(
        body: ErrorView(
          message: albumProv.error ?? 'Album not found',
          onRetry: () {
            context.read<AlbumProvider>().loadAlbumDetail(widget.albumId);
          },
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Premium Hero Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred back image
                      if (album.coverUrl != null)
                        Opacity(
                          opacity: 0.15,
                          child: CachedNetworkImage(
                            imageUrl: album.coverUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.background],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Core centered artwork + metadata
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: album.coverUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: album.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Album description & details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        album.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        album.artistName,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Album • ${songs.length} tracks • ${album.releasedAt.year}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Direct Play and Shuffle buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 24),
                            label: const Text('Play'),
                            onPressed: () {
                              if (songs.isNotEmpty) {
                                player.playSongQueue(songs, startIndex: 0);
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              foregroundColor: AppColors.textPrimary,
                            ),
                            icon: const Icon(Icons.shuffle_rounded, size: 20, color: AppColors.primary),
                            label: const Text('Shuffle'),
                            onPressed: () {
                              if (songs.isNotEmpty) {
                                final list = List<dynamic>.from(songs)..shuffle();
                                player.playSongQueue(list.cast(), startIndex: 0);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Tracks List
              if (songs.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No tracks in this album',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      return SongTile(
                        song: songs[index],
                        queue: songs,
                        indexInQueue: index,
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.album, color: AppColors.textSecondary, size: 48),
      );
}
