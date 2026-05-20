import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _initials(AuthProvider auth) {
    final source = auth.displayName ?? auth.user?.displayName ?? auth.user?.username ?? '';
    final trimmed = source.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  /// Builds the avatar widget with try/catch fallback pattern.
  Widget _buildAvatar(String resolvedAvatar, AuthProvider auth) {
    if (resolvedAvatar.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          resolvedAvatar,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(auth),
        ),
      );
    }
    return _fallbackAvatar(auth);
  }

  /// Fallback: local asset → initials.
  Widget _fallbackAvatar(AuthProvider auth) {
    return ClipOval(
      child: Image.asset(
        'assets/images/default_avatar.png',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(
          width: 80,
          height: 80,
          child: Center(
            child: Text(
              _initials(auth),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final displayName =
                auth.displayName ?? auth.user?.displayName ?? auth.user?.username ?? 'Listener';
            final avatarUrl = auth.avatarUrl ?? auth.user?.avatarUrl;
            final resolvedAvatar = AppConstants.resolveMediaUrl(avatarUrl);
            final email = auth.user?.email ?? '';
            final username = auth.user?.username ?? '';

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.surfaceVariant,
                        child: _buildAvatar(resolvedAvatar, auth),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            if (username.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '@$username',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.manage_accounts, color: AppColors.primary),
                        title: const Text(
                          'My Account',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () => context.push(AppRouter.myAccount),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
