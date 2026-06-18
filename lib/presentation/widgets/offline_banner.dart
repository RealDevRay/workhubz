import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  final String? offlineMessage;
  final String? onlineMessage;

  const OfflineBanner({
    super.key,
    required this.isOnline,
    this.offlineMessage,
    this.onlineMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      if (onlineMessage == null) return const SizedBox.shrink();
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: AppColors.success.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_done,
              color: AppColors.success,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              onlineMessage ?? 'Back online',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              offlineMessage ?? 'You\'re offline. Some features may be limited.',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineOverlay extends StatelessWidget {
  final Widget child;

  const OfflineOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'You\'re Offline',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Browsing cached data only',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
