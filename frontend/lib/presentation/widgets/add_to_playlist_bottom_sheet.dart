import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/track_model.dart';
import '../providers/playlist_provider.dart';

class AddToPlaylistBottomSheet extends StatefulWidget {
  final Track track;

  const AddToPlaylistBottomSheet({
    super.key,
    required this.track,
  });

  @override
  State<AddToPlaylistBottomSheet> createState() => _AddToPlaylistBottomSheetState();
}

class _AddToPlaylistBottomSheetState extends State<AddToPlaylistBottomSheet> {
  bool _isCreating = false;
  String? _savingPlaylistId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlaylistProvider>();
      if (provider.playlists.isEmpty && !provider.isLoading) {
        provider.loadPlaylists();
      }
    });
  }

  Future<void> _showCreatePlaylistDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: !_isCreating,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
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
                    hintText: 'My playlist',
                  ),
                  enabled: !_isCreating,
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add description...',
                  ),
                  enabled: !_isCreating,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isCreating ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isNameEmpty || _isCreating
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final description = descController.text.trim();

                        setDialogState(() {
                          _isCreating = true;
                          errorMessage = null;
                        });

                        final provider = context.read<PlaylistProvider>();
                        await provider.createPlaylist(
                          name,
                          description.isEmpty ? null : description,
                        );

                        if (!ctx.mounted) return;

                        final error = provider.error;
                        if (error != null) {
                          setDialogState(() {
                            errorMessage = error;
                            _isCreating = false;
                          });
                          return;
                        }

                        setDialogState(() {
                          _isCreating = false;
                        });
                        Navigator.pop(ctx);
                      },
                child: _isCreating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    descController.dispose();
  }

  Future<void> _addToPlaylist(String playlistId, String playlistName) async {
    setState(() {
      _savingPlaylistId = playlistId;
    });

    final provider = context.read<PlaylistProvider>();
    await provider.addTrack(playlistId, widget.track.id);

    if (!mounted) return;

    setState(() {
      _savingPlaylistId = null;
    });

    final error = provider.error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${widget.track.title}" added to "$playlistName".')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        final playlistProv = context.watch<PlaylistProvider>();

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add to playlist',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.track.title,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                      tooltip: 'Create playlist',
                      onPressed: _showCreatePlaylistDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: playlistProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : playlistProv.playlists.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.library_music_rounded, color: AppColors.textSecondary, size: 56),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No playlists yet. Create one first.',
                                    style: TextStyle(color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _showCreatePlaylistDialog,
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Create Playlist'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: playlistProv.playlists.length,
                            itemBuilder: (ctx, index) {
                              final playlist = playlistProv.playlists[index];
                              final isAlreadyAdded = playlist.tracks?.any((track) => track.id == widget.track.id) ?? false;
                              final isSaving = _savingPlaylistId == playlist.id;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.queue_music_rounded, color: AppColors.textSecondary),
                                ),
                                title: Text(
                                  playlist.name,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${playlist.tracks?.length ?? playlist.trackCount} track${(playlist.tracks?.length ?? playlist.trackCount) == 1 ? '' : 's'}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                trailing: isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Icon(
                                        isAlreadyAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                        color: isAlreadyAdded ? Colors.green : AppColors.primary,
                                      ),
                                onTap: isSaving || isAlreadyAdded ? null : () => _addToPlaylist(playlist.id, playlist.name),
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

void showAddToPlaylistBottomSheet(BuildContext context, Track track) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddToPlaylistBottomSheet(track: track),
  );
}
