import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/space_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/booking_providers.dart';
import '../../../data/providers/space_providers.dart';
import '../../../services/mpesa_service.dart';

final mpesaServiceProvider = Provider<MpesaService>((ref) => MpesaService());

class BookingPaymentScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const BookingPaymentScreen({super.key, required this.spaceId});

  @override
  ConsumerState<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> {
  final _phoneController = TextEditingController(text: '+254');
  int _hours = 1;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaceAsync = ref.watch(spaceByIdProvider(widget.spaceId));
    final user = ref.watch(currentUserProvider);
    final textTheme = Theme.of(context).textTheme;

    return spaceAsync.when(
      data: (space) {
        if (space == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking')),
            body: const Center(child: Text('Space not found')),
          );
        }
        return _buildScreen(context, space, user, textTheme);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildScreen(BuildContext context, SpaceModel space, dynamic user, TextTheme textTheme) {
    final totalAmount = space.pricing.calculateTotal(_hours);

    return Scaffold(
      appBar: AppBar(title: const Text('Reserve & Pay')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(space.name, style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(space.neighborhood, style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${space.hours.openHour}:00 - ${space.hours.closeHour}:00', style: textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Select Duration', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [1, 2, 3, 4, 6, 8].map((h) {
                final selected = _hours == h;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('$h hr${h > 1 ? 's' : ''}'),
                    selected: selected,
                    onSelected: (_) => setState(() => _hours = h),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment Details', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildPriceRow(textTheme, 'Rate', '${CurrencyFormatter.formatKes(space.pricing.hourlyRate)}/hr'),
                _buildPriceRow(textTheme, 'Duration', '$_hours hour${_hours > 1 ? 's' : ''}'),
                const Divider(),
                _buildPriceRow(textTheme, 'Total', CurrencyFormatter.formatKes(totalAmount), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('M-Pesa Phone Number', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+2547XXXXXXXX',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.phone_android),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _handlePayment(space, totalAmount, user),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0DB42D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.payment),
              label: Text(
                _isProcessing ? 'Processing...' : 'Pay ${CurrencyFormatter.formatKes(totalAmount)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(TextTheme textTheme, String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Future<void> _handlePayment(SpaceModel space, double totalAmount, dynamic user) async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'Enter a valid M-Pesa phone number');
      return;
    }
    if (user == null) {
      setState(() => _errorMessage = 'Please sign in first');
      return;
    }

    setState(() { _isProcessing = true; _errorMessage = null; });

    try {
      final bookingId = const Uuid().v4();
      final now = DateTime.now();
      final endTime = now.add(Duration(hours: _hours));

      final booking = BookingModel(
        id: bookingId,
        userId: user.id,
        spaceId: widget.spaceId,
        spaceName: space.name,
        spaceAddress: space.address,
        startTime: now,
        endTime: endTime,
        totalAmount: totalAmount,
        paymentStatus: PaymentStatus.pending,
        bookingStatus: BookingStatus.pending,
        durationHours: _hours,
      );

      await ref.read(bookingRepositoryProvider).createBooking(booking);

      final mpesa = ref.read(mpesaServiceProvider);
      final result = await mpesa.initiateStkPush(
        phoneNumber: phone,
        amount: totalAmount,
        accountReference: bookingId.substring(0, 12),
        transactionDescription: 'WorkHubz: ${space.name}',
      );

      if (!result.success) {
        setState(() {
          _isProcessing = false;
          _errorMessage = result.errorMessage ?? 'Payment initiation failed';
        });
        return;
      }

      for (var i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 3));
        final status = await mpesa.queryPaymentStatus(result.checkoutRequestId!);
        if (status.success) {
          final receipt = status.checkoutRequestId ?? result.checkoutRequestId;
          await ref.read(bookingRepositoryProvider).updatePaymentStatus(
            bookingId, PaymentStatus.paid,
            mpesaReceiptNumber: receipt,
          );
          await ref.read(bookingRepositoryProvider).updateBookingStatus(
            bookingId, BookingStatus.upcoming,
          );
          if (mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment successful! Booking confirmed.')),
            );
            // ignore: use_build_context_synchronously
            context.pop();
          }
          return;
        }
      }

      setState(() {
        _isProcessing = false;
        _errorMessage = 'Payment timed out. Check M-Pesa messages for confirmation.';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: $e';
      });
    }
  }
}
