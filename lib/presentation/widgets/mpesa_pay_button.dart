import 'package:flutter/material.dart';

class MpesaPayButton extends StatefulWidget {
  final double amount;
  final String spaceName;
  final VoidCallback onPaymentInitiated;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;
  final bool isLoading;
  final String? buttonText;

  const MpesaPayButton({
    super.key,
    required this.amount,
    required this.spaceName,
    required this.onPaymentInitiated,
    this.onPaymentSuccess,
    this.onPaymentFailed,
    this.isLoading = false,
    this.buttonText,
  });

  @override
  State<MpesaPayButton> createState() => _MpesaPayButtonState();
}

class _MpesaPayButtonState extends State<MpesaPayButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0DB42D), // M-Pesa green
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.payment),
        label: Text(
          widget.buttonText ?? 'Pay with M-Pesa (KSh ${widget.amount.toInt()})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _handlePayment() {
    _showMpesaConfirmationDialog();
  }

  void _showMpesaConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm M-Pesa Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking at: ${widget.spaceName}'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount:'),
                  Text(
                    'KSh ${widget.amount.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'You will receive an M-Pesa prompt on your phone. Enter your PIN to complete the payment.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onPaymentInitiated();
                _showPaymentProcessingDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0DB42D),
              ),
              child: const Text(
                'Proceed',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing your payment...'),
              SizedBox(height: 8),
              Text(
                'Check your phone for the M-Pesa prompt',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MpesaPaymentCard extends StatelessWidget {
  final double amount;
  final String bookingDetails;
  final VoidCallback onPayNow;
  final bool isPaid;

  const MpesaPaymentCard({
    super.key,
    required this.amount,
    required this.bookingDetails,
    required this.onPayNow,
    this.isPaid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaid
              ? [Colors.grey[300]!, Colors.grey[400]!]
              : [const Color(0xFF0DB42D), const Color(0xFF0A8C1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isPaid
                ? Colors.grey.withValues(alpha: 0.3)
                : const Color(0xFF0DB42D).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'M-Pesa Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isPaid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'PAID',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bookingDetails,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'KSh ${amount.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    color: Color(0xFF0DB42D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
