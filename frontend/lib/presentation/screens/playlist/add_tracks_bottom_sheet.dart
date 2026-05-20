import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/search_provider.dart';
import '../../../domain/entities/playlist.dart';
import '../../widgets/loading_indicator.dart';

class AddTracksBottomSheet extends StatefulWidget {
  final Playlist playlist;
  const AddTracksBottomSheet({super.key, required this.playlist});

  @override
  State<AddTracksBottomSheet> createState() => _AddTracksBottomSheetState();
}

class _AddTracksBottomSheetState extends State<AddTracksBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().clearSearch();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<SearchProvider>().performSearch(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final searchProv = context.watch<SearchProvider>();
        final playlistProv = context.watch<PlaylistProvider>();

        // Get the latest playlist state from the provider to reactively update checkmarks
        final currentPlaylist = playlistProv.playlists.firstWhere(
          (p) => p.id == widget.playlist.id,
          orElse: () => widget.playlist,
        );

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Grabber/Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Add Songs to ${currentPlaylist.name}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search for tracks...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              searchProv.clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Results List
              Expanded(
                child: searchProv.isSearching
                    ? const Center(child: LoadingIndicator())
                    : searchProv.results.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Type to search tracks'
                                  : 'No tracks found',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: searchProv.results.length,
                            itemBuilder: (context, index) {
                              final track = searchProv.results[index];
                              final isAlreadyAdded = currentPlaylist.tracks?.any((t) => t.id == track.id) ?? false;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: track.coverArtUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: track.coverArtUrl!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => const Icon(Icons.music_note, color: AppColors.textSecondary),
                                        )
                                      : const Icon(Icons.music_note, color: AppColors.textSecondary),
                                ),
                                title: Text(
                                  track.title,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  track.artist,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: isAlreadyAdded
                                    ? const Icon(Icons.check_circle_rounded, color: Colors.grey)
                                    : IconButton(
                                        icon: const Icon(Icons.add_circle_rounded, color: Colors.green),
                                        onPressed: () {
                                          playlistProv.addTrack(currentPlaylist.id, track.id);
                                        },
                                      ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
