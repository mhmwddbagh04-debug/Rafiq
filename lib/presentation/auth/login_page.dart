import 'package:Rafiq/core/api/auth_service.dart';
import 'package:Rafiq/core/api/token_manager.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:Rafiq/widgets/auth_screen_wrapper.dart';
import 'package:Rafiq/widgets/custom_snackbar.dart';
import 'package:Rafiq/widgets/social_auth_section.dart';
import 'package:dio/dio.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;

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

    return AuthScreenWrapper(
      title: local.loginTitle,
      child: Column(
        children: [
          Text(
            local.welcomeBack,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.primaryBlue : AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            local.loginSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.secTextDark : AppColors.secTextLight,
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
                  validator: (value) => DataValidator.emailValidator(value ?? "", local),
                ),
                CustomTextField(
                  cont: passwordController,
                  hint: local.password,
                  isPassword: true,
                  icon: Icons.lock_outline,
                  validator: (value) => DataValidator.passwordValidator(value ?? "", local),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/otp'),
                child: Text(
                  local.forgotPassword,
                  style: const TextStyle(
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
            isLoading: _isLoading,
            onPressed: () => _handleLogin(context, local),
          ),
          const SizedBox(height: 24),
          
          SocialAuthSection(label: local.orSignUpWith),
          
          const SizedBox(height: 22),
          _buildRegisterRow(context, local, isDark),
        ],
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, AppLocalizations local) async {
    if (!formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (context.mounted) {
        CustomSnackBar.show(context, message: result['message'] ?? local.loginSuccess);
        final token = await TokenManager.getToken();
        final refreshToken = await TokenManager.getRefreshToken();
        if (token != null && TokenManager.isTokenExpired(token)) {
          if (refreshToken != null) {
            try {
              final newTokens = await AuthService().refreshToken({
                "accessToken": token,
                "refreshToken": refreshToken,
              });
              await TokenManager.saveToken(newTokens['accessToken']);
              await TokenManager.saveRefreshToken(newTokens['refreshToken']);
            } catch (err) {
              CustomSnackBar.show(context, message: "Session expired, please login again", isError: true);
              setState(() => _isLoading = false);
              return;
            }
          }
        }
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on DioException catch (e) {
      String errorMessage = "Login failed";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['description'] ?? e.response?.data['message'] ?? errorMessage;
      }
      if (context.mounted) CustomSnackBar.show(context, message: errorMessage, isError: true);
    } catch (e) {
      if (context.mounted) CustomSnackBar.show(context, message: "An error occurred", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRegisterRow(BuildContext context, AppLocalizations local, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(local.noAccount, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: Text(local.register, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
