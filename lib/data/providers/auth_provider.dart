import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = Supabase.instance.client.auth;
  return auth.onAuthStateChange.map((event) => event.session?.user);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final signInWithGoogleProvider = FutureProvider.family<void, String?>((
  ref,
  redirectTo,
) async {
  await Supabase.instance.client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: redirectTo ?? 'io.supabase.flutter://callback',
  );
});

final signOutProvider = FutureProvider<void>((ref) async {
  await Supabase.instance.client.auth.signOut();
});
