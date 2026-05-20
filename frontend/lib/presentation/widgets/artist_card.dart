import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/artist.dart';
import '../router/app_router.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRouter.artist(artist.id)),
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            ClipOval(
              child: artist.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: artist.imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const Text(
              'Artist',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: AppColors.textSecondary, size: 44),
      );
}
