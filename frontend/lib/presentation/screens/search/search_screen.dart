import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/search_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  final List<Map<String, dynamic>> _genres = const [
    {'name': 'Поп', 'color': Color(0xFF5A0E1A)},
    {'name': 'Рок', 'color': Color(0xFF801424)},
    {'name': 'Рэп', 'color': Color(0xFF4A0A13)},
    {'name': 'Хип-хоп', 'color': Color(0xFF38050E)},
    {'name': 'K-Pop', 'color': Color(0xFF9E1B32)},
    {'name': 'Джаз', 'color': Color(0xFF6B0B18)},
    {'name': 'Электроника', 'color': Color(0xFFBD1E37)},
    {'name': 'Инди', 'color': Color(0xFF2E0308)},
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<SearchProvider>().performSearch(query);
    });
  }

  void _searchNow(String query) {
    _debounce?.cancel();
    context.read<SearchProvider>().performSearch(query);
  }

  void _submitSearch(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;
    final searchProv = context.read<SearchProvider>();
    searchProv.saveRecentSearch(normalizedQuery);
    searchProv.performSearch(normalizedQuery);
  }

  void _setSearchQuery(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() {});
    _submitSearch(query);
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = context.watch<SearchProvider>();

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  onChanged: (val) {
                    _onSearchChanged(val);
                    setState(() {});
                  },
                  onSubmitted: _submitSearch,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Введите название песни...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              _controller.clear();
                              _searchNow('');
                              searchProv.clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _controller.text.isEmpty
                      ? _buildGenresAndRecent(searchProv)
                      : _buildSearchResults(searchProv),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenresAndRecent(SearchProvider searchProv) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchProv.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'История поиска',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: searchProv.clearRecentSearches,
                  child: const Text('Очистить', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchProv.recentSearches.length,
              itemBuilder: (ctx, index) {
                final query = searchProv.recentSearches[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
                  title: Text(
                    query,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                    onPressed: () => searchProv.removeRecentSearch(query),
                  ),
                  onTap: () => _setSearchQuery(query),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Жанры музыки',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _genres.length,
            itemBuilder: (ctx, index) {
              final genre = _genres[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _setSearchQuery(genre['name'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [genre['color'], genre['color'].withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    genre['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProv) {
    if (searchProv.isSearching) {
      return const Center(child: LoadingIndicator());
    }

    if (searchProv.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено по запросу "${_controller.text}"',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Результаты поиска',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: searchProv.results.length,
            itemBuilder: (ctx, index) {
              final track = searchProv.results[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
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
                  searchProv.saveRecentSearch(_controller.text);
                  final player = context.read<PlayerProvider>();
                  player.playQueue(searchProv.results, startIndex: index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[900],
      child: const Icon(Icons.music_note, color: Colors.grey),
    );
  }
}