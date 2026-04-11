class ApiConstants {
  ApiConstants._();

  // Base URLs
  // For emulator: use localhost with adb reverse tcp:3000 tcp:3000
  // For real device: use your computer's local IP (e.g., 192.168.0.200)
  static const String baseUrl = 'http://localhost:3000';
  static const String wsUrl = 'ws://localhost:3000';

  // OpenRouter AI - NVIDIA Nemotron Nano 12B VL (free)
  static const String openRouterUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterApiKey =
      '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';
  static const String gemmaModel = 'nvidia/nemotron-nano-12b-v2-vl:free';

  // Auth Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String enable2fa = '/api/auth/enable-2fa';
  static const String verify2fa = '/api/auth/verify-2fa';
  static const String disable2fa = '/api/auth/disable-2fa';
  static const String me = '/api/auth/me';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String loginGoogle = '/api/auth/login/google';
  static const String loginApple = '/api/auth/login/apple';

  // AI Endpoints
  static const String analyzePrescription = '/api/ai/analyze-prescription';
  static const String identifyPill = '/api/ai/identify-pill';
  static const String aiInsights = '/api/ai/insights';
  static const String analyzeSymptoms = '/api/ai/analyze-symptoms';

  // Medication Endpoints
  static const String medications = '/api/medications';
  static const String scanPrescription = '/api/ai/analyze-prescription';

  // Dose Log Endpoints
  static const String doseLogs = '/api/dose-logs';
  static const String todayLogs = '/api/dose-logs/today';
  static const String logHistory = '/api/dose-logs/history';

  // Profile Endpoints
  static const String profiles = '/api/profiles';

  // Analytics Endpoints
  static const String adherence = '/api/analytics/adherence';
  static const String streak = '/api/analytics/streak';
  static const String bodyImpact = '/api/analytics/body-impact';
  static const String aiCoach = '/api/analytics/ai-coach';

  // Notification Endpoints
  static const String notifications = '/api/notifications';
}

class AppConstants {
  AppConstants._();

  static const String appName = 'MedTrack AI';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';
  static const String pinKey = 'user_pin';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const int shortAnimation = 200;
  static const int mediumAnimation = 300;
  static const int longAnimation = 500;
}
