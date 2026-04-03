import 'package:Rafiq/core/api_service.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            physics: BouncingScrollPhysics(),
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
                              final result = await ApiService.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              // عرض رسالة نجاح من السيرفر أو رسالة ثابتة
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ?? local.loginSuccess,
                                  ),
                                ),
                              );

                              Navigator.pushNamed(
                                context,
                                '/home',
                              ); // نجاح الدخول
                            } catch (e) {
                              // عرض رسالة الخطأ القادمة من السيرفر
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 24),
                      buildSocialDivider(local),
                      const SizedBox(height: 22),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          socialButton(
                            "Google",
                            Icons.g_mobiledata,
                            Colors.black,
                          ),
                          socialButton("Facebook", Icons.facebook, Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 22),
                      buildRegisterRow(context, local),
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

  Widget buildSocialDivider(AppLocalizations local) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(local.orSignUpWith, style: const TextStyle(fontSize: 14)),
        ),
        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
      ],
    );
  }

  Widget buildRegisterRow(BuildContext context, AppLocalizations local) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(local.noAccount),
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

  Widget socialButton(String text, IconData icon, Color color) {
    return Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
