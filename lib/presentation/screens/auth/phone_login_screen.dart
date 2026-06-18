import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerWidget {
  final String? redirectTo;

  const PhoneLoginScreen({
    super.key,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.workspaces_filled,
                  size: 54,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'WorkHubz',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Find and book workspaces in Nairobi',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final redirect = redirectTo ?? 'io.supabase.flutter://callback';
                    await ref.read(signInWithGoogleProvider(redirect).future);
                    // After successful sign-in (deep link resumes), navigate to redirect if provided
                    if (redirect.isNotEmpty && redirect != 'io.supabase.flutter://callback') {
                      if (context.mounted) {
                        context.go(redirect);
                      }
                    }
                  },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
