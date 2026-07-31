import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/views/home_screen.dart';
import '../../features/home/views/main_shell.dart';
import '../../features/prayer_times/views/prayer_times_screen.dart';
import '../../features/news/views/news_screen.dart';
import '../../features/news/views/news_detail_screen.dart';
import '../../features/events/views/events_screen.dart';
import '../../features/events/views/event_detail_screen.dart';
import '../../features/about/views/about_screen.dart';
import '../../features/about/views/about_islam_screen.dart';
import '../../features/calendar/views/calendar_screen.dart';
import '../../features/contact/views/contact_screen.dart';
import '../../features/donation/views/donation_screen.dart';
import '../../features/membership/views/membership_screen.dart';
import '../../features/wedding/views/wedding_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../shared/widgets/webview_screen.dart';

/// Navigation Routes
class AppRoutes {
  static const String home = '/';
  static const String prayerTimes = '/prayer-times';
  static const String news = '/news';
  static const String newsDetail = '/news/:id';
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  static const String about = '/about';
  static const String aboutIslam = '/about-islam';
  static const String calendar = '/calendar';
  static const String contact = '/contact';
  static const String donation = '/donation';
  static const String membership = '/membership';
  static const String wedding = '/wedding';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String webview = '/webview';
}

/// Navigation Service
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.prayerTimes,
            name: 'prayerTimes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerTimesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.news,
            name: 'news',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NewsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.events,
            name: 'events',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EventsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Detail pages (outside shell)
      GoRoute(
        path: AppRoutes.newsDetail,
        name: 'newsDetail',
        builder: (context, state) => NewsDetailScreen(
          newsId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.eventDetail,
        name: 'eventDetail',
        builder: (context, state) => EventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),

      // Other screens
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.aboutIslam,
        name: 'aboutIslam',
        builder: (context, state) => const AboutIslamScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.contact,
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.donation,
        name: 'donation',
        builder: (context, state) => const DonationScreen(),
      ),
      GoRoute(
        path: AppRoutes.membership,
        name: 'membership',
        builder: (context, state) => const MembershipScreen(),
      ),
      GoRoute(
        path: AppRoutes.wedding,
        name: 'wedding',
        builder: (context, state) => const WeddingScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.webview,
        name: 'webview',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? 'https://www.comunidadeislamica.pt';
          final title = state.uri.queryParameters['title'] ?? '';
          return WebViewScreen(url: url, title: title);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
}
