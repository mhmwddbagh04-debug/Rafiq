import 'package:Rafiq/core/api/dio_client.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/core/cart_provider.dart';
import 'package:Rafiq/core/favorite_provider.dart';
import 'package:Rafiq/core/notification_service.dart';
import 'package:Rafiq/firebase_options.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try {
    Stripe.publishableKey = "pk_test_51TbiizPoxcPmk868QZRYxcCby5tNhoJ7ZmQvLhsUbvnPuC884jEiHTxTcAu5SKKr7AHvkJPFVhfgljCZ9n1W65Om00zrxmVPkB";
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Stripe Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      navigatorKey: DioClient.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Rafiq',
      locale: provider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      themeMode: provider.currentThemeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'RobotoSlab',
        scaffoldBackgroundColor:  Colors.grey[50],
        colorScheme: const ColorScheme.light(
          primary: AppColors.darkBlue,
          secondary: AppColors.primaryBlue,
          surface: AppColors.cardLight,
          onSurface: AppColors.mainTextLight,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'RobotoSlab',
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.darkBlue,
          surface: AppColors.cardDark,
          onSurface: AppColors.mainTextDark,
        ),
      ),

      initialRoute: AppRouter.splash,
      routes: AppRouter.getRoutes(),
    );
  }
}
