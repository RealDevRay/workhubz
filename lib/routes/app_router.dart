import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/providers/tab_provider.dart';
import '../presentation/screens/auth/phone_login_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/discover/location_onboarding_screen.dart';
import '../presentation/screens/discover/discover_screen.dart';
import '../presentation/screens/map_explore/map_explore_screen.dart';
import '../presentation/screens/space_detail/space_detail_screen.dart';
import '../presentation/screens/bookings/bookings_screen.dart';
import '../presentation/screens/bookings/booking_payment_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/saved_spaces_screen.dart';
import '../presentation/screens/profile/payment_history_screen.dart';
import '../presentation/widgets/bottom_nav.dart';
import '../presentation/widgets/connectivity_banner.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Enhancement: basic auth guard for protected routes (bookings, saved, etc.)
    // Uses current Supabase session (sync check). Does not break public browsing.
    final user = Supabase.instance.client.auth.currentUser;
    final protectedPaths = ['/booking', '/saved-spaces', '/payment-history'];
    final isProtected = protectedPaths.any((p) => state.uri.path.startsWith(p));
    if (isProtected && user == null) {
      final redirect = Uri.encodeComponent(state.uri.toString());
      return '/phone-login?redirect=$redirect';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          SplashScreen(onComplete: () => context.go('/onboarding-location')),
    ),
    GoRoute(
      path: '/onboarding-location',
      builder: (context, state) => const LocationOnboardingScreen(),
    ),
    GoRoute(
      path: '/phone-login',
      builder: (context, state) {
        final redirectTo = state.uri.queryParameters['redirect'];
        return PhoneLoginScreen(redirectTo: redirectTo);
      },
    ),
    GoRoute(
      path: '/discover',
      builder: (context, state) {
        final neighborhood = state.uri.queryParameters['neighborhood'];
        return DiscoverScreen(initialNeighborhood: neighborhood);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(
        initialNeighborhood: state.uri.queryParameters['neighborhood'],
      ),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/space/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return SpaceDetailScreen(spaceId: id);
      },
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) => const BookingsScreen(),
    ),
    GoRoute(
      path: '/booking-payment/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BookingPaymentScreen(spaceId: id);
      },
    ),
    GoRoute(
      path: '/saved-spaces',
      builder: (context, state) => const SavedSpacesScreen(),
    ),
    GoRoute(
      path: '/payment-history',
      builder: (context, state) => const PaymentHistoryScreen(),
    ),
  ],
);

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialNeighborhood;

  const HomeScreen({super.key, this.initialNeighborhood});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final List<Widget> _screens = [
    DiscoverScreen(initialNeighborhood: widget.initialNeighborhood),
    const MapExploreScreen(),
    const SearchScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);

    return ConnectivityBanner(
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: WorkHubzBottomNav(
          currentIndex: currentIndex,
          onIndexChanged: (i) => ref.read(tabIndexProvider.notifier).state = i,
        ),
      ),
    );
  }
}
