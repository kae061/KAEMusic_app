import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/track_model.dart';
import '../../domain/entities/song.dart';
import '../providers/player_provider.dart';
import '../providers/favorites_provider.dart';
import 'add_to_playlist_bottom_sheet.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song> queue;
  final int indexInQueue;
  final VoidCallback? onLikeTap;
  final VoidCallback? onAddToPlaylistTap;
  final bool showLikeButton;
  final bool? isLikedOverride;

  const SongTile({
    super.key,
    required this.song,
    required this.queue,
    required this.indexInQueue,
    this.onLikeTap,
    this.onAddToPlaylistTap,
    this.showLikeButton = true,
    this.isLikedOverride,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isPlaying = player.currentSong?.id == song.id && player.isPlaying;
    final isCurrent = player.currentSong?.id == song.id;
    final addToPlaylistAction = onAddToPlaylistTap ?? () => showAddToPlaylistBottomSheet(context, _songToTrack(song));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            fit: StackFit.expand,
            children: [
              song.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: song.coverUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
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
        song.title,
        style: TextStyle(
          color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artistName}${song.albumTitle != null ? ' • ${song.albumTitle}' : ''}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            song.durationFormatted,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          if (showLikeButton) ...[
            const SizedBox(width: 4),
            Consumer<FavoritesProvider>(
              builder: (context, favProv, _) {
                final isLiked = isLikedOverride ?? favProv.isFavorited(song.id);
                return IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? Colors.redAccent : AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onLikeTap ?? () => favProv.toggleFavorite(song.id, trackPlaceholder: _songToTrack(song)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                );
              },
            ),
          ],
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.playlist_add_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: addToPlaylistAction,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
      onTap: () {
        context.read<PlayerProvider>().playSongQueue(queue, startIndex: indexInQueue);
      },
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 20),
      );

  Track _songToTrack(Song song) {
    return Track(
      id: song.id,
      title: song.title,
      artist: song.artistName,
      album: song.albumTitle,
      durationSeconds: song.duration.inSeconds,
      streamUrl: song.audioUrl,
      coverArtUrl: song.coverUrl,
    );
  }
}
