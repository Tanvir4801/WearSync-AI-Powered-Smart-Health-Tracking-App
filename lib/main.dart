import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/notifications/notification_service.dart';

// TODO: RELEASE - Remove all debugPrint statements (run: grep -r "debugPrint" lib/)
// TODO: RELEASE - Set flutter run --release to test performance
// TODO: RELEASE - Add android/app/google-services.json for production Firebase project
// TODO: RELEASE - Set minSdkVersion 21 in build.gradle
// TODO: RELEASE - Add ProGuard rules for Firebase + Hugging Face
// TODO: RELEASE - Test on physical device for pedometer accuracy
// TODO: RELEASE - Add Privacy Policy URL (required for Play Store - health data)
// TODO: RELEASE - Add ACTIVITY_RECOGNITION permission rationale in AndroidManifest
// TODO: RELEASE - Test demo mode toggle on/off cycle completely
// TODO: RELEASE - Set applicationId to your real package name
// TODO: RELEASE - Generate release keystore and sign APK

Future<void> _initializeFirebaseSafely() async {
  try {
    // Firebase might auto-initialize on Android/iOS
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Firebase already initialized, ignore
    debugPrint('Firebase initialization attempted but already initialized: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables. If .env is missing, the app will continue
  // and services should handle missing keys gracefully. Use .env.example
  // as a template for required values.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('No .env file found: $e');
  }

  await _initializeFirebaseSafely();
  await initializeRouter();

  final NotificationService notifications = NotificationService();
  try {
    await notifications.initialize();
  } catch (error, stackTrace) {
    debugPrint('Notification initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const ProviderScope(child: SmartwearAiApp()));
}

class SmartwearAiApp extends StatelessWidget {
  const SmartwearAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smartwear AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.background,
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF8FAFC),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF8FAFC),
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
            headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
            headlineSmall: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
            titleLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
            titleMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF8FAFC),
            ),
            titleSmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFFF8FAFC),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFF8FAFC),
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppTheme.card,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primaryAccent.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6366F1),
                );
              }
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              );
            },
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Color(0xFF6366F1),
                  size: 24,
                );
              }
              return const IconThemeData(
                color: Color(0xFF64748B),
                size: 24,
              );
            },
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryAccent,
              width: 2,
            ),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: router,
    );
  }
}
