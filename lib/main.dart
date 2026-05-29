import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/providers/theme_provider.dart';
import 'package:trendsoccer/core/router/app_router.dart';
import 'package:trendsoccer/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  FcmService.configureForegroundListeners();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  // v2.1.1: initSdk is native-only (MethodChannel); not exposed on FlutterNaverLogin class.
  await FlutterNaverLogin.channel.invokeMethod<void>(
    'initSdk',
    <String, String>{
      'clientId': '4vRIttCnY29H4SdYztZU',
      'clientSecret': 'MaqnBYPgKh',
      'clientName': 'TrendSoccer',
    },
  );
  // ignore: avoid_print
  print('[AUTH] Naver SDK initialized');
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TrendSoccerApp(),
    ),
  );
}

class TrendSoccerApp extends ConsumerStatefulWidget {
  const TrendSoccerApp({super.key});

  @override
  ConsumerState<TrendSoccerApp> createState() => _TrendSoccerAppState();
}

class _TrendSoccerAppState extends ConsumerState<TrendSoccerApp> {
  @override
  void initState() {
    super.initState();
    ref.read(authProvider).initFromStoredToken();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    ref.watch(authProvider);

    return MaterialApp.router(
      title: 'TrendSoccer',
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: Locale(language.name),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      routerConfig: AppRouter.router,
    );
  }
}
