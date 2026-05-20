import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/player_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/add_to_playlist_bottom_sheet.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showQueue = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.currentTrack;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('No track playing', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    // Toggle between main player view and active queue view
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0E17), Color(0xFF07070A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        const Text(
                          'PLAYING FROM QUEUE',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.album ?? 'Single',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _showQueue ? Icons.music_note_rounded : Icons.queue_music_rounded,
                        color: _showQueue ? AppColors.primary : AppColors.textPrimary,
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _showQueue = !_showQueue;
                        });
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showQueue ? _buildQueueView(player) : _buildPlayerCore(player),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCore(PlayerProvider player) {
    final track = player.currentTrack!;
    final favoritesProv = context.watch<FavoritesProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Cover Art with a soft glowing ambient shadows
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: track.coverArtUrl != null
                    ? CachedNetworkImage(
                        imageUrl: track.coverArtUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _coverPlaceholder(),
                      )
                    : _coverPlaceholder(),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Metadata (Title + Artist)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      track.artist,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      favoritesProv.isFavorited(track.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: favoritesProv.isFavorited(track.id) ? Colors.redAccent : AppColors.textSecondary,
                      size: 28,
                    ),
                    onPressed: () => favoritesProv.toggleFavorite(track.id, trackPlaceholder: track),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.playlist_add_rounded,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                    onPressed: () => showAddToPlaylistBottomSheet(context, track),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Custom interactive Seeking Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: player.progress,
              onChanged: player.seekToProgress,
            ),
          ),

          // Progress timestamps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(player.position),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Text(
                  _formatDuration(player.duration),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Core audio buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shuffle button
              IconButton(
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: player.isShuffled ? AppColors.primary : AppColors.textSecondary,
                  size: 24,
                ),
                onPressed: player.toggleShuffle,
              ),

              // Skip previous
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 38),
                onPressed: player.skipToPrevious,
              ),

              // Play / Pause Circle Button
              GestureDetector(
                onTap: player.togglePlayPause,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: player.isBuffering
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                ),
              ),

              // Skip next
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 38),
                onPressed: player.skipToNext,
              ),

              // Repeat mode toggler
              IconButton(
                icon: Icon(
                  player.repeatMode == RepeatMode.none
                      ? Icons.repeat_rounded
                      : (player.repeatMode == RepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded),
                  color: player.repeatMode == RepeatMode.none ? AppColors.textSecondary : AppColors.primary,
                  size: 24,
                ),
                onPressed: player.toggleRepeat,
              ),
            ],
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildQueueView(PlayerProvider player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Queue List',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: player.queue.length,
            itemBuilder: (ctx, index) {
              final track = player.queue[index];
              final isCurrent = player.currentTrack?.id == track.id;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: track.coverArtUrl ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.music_note, color: AppColors.textSecondary),
                  ),
                ),
                title: Text(
                  track.title,
                  style: TextStyle(
                    color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  track.artist,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.equalizer_rounded, color: AppColors.primary)
                    : Text(
                        _formatSeconds(track.durationSeconds),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                onTap: () {
                  player.playQueue(player.queue, startIndex: index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() => Container(
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 80),
      );

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatSeconds(int? totalSeconds) {
    if (totalSeconds == null) return '00:00';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
