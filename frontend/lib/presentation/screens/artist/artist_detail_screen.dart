import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/artist_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;
  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArtistProvider>().loadArtistDetail(widget.artistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final artistProv = context.watch<ArtistProvider>();

    final artist = artistProv.selectedArtist;
    final albums = artistProv.artistAlbums;
    final songs = artistProv.artistSongs;

    if (artistProv.isLoadingDetail) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (artistProv.error != null || artist == null) {
      return Scaffold(
        body: ErrorView(
          message: artistProv.error ?? 'Artist not found',
          onRetry: () {
            context.read<ArtistProvider>().loadArtistDetail(widget.artistId);
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
              // Massive Artist Banner with verified status
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      artist.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: artist.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : _placeholderBanner(),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'VERIFIED ARTIST',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              artist.name,
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_formatListeners(artist.monthlyListeners)} monthly listeners',
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bio details
              if (artist.bio != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Biography',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          artist.bio!,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

              // Artist Albums Section
              if (albums.isNotEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          'Albums',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: albums.length,
                          itemBuilder: (ctx, index) {
                            final album = albums[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: AlbumCard(album: album),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

              // Top tracks heading
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Popular Songs',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Popular songs list
              if (songs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('No songs available', style: TextStyle(color: AppColors.textSecondary)),
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

  String _formatListeners(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }

  Widget _placeholderBanner() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.person, color: AppColors.textSecondary, size: 72),
      );
}
