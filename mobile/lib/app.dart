import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/medication/screens/add_medication_screen.dart';
import '../features/scan/screens/scan_medication_screen.dart';
import '../features/dose/screens/log_dose_screen.dart';
import '../features/profile/screens/family_profiles_screen.dart';
import '../features/security/screens/security_settings_screen.dart';

class MedTrackApp extends StatelessWidget {
  MedTrackApp({super.key});

  final _router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/medication/add',
        builder: (context, state) => const AddMedicationScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanMedicationScreen(),
      ),
      GoRoute(
        path: '/dose/log',
        builder: (context, state) => const LogDoseScreen(),
      ),
      GoRoute(
        path: '/family-profiles',
        builder: (context, state) => const FamilyProfilesScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        title: 'MedTrack AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
