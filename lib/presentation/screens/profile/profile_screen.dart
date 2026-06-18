import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider);
    final isLoggedIn = user != null;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 64, color: AppColors.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'Sign in to manage your profile',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(signInWithGoogleProvider(null).future);
                },
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                  height: 20,
                  width: 20,
                ),
                label: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildProfileHeader(textTheme, user),
          const SizedBox(height: 16),
          _buildPromoBanner(textTheme),
          const SizedBox(height: 20),
          _buildSectionTitle(textTheme, 'Account'),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.bookmark,
                title: 'Saved Spaces',
                subtitle: 'Your favorite work spots',
                onTap: () {
                  context.push('/saved-spaces');
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.history,
                title: 'Payment History',
                subtitle: 'Invoices and receipts',
                onTap: () {
                  context.push('/payment-history');
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Preferences and account',
                onTap: () => _showSettingsBottomSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(textTheme, 'Support'),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Chat with the WorkHubz team',
                onTap: () async {
                  final url = Uri.parse('https://wa.me/254700000000'); // Replace with actual number
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version and company details',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'WorkHubz',
                    applicationVersion: '1.0.0',
                    applicationIcon: Image.asset('assets/branding/app_icon_legacy.png', width: 48, height: 48),
                    children: [
                      const Text('Find and book workspaces in Nairobi. WorkHubz helps you locate the perfect environment for your work.'),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMenuCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Sign out of WorkHubz',
                textColor: AppColors.error,
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(TextTheme textTheme, User? user) {
    final displayName = user?.userMetadata?['full_name'] as String? ?? 'User';
    final email = user?.email ?? '';
    final photoUrl = user?.userMetadata?['avatar_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.onPrimary,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 28, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildStat(textTheme, 'Saved', '0'),
                _buildStat(textTheme, 'Bookings', '0'),
                _buildStat(textTheme, 'Reviews', '0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(TextTheme textTheme, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        color: AppColors.onBackground,
      ),
    );
  }

  Widget _buildPromoBanner(TextTheme textTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppColors.surface,
        child: Stack(
          children: [
            Image.asset(
              'assets/branding/promo_banner.png',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Your next workspace, sorted',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.onSurface),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Notifications'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: false,
                onChanged: (value) {},
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
