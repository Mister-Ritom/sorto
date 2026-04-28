// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';

// Onboarding
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/hook_screen.dart';
import '../../features/onboarding/screens/role_screen.dart';
import '../../features/onboarding/screens/interest_screen.dart';
import '../../features/onboarding/screens/social_proof_screen.dart';
import '../../features/onboarding/screens/username_screen.dart';
import '../../features/onboarding/screens/notification_screen.dart';
import '../../features/onboarding/screens/wallet_intro_screen.dart';
import '../../features/onboarding/screens/launch_screen.dart';

// Feed
import '../../features/feed/screens/home_screen.dart';
import '../../features/feed/screens/search_screen.dart';

// Dares
import '../../features/dares/screens/dare_detail_screen.dart';
import '../../features/dares/screens/create_dare_screen.dart';
import '../../features/dares/screens/submit_proof_screen.dart';
import '../../features/dares/screens/proof_review_screen.dart';

// Performer Posts
import '../../features/performer_posts/screens/create_performer_post_screen.dart';
import '../../features/performer_posts/screens/performer_post_detail_screen.dart';

// Wallet
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/screens/withdrawal_screen.dart';

// Profile
import '../../features/profile/screens/own_profile_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';

// Notifications
import '../../features/notifications/screens/notifications_screen.dart';

// Settings
import '../../features/settings/screens/settings_screen.dart';

// Admin
import '../../features/admin/screens/contest_queue_screen.dart';

// ─── ROUTE NAMES ─────────────────────────────────────────────────────────────
class Routes {
  Routes._();

  static const splash = '/';
  static const hookOnboarding = '/onboarding/hook';
  static const roleOnboarding = '/onboarding/role';
  static const interestOnboarding = '/onboarding/interests';
  static const socialProofOnboarding = '/onboarding/social-proof';
  static const usernameOnboarding = '/onboarding/username';
  static const notificationOnboarding = '/onboarding/notifications';
  static const walletIntroOnboarding = '/onboarding/wallet-intro';
  static const launchOnboarding = '/onboarding/launch';

  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';

  static const home = '/home';
  static const search = '/search';

  // Deep-linkable: sorto.ritom.in/dare/:id
  static const dareDetail = '/dare/:dareId';
  static String dareDetailPath(String id) => '/dare/$id';

  static const createDare = '/dare/create';
  static const submitProof = '/dare/:dareId/submit-proof';
  static String submitProofPath(String id) => '/dare/$id/submit-proof';

  static const reviewProof = '/dare/:dareId/review/:submissionId';
  static String reviewProofPath(String dareId, String subId) =>
      '/dare/$dareId/review/$subId';

  // Deep-linkable: sorto.ritom.in/post/:id
  static const performerPostDetail = '/post/:postId';
  static String performerPostDetailPath(String id) => '/post/$id';
  static const createPerformerPost = '/post/create';

  static const wallet = '/wallet';
  static const withdrawal = '/wallet/withdraw';

  // Deep-linkable: sorto.ritom.in/profile/:username
  static const profileSelf = '/profile';
  static const profilePublic = '/profile/:username';
  static String profilePublicPath(String username) => '/profile/$username';

  static const notifications = '/notifications';
  static const settings = '/settings';
  static const adminContestQueue = '/admin/contests';

  static const privacyPolicy = '/legal/privacy';
  static const termsOfService = '/legal/terms';
}

// ─── ROUTER PROVIDER ─────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateListenableProvider);

  return GoRouter(
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    initialLocation: Routes.splash,

    // ─── DEEP LINK CONFIGURATION ─────────────────────────────────────────
    // Handles both:
    //   • Custom scheme:  sorto://dare/123
    //   • Universal link: https://sorto.ritom.in/dare/123
    // iOS:  add `Associated Domains` → `applinks:sorto.ritom.in`
    //       and `sorto` custom scheme in Info.plist
    // Android: add intent-filter in AndroidManifest.xml (see comments there)
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;
      final loc = state.uri.toString();

      // Splash always shows — it handles its own navigation
      if (loc == Routes.splash) return null;

      // If logged in and trying to access onboarding or auth → go home.
      // Onboarding completion is tracked in profile.onboarding_done;
      // the only path that sets it to true is the LaunchScreen, which
      // then calls context.go(Routes.home) directly.
      if (isLoggedIn &&
          (loc.startsWith('/onboarding') || loc.startsWith('/auth'))) {
        return Routes.home;
      }

      // Allow unauthenticated access to onboarding and auth screens
      if (loc.startsWith('/onboarding') || loc.startsWith('/auth')) return null;

      // All other routes require authentication
      if (!isLoggedIn) return Routes.signIn;
      return null;
    },

    routes: [
      // ─── SPLASH ────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (ctx, state) => const SplashScreen(),
      ),

      // ─── ONBOARDING ────────────────────────────────────────────────────
      GoRoute(
        path: Routes.hookOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const HookScreen()),
      ),
      GoRoute(
        path: Routes.roleOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const RoleScreen()),
      ),
      GoRoute(
        path: Routes.interestOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const InterestScreen()),
      ),
      GoRoute(
        path: Routes.socialProofOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const SocialProofScreen()),
      ),
      GoRoute(
        path: Routes.usernameOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const UsernameScreen()),
      ),
      GoRoute(
        path: Routes.notificationOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const NotificationScreen()),
      ),
      GoRoute(
        path: Routes.walletIntroOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const WalletIntroScreen()),
      ),
      GoRoute(
        path: Routes.launchOnboarding,
        pageBuilder: (ctx, state) => _slideUpPage(const LaunchScreen()),
      ),

      // ─── AUTH ──────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.signIn,
        pageBuilder: (ctx, state) => _fadePage(const SignInScreen()),
      ),
      GoRoute(
        path: Routes.signUp,
        pageBuilder: (ctx, state) => _slidePage(const SignUpScreen()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        pageBuilder: (ctx, state) => _slidePage(const ForgotPasswordScreen()),
      ),

      // ─── HOME / SEARCH ─────────────────────────────────────────────────
      GoRoute(
        path: Routes.home,
        pageBuilder: (ctx, state) => _fadePage(const HomeScreen()),
      ),
      GoRoute(
        path: Routes.search,
        pageBuilder: (ctx, state) => _slidePage(const SearchScreen()),
      ),

      // ─── DARES ─────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.createDare,
        pageBuilder: (ctx, state) => _slideUpPage(const CreateDareScreen()),
      ),
      GoRoute(
        path: '/dare/:dareId',
        pageBuilder: (ctx, state) {
          final dareId = state.pathParameters['dareId']!;
          return _slidePage(DareDetailScreen(dareId: dareId));
        },
        routes: [
          GoRoute(
            path: 'submit-proof',
            pageBuilder: (ctx, state) {
              final dareId = state.pathParameters['dareId']!;
              return _slideUpPage(SubmitProofScreen(dareId: dareId));
            },
          ),
          GoRoute(
            path: 'review/:submissionId',
            pageBuilder: (ctx, state) {
              final dareId = state.pathParameters['dareId']!;
              final submissionId = state.pathParameters['submissionId']!;
              return _slidePage(
                ProofReviewScreen(dareId: dareId, submissionId: submissionId),
              );
            },
          ),
        ],
      ),

      // ─── PERFORMER POSTS ───────────────────────────────────────────────
      GoRoute(
        path: Routes.createPerformerPost,
        pageBuilder: (ctx, state) =>
            _slideUpPage(const CreatePerformerPostScreen()),
      ),
      GoRoute(
        path: '/post/:postId',
        pageBuilder: (ctx, state) {
          final postId = state.pathParameters['postId']!;
          return _slidePage(PerformerPostDetailScreen(postId: postId));
        },
      ),

      // ─── WALLET ────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.wallet,
        pageBuilder: (ctx, state) => _slidePage(const WalletScreen()),
        routes: [
          GoRoute(
            path: 'withdraw',
            pageBuilder: (ctx, state) => _slideUpPage(const WithdrawalScreen()),
          ),
        ],
      ),

      // ─── PROFILE ───────────────────────────────────────────────────────
      GoRoute(
        path: Routes.profileSelf,
        pageBuilder: (ctx, state) => _slidePage(const OwnProfileScreen()),
      ),
      GoRoute(
        path: '/profile/:username',
        pageBuilder: (ctx, state) {
          final username = state.pathParameters['username']!;
          return _slidePage(PublicProfileScreen(username: username));
        },
      ),

      // ─── NOTIFICATIONS ─────────────────────────────────────────────────
      GoRoute(
        path: Routes.notifications,
        pageBuilder: (ctx, state) => _slidePage(const NotificationsScreen()),
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (ctx, state) => _slidePage(const SettingsScreen()),
      ),

      // ─── ADMIN ─────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.adminContestQueue,
        pageBuilder: (ctx, state) => _slidePage(const ContestQueueScreen()),
      ),
    ],

    // ─── ERROR PAGE ──────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─── PAGE TRANSITION BUILDERS ─────────────────────────────────────────────────
CustomTransitionPage<void> _slidePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage<void> _slideUpPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ─── AUTH STATE LISTENABLE (for GoRouter.refreshListenable) ──────────────────
class AuthStateListenable extends ChangeNotifier {
  AuthStateListenable(this._client) {
    _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  final SupabaseClient _client;
}

final authStateListenableProvider = Provider<AuthStateListenable>((ref) {
  return AuthStateListenable(Supabase.instance.client);
});
