import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';

class QrCheckinView extends StatefulWidget {
  final String checkInCode;
  final String bookingId;
  final String spaceName;
  final DateTime checkInTime;
  final bool isCheckedIn;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCheckOut;

  const QrCheckinView({
    super.key,
    required this.checkInCode,
    required this.bookingId,
    required this.spaceName,
    required this.checkInTime,
    required this.isCheckedIn,
    this.onCheckIn,
    this.onCheckOut,
  });

  @override
  State<QrCheckinView> createState() => _QrCheckinViewState();
}

class _QrCheckinViewState extends State<QrCheckinView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status indicator
          if (widget.isCheckedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Checked In',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warning, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.pending, color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Ready to Check In',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Space name
          Text(
            widget.spaceName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ID: ${widget.bookingId.substring(0, 8)}...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: QrImageView(
              data: widget.checkInCode,
              version: QrVersions.auto,
              size: 250,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Check-In Instructions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Show this QR code to the reception staff\n2. They will scan it to confirm your check-in\n3. You can now access the workspace',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Buttons
          if (!widget.isCheckedIn && widget.onCheckIn != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onCheckIn,
                icon: const Icon(Icons.check_circle),
                label: const Text('Manually Check In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          else if (widget.isCheckedIn && widget.onCheckOut != null)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Checked in at',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _formatTime(widget.checkInTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onCheckOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Check Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareQRCode,
              icon: const Icon(Icons.share),
              label: const Text('Share QR Code'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} - ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _shareQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code shared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class QrScannerOverlay extends StatelessWidget {
  final double size;

  const QrScannerOverlay({
    super.key,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Dimmed areas
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          // Transparent center
          Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.success,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Corner highlights
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  // Top-left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                          left: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Top-right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                          left: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: AppColors.success,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
