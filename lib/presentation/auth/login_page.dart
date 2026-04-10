import 'package:Rafiq/core/api/auth_service.dart';
import 'package:Rafiq/core/api/token_manager.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;

    Color mainTextColor = isDark
        ? AppColors.mainTextDark
        : AppColors.mainTextLight;
    Color secondaryTextColor = isDark
        ? AppColors.secTextDark
        : AppColors.secTextLight;
    List<Color> currentGradient = isDark
        ? AppColors.gradientDark
        : AppColors.gradientLight;
    Color cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: currentGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/image/logo.png'),
                const SizedBox(height: 8),
                Text(
                  local.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: mainTextColor,
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(
                    "assets/image/doctors.png",
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 35, 24, 35),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        local.welcomeBack,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.primaryBlue
                              : AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        local.loginSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              cont: emailController,
                              hint: local.email,
                              icon: Icons.email_outlined,
                              validator: (value) =>
                                  DataValidator.emailValidator(
                                    value ?? "",
                                    local,
                                  ),
                            ),
                            CustomTextField(
                              cont: passwordController,
                              hint: local.password,
                              isPassword: true,
                              icon: Icons.lock_outline,
                              validator: (value) =>
                                  DataValidator.passwordValidator(
                                    value ?? "",
                                    local,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/otp'),
                            child: Text(
                              local.forgotPassword,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: local.login,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              final result = await AuthService().login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primaryBlue,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Text(
                                      result['message'] ?? local.loginSuccess,
                                    ),
                                  ),
                                );

                                // ✅ تحقق من صلاحية التوكن
                                final token = await TokenManager.getToken();
                                final refreshToken =
                                    await TokenManager.getRefreshToken();

                                if (token != null && token.isNotEmpty) {
                                  final expired = TokenManager.isTokenExpired(
                                    token,
                                  );
                                  if (expired) {
                                    print("❌ Token expired, refreshing...");
                                    if (refreshToken != null &&
                                        refreshToken.isNotEmpty) {
                                      try {
                                        final newTokens =
                                            await AuthService().refreshToken(
                                              {
                                                "accessToken": token,
                                                "refreshToken": refreshToken,
                                              },
                                            );
                                        await TokenManager.saveToken(
                                          newTokens['accessToken'],
                                        );
                                        await TokenManager.saveRefreshToken(
                                          newTokens['refreshToken'],
                                        );
                                        print("✅ Token refreshed successfully");
                                      } catch (err) {
                                        print("❌ Refresh failed: $err");
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "انتهت صلاحية الجلسة، برجاء تسجيل الدخول مرة أخرى",
                                            ),
                                          ),
                                        );
                                        return; // وقف هنا وما تروحش للـ Home
                                      }
                                    } else {
                                      print("❌ No refresh token found");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "انتهت صلاحية الجلسة، برجاء تسجيل الدخول مرة أخرى",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                  } else {
                                    print("✅ Token is still valid");
                                  }
                                }

                                // ✅ بعد التأكد من التوكن أو تحديثه
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              print("Login error: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Login failed: $e")),
                                );
                              }
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 24),
                      buildSocialDivider(local, isDark),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          socialButton(
                            "Google",
                            Iconsax.google_1_bold,
                            Colors.black,
                            isDark,
                          ),
                          socialButton(
                            "Facebook",
                            Icons.facebook,
                            Colors.blue,
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      buildRegisterRow(context, local, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSocialDivider(AppLocalizations local, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            local.orSignUpWith,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.secTextDark : AppColors.secTextLight,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget buildRegisterRow(
    BuildContext context,
    AppLocalizations local,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          local.noAccount,
          style: TextStyle(
            color: isDark ? AppColors.mainTextDark : AppColors.mainTextLight,
          ),
        ),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: Text(
            local.register,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget socialButton(String text, IconData icon, Color color, bool isDark) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.mainTextDark : AppColors.mainTextLight,
            ),
          ),
        ],
      ),
    );
  }
}
