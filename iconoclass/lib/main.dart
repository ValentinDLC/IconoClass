// Application entry point with theme configuration, routing, and provider setup
// This file initializes the Flutter app, sets up global theme, and configures the navigation structure
// It also wraps the app with necessary providers for state management

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/app_data_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred device orientations (portrait only for better mobile experience)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local storage service
  await StorageService.init();

  runApp(const IconoClassApp());
}

class IconoClassApp extends StatelessWidget {
  const IconoClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication provider for managing user login state
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // App data provider for managing application data (sessions, instructors, etc.)
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],
      child: MaterialApp(
        title: 'IconoClass',
        debugShowCheckedModeBanner: false,

        // App theme configuration with custom colors and typography
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          useMaterial3: true,

          // Custom text theme using Google Fonts
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),

          // Card theme
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.purple, width: 2),
            ),
          ),

          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Initial route based on authentication status
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Show login screen if not authenticated, otherwise show main screen
            return auth.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
