import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/providers/booking_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/tab_provider.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_state_widget.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    final isLoggedIn = userId.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.login,
                size: 64,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              const Text('Sign in to see your bookings'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/phone-login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final upcomingAsync = ref.watch(upcomingBookingsProvider(userId));
    final pastAsync = ref.watch(pastBookingsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          upcomingAsync.when(
            data: (upcoming) => pastAsync.when(
              data: (past) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _buildBookingSummary(
                  textTheme,
                  upcoming.length,
                  past.length,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                upcomingAsync.when(
                  data: (upcoming) =>
                      _buildBookingsList(upcoming, isUpcoming: true),
                  loading: () => const ListShimmer(),
                  error: (e, _) =>
                      ErrorStateWidget(title: 'Error', message: e.toString()),
                ),
                pastAsync.when(
                  data: (past) => _buildBookingsList(past, isUpcoming: false),
                  loading: () => const ListShimmer(),
                  error: (e, _) =>
                      ErrorStateWidget(title: 'Error', message: e.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(
    List<BookingModel> bookings, {
    required bool isUpcoming,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUpcoming ? Icons.event_available : Icons.history,
                  size: 56,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  isUpcoming ? 'No upcoming bookings' : 'No past bookings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isUpcoming
                      ? 'Explore spaces and lock in your next session.'
                      : 'Your past bookings will show here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.read(tabIndexProvider.notifier).state = 0;
                  },
                  child: const Text('Browse Spaces'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, isUpcoming: isUpcoming);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, {required bool isUpcoming}) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: const Center(child: Icon(Icons.image, size: 40)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.spaceName,
                        style: textTheme.titleLarge,
                      ),
                    ),
                    _buildStatusBadge(booking.bookingStatus.name),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  booking.spaceAddress,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoBlock(
                      label: 'Date',
                      value: TimeUtils.formatDate(booking.startTime),
                    ),
                    _buildInfoBlock(
                      label: 'Time',
                      value: TimeUtils.formatTimeRange(
                        booking.startTime,
                        booking.endTime,
                      ),
                    ),
                    _buildInfoBlock(
                      label: 'Total',
                      value: CurrencyFormatter.formatKes(booking.totalAmount),
                    ),
                  ],
                ),
                if (isUpcoming && booking.canCheckIn) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/space/${booking.spaceId}');
                      },
                      child: const Text('Check In'),
                    ),
                  ),
                ],
                if (!isUpcoming && !booking.isRated) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/space/${booking.spaceId}');
                          },
                          child: const Text('Leave Review'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/space/${booking.spaceId}');
                          },
                          child: const Text('Rebook'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(
    TextTheme textTheme,
    int upcomingCount,
    int pastCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text('$upcomingCount sessions', style: textTheme.titleMedium),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.surfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'History',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text('$pastCount visits', style: textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'upcoming':
        color = AppColors.primary;
        break;
      case 'active':
        color = AppColors.success;
        break;
      case 'completed':
        color = AppColors.onSurfaceVariant;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
