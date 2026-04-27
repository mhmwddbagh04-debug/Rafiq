import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';
import '../core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import '../widgets/custom_button.dart';

class ChooseLanguagePage extends StatelessWidget {
  const ChooseLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;
    Color mainTextColor = isDark ? AppColors.mainTextDark : AppColors.mainTextLight;
    Color secondaryTextColor = isDark ? AppColors.secTextDark : AppColors.secTextLight;
    List<Color> currentGradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: currentGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // إضافة التمرير هنا
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Image.asset('assets/image/logo.png', height: 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/image/themes.png'),
                  const SizedBox(height: 30),
                  Text(
                    local.personalizeTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    local.personalizeDesc,
                    style: TextStyle(
                      fontSize: 15,
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 35),

                  Column(
                    children: [
                      // Language Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            local.language,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.primaryBlue : AppColors.darkBlue,
                            ),
                          ),
                          Row(
                            children: [
                              _buildToggleButton(
                                text: local.english,
                                isSelected: !provider.isArabic,
                                onPressed: () => provider.changeLanguage('en'),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildToggleButton(
                                text: local.arabic,
                                isSelected: provider.isArabic,
                                onPressed: () => provider.changeLanguage('ar'),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            local.theme,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.primaryBlue : AppColors.darkBlue,
                            ),
                          ),
                          Row(
                            children: [
                              _buildToggleButton(
                                icon: Icons.light_mode,
                                isSelected: !isDark,
                                onPressed: () => provider.changeTheme(ThemeMode.light),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildToggleButton(
                                icon: Icons.dark_mode,
                                isSelected: isDark,
                                onPressed: () => provider.changeTheme(ThemeMode.dark),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 60), // تم استبدال Spacer بمسافة ثابتة ليعمل التمرير
                  CustomButton(
                    text: local.letsStart,
                    backgroundColor: AppColors.primaryBlue,
                    onPressed: () => Navigator.pushNamed(context, AppRouter.login),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    String? text,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isSelected
              ? AppColors.primaryBlue
              : (isDark ? AppColors.cardDark : Colors.white),
          foregroundColor: isSelected
              ? Colors.white
              : (isDark ? AppColors.primaryBlue : AppColors.darkBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: text != null ? Text(text) : Icon(icon),
      ),
    );
  }
}
