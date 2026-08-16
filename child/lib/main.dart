import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'screens/home/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';
import 'services/reminder_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'family/deep_link_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DateFormat dengan locale 'id_ID' dipakai lintas layar.
  await initializeDateFormatting('id_ID');

  final reminders = ReminderService.instance;
  await reminders.init();

  // Firebase: aman walau google-services.json belum terpasang.
  await FirebaseService.instance.init();

  // Inisialisasi handler deep link & family reminders
  DeepLinkHandler.instance.init();

  // Cold start dari notifikasi azan -> putar azan.
  try {
    final launch = await reminders.launchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final p = launch?.notificationResponse?.payload;
      if (p != null) {
        final data = jsonDecode(p) as Map<String, dynamic>;
        if (data['kind'] == 'azan') await reminders.azan.play();
      }
    }
  } catch (_) {}

  runApp(const IbadahKuApp());
}

class IbadahKuApp extends StatelessWidget {
  const IbadahKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final themeMode = state.loaded ? state.settings.theme : ThemeMode.system;

    return MaterialApp(
      title: 'IbadahKu',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: !state.loaded
          ? const SplashScreen()
          : state.user == null
              ? const LoginScreen()
              : state.onboardingDone
                  ? const HomeShell()
                  : const OnboardingFlow(),
    );
  }
}
