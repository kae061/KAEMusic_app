import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../widgets/add_to_playlist_bottom_sheet.dart';
import '../../../data/models/track_model.dart';
import 'add_tracks_bottom_sheet.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylistDetail(widget.playlistId);
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistProv = context.watch<PlaylistProvider>();
    final favProv = context.watch<FavoritesProvider>();
    final player = context.read<PlayerProvider>();

    final playlist = playlistProv.selectedPlaylist;

    if (playlistProv.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: LoadingIndicator()),
      );
    }

    if (playlistProv.error != null || playlist == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorView(
          message: playlistProv.error ?? 'Playlist not found',
          onRetry: () {
            context.read<PlaylistProvider>().loadPlaylistDetail(widget.playlistId);
          },
        ),
      );
    }

    final List<Track> tracks = playlist.tracks ?? [];

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
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                    tooltip: 'Rename Playlist',
                    onPressed: () {
                      final controller = TextEditingController(text: playlist.name);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('Rename Playlist', style: TextStyle(color: AppColors.textPrimary)),
                          content: TextField(
                            controller: controller,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(labelText: 'New Name'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final name = controller.text.trim();
                                if (name.isNotEmpty) {
                                  Navigator.pop(ctx);
                                  await playlistProv.renamePlaylist(playlist.id, name);
                                }
                              },
                              child: const Text('Rename'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: 'Delete Playlist',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('Delete Playlist', style: TextStyle(color: AppColors.textPrimary)),
                          content: Text('Are you sure you want to delete "${playlist.name}"?', style: const TextStyle(color: AppColors.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                await playlistProv.deletePlaylist(playlist.id);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (playlist.coverUrl != null)
                        Opacity(
                          opacity: 0.15,
                          child: CachedNetworkImage(
                            imageUrl: playlist.coverUrl!,
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
                              child: playlist.coverUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: playlist.coverUrl!,
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

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        playlist.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (playlist.description != null && playlist.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          playlist.description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Created by Antigravity • ${tracks.length} track${tracks.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 20),
                            label: const Text('Play All'),
                            onPressed: () {
                              if (tracks.isNotEmpty) {
                                player.playQueue(tracks, startIndex: 0);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              foregroundColor: AppColors.textPrimary,
                            ),
                            icon: const Icon(Icons.shuffle_rounded, size: 18, color: AppColors.primary),
                            label: const Text('Shuffle'),
                            onPressed: () {
                              if (tracks.isNotEmpty) {
                                final list = List<Track>.from(tracks)..shuffle();
                                player.playQueue(list, startIndex: 0);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              foregroundColor: AppColors.textPrimary,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                            label: const Text('Add Songs'),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => AddTracksBottomSheet(playlist: playlist),
                              ).whenComplete(() {
                                if (context.mounted) {
                                  context.read<PlaylistProvider>().loadPlaylistDetail(playlist.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              if (tracks.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No tracks inside this playlist yet. Add tracks to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      final track = tracks[index];
                      final isCurrent = player.currentTrack?.id == track.id;
                      final isPlaying = isCurrent && player.isPlaying;
                      final isLiked = favProv.isFavorited(track.id);

                      final durationMin = ((track.durationSeconds ?? 0) / 60).floor();
                      final durationSec = (track.durationSeconds ?? 0) % 60;
                      final durationFormatted = '$durationMin:${durationSec.toString().padLeft(2, '0')}';

                      return Dismissible(
                        key: ValueKey('playlist_${playlist.id}_track_${track.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          playlistProv.removeTrack(playlist.id, track.id);
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  track.coverArtUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: track.coverArtUrl!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => _placeholderTrack(),
                                        )
                                      : _placeholderTrack(),
                                  if (isCurrent)
                                    Container(
                                      color: Colors.black54,
                                      child: Icon(
                                        isPlaying ? Icons.equalizer_rounded : Icons.pause_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          title: Text(
                            track.title,
                            style: TextStyle(
                              color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track.artist,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                durationFormatted,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isLiked ? AppColors.primary : AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  favProv.toggleFavorite(track.id, trackPlaceholder: track);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.playlist_add_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => showAddToPlaylistBottomSheet(context, track),
                              ),
                            ],
                          ),
                          onTap: () {
                            player.playQueue(tracks, startIndex: index);
                          },
                        ),
                      );
                    },
                    childCount: tracks.length,
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
        child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 48),
      );

  Widget _placeholderTrack() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 20),
      );
}
