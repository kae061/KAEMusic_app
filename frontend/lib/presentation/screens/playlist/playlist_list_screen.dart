import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/playlist_provider.dart';
import '../../../domain/entities/playlist.dart';
import '../../router/app_router.dart';
import '../../widgets/loading_indicator.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  State<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().loadPlaylists();
    });
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isSaving = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isNameEmpty = nameController.text.trim().isEmpty;
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Create Playlist',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    hintText: 'My sweet playlist',
                  ),
                  onChanged: (_) => setState(() {}),
                  enabled: !isSaving,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'A chill mix for modular coding...',
                  ),
                  enabled: !isSaving,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (isNameEmpty || isSaving)
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();
                        setState(() {
                          isSaving = true;
                          errorMessage = null;
                        });
                        
                        final playlistProvider = context.read<PlaylistProvider>();
                        await playlistProvider.createPlaylist(
                              name,
                              desc.isEmpty ? null : desc,
                            );
                        
                        final error = playlistProvider.error;
                        if (error != null) {
                          setState(() {
                            errorMessage = error;
                            isSaving = false;
                          });
                        } else {
                          if (!ctx.mounted || !context.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Playlist created successfully.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRenamePlaylistDialog(BuildContext context, Playlist playlist) {
    final nameController = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Rename Playlist',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'New Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                await context.read<PlaylistProvider>().renamePlaylist(
                      playlist.id,
                      name,
                    );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(BuildContext context, Playlist playlist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Playlist',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PlaylistProvider>().deletePlaylist(playlist.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlistProv = context.watch<PlaylistProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent, // Let parent background show through
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _buildContent(context, playlistProv),
    );
  }

  Widget _buildContent(BuildContext context, PlaylistProvider playlistProv) {
    if (playlistProv.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (playlistProv.playlists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_rounded, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No playlists yet. Tap + to create one.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80), // Padding for FAB
      itemCount: playlistProv.playlists.length,
      itemBuilder: (ctx, index) {
        final playlist = playlistProv.playlists[index];
        final trackCount = playlist.tracks?.length ?? playlist.trackCount;

        return Dismissible(
          key: ValueKey('playlist_list_${playlist.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.redAccent,
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            _showDeletePlaylistDialog(context, playlist);
            return false; // Handled by dialog
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: playlist.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: playlist.coverUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _playlistPlaceholder(),
                    )
                  : _playlistPlaceholder(),
            ),
            title: Text(
              playlist.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '$trackCount track${trackCount == 1 ? '' : 's'}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
              color: AppColors.card,
              onSelected: (val) {
                if (val == 'rename') {
                  _showRenamePlaylistDialog(context, playlist);
                } else if (val == 'delete') {
                  _showDeletePlaylistDialog(context, playlist);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 18),
                      SizedBox(width: 8),
                      Text('Rename'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
            onLongPress: () {
              _showRenamePlaylistDialog(context, playlist);
            },
            onTap: () => context.push(AppRouter.playlist(playlist.id)),
          ),
        );
      },
    );
  }

  Widget _playlistPlaceholder() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 24),
      );
}
