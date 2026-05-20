import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/music_catalog_provider.dart';
import '../../providers/player_provider.dart';

import '../../widgets/loading_indicator.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicCatalogProvider>().loadTracks();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MusicCatalogProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<MusicCatalogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tracks.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.tracks.isEmpty) {
            return const Center(child: Text('No tracks available.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTracks(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.tracks.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.tracks.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final track = provider.tracks[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: track.coverArtUrl != null
                        ? CachedNetworkImage(
                            imageUrl: track.coverArtUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _buildFallbackIcon(),
                          )
                        : _buildFallbackIcon(),
                  ),
                  title: Text(
                    track.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    track.artist,
                    style: const TextStyle(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDuration(track.durationSeconds),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () {
                    final player = context.read<PlayerProvider>();
                    player.playQueue(provider.tracks, startIndex: index);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 50,
      height: 50,
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.music_note, color: AppColors.textSecondary),
    );
  }
}
