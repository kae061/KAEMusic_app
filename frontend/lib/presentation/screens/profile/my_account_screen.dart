import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../router/app_router.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _displayNameController;
  bool _isSavingName = false;
  bool _isUpdatingAvatar = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      auth.loadCurrentUser();
      debugPrint('User authenticated: ${auth.isAuthenticated}');
      debugPrint('User id: ${auth.user?.id}');
      debugPrint('Display name: ${auth.displayName}');
      debugPrint('Avatar URL: ${auth.avatarUrl}');
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _syncDisplayName(String? displayName) {
    final value = displayName ?? '';
    if (_displayNameController.text != value) {
      _displayNameController.text = value;
    }
  }

  Future<void> _pickAndUploadAvatar(AuthProvider auth) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isUpdatingAvatar = true);
    final success = await auth.uploadAvatarFile(image.path, image.name);
    if (!mounted) return;
    setState(() => _isUpdatingAvatar = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile picture updated.' : 'Failed to upload image.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteAvatar(AuthProvider auth) async {
    setState(() => _isUpdatingAvatar = true);
    final success = await auth.deleteAvatar();
    if (!mounted) return;
    setState(() => _isUpdatingAvatar = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile picture removed.' : 'Failed to remove picture.',
          ),
        ),
      );
    }
  }

  void _showAvatarOptions(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.textPrimary),
              title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(auth);
              },
            ),
            if (auth.avatarUrl != null && auth.avatarUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteAvatar(auth);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Profile Data', style: TextStyle(color: AppColors.textPrimary)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final avatarUrl = auth.avatarUrl ?? auth.user?.avatarUrl;
            final resolvedAvatar = AppConstants.resolveMediaUrl(avatarUrl);

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isUpdatingAvatar ? null : () => _showAvatarOptions(ctx, auth),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.surfaceVariant,
                            child: _buildAvatar(resolvedAvatar, auth),
                          ),
                          if (_isUpdatingAvatar)
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0x88000000),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          if (!_isUpdatingAvatar)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _displayNameController,
                    enabled: !_isSavingName,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSavingName
                            ? null
                            : () async {
                                final newName = _displayNameController.text.trim();
                                if (newName.isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Display name cannot be empty.')),
                                  );
                                  return;
                                }

                                setDialogState(() => _isSavingName = true);
                                final success = await auth.updateDisplayName(newName);
                                if (!mounted) return;
                                setDialogState(() => _isSavingName = false);

                                if (success && mounted) {
                                  Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(content: Text('Display name updated.')),
                                    );
                                  }
                                } else if (mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Failed to update display name.')),
                                  );
                                }
                              },
                        child: _isSavingName
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout(AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out of KAEMusic?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await auth.logout();
    if (!mounted) return;
    context.go(AppRouter.login);
  }

  Widget _buildAvatar(String resolvedAvatar, AuthProvider auth) {
    if (resolvedAvatar.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          resolvedAvatar,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const SizedBox(
              width: 100,
              height: 100,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (_, __, ___) => _fallbackAvatar(auth),
        ),
      );
    }
    return _fallbackAvatar(auth);
  }

  Widget _fallbackAvatar(AuthProvider auth) {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: AppColors.textDisabled,
        child: const Center(
          child: Icon(
            Icons.person,
            size: 50,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.lightBlueAccent,
              AppColors.oceanBlue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            _syncDisplayName(auth.displayName ?? auth.user?.displayName);

            final avatarUrl = auth.avatarUrl ?? auth.user?.avatarUrl;
            final resolvedAvatar = AppConstants.resolveMediaUrl(avatarUrl);
            final displayName = auth.displayName ?? auth.user?.displayName ?? auth.user?.username ?? 'Listener';

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: _buildAvatar(resolvedAvatar, auth),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, size: 28),
                          color: Colors.white,
                          onPressed: () => _showProfileDialog(context, auth),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Profile Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Card(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: Colors.white,
                            ),
                            title: Text(
                              themeProvider.isDarkMode ? 'Dark Theme' : 'Light Theme',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                              activeTrackColor: Colors.white,
                              activeThumbColor: const Color(0xFF4682B4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () => _confirmLogout(auth),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}