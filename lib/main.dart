import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_router.dart';
import 'core/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
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
