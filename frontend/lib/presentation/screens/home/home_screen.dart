import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AppColors {
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF161616);
  static const Color primary = Color(0xFF5A0E1A);
  static const Color primaryLight = Color(0xFF801424);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Color> _spotifyCardColors = const [
    Color(0xFFE9967A),
    Color(0xFF6495ED),
    Color(0xFFF0E68C),
    Color(0xFFDB7093),
    Color(0xFF9370DB),
    Color(0xFF20B2AA),
  ];

  @override
  Widget build(BuildContext context) {
    dynamic artistProv;
    try {
      artistProv = context.watch<dynamic>();
    } catch (_) {}

    final List<dynamic> artists = (artistProv != null && artistProv.artists != null) 
        ? artistProv.artists 
        : [
            _MockArtist('Ulukmanapo', 'https://via.placeholder.com/150'),
            _MockArtist('Jax (02.14)', 'https://via.placeholder.com/150'),
            _MockArtist('Мирбек Атабеков', 'https://via.placeholder.com/150'),
            _MockArtist('Jah Khalib', 'https://via.placeholder.com/150'),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Все',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Музыка',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Популярные радиостанции'),
              const SizedBox(height: 12),
              _buildSpotifyStationCarousel(artists),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Бесконечная подборка с твоими любимыми треками и исполнителями.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              _buildSectionHeader('Рекомендуемые станции'),
              const SizedBox(height: 12),
              _buildSpotifyStationCarousel(artists.reversed.toList()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            'Показать все',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotifyStationCarousel(List<dynamic> artists) {
    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: artists.length,
        itemBuilder: (ctx, index) {
          final artist = artists[index];
          final cardColor = _spotifyCardColors[index % _spotifyCardColors.length];

          return Container(
            width: 175,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Icon(Icons.radio, size: 14, color: Colors.black.withOpacity(0.5)),
                          ),
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Text(
                              'РАДИО',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: const ClipOval(
                                child: Icon(Icons.person, size: 50, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 55,
                      child: Text(
                        artist.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    'Включает треки ${artist.name} и других похожих исполнителей.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MockArtist {
  final String name;
  final String imageUrl;
  _MockArtist(this.name, this.imageUrl);
}