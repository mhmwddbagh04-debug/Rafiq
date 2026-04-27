import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/cart_provider.dart';
import 'package:Rafiq/core/favorite_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/api/dio_client.dart';
import 'core/app_router.dart';
import 'core/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
