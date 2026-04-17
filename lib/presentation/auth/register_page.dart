import 'package:Rafiq/core/api/auth_service.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/widgets/auth_screen_wrapper.dart';
import 'package:Rafiq/widgets/custom_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:provider/provider.dart';
import '../../core/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:Rafiq/l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false; // متغير حالة التحميل

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;

    return AuthScreenWrapper(
      title: local.registerTitle,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            CustomTextField(
              cont: firstNameController,
              hint: local.firstName,
              icon: Icons.person_outline,
              validator: (value) => DataValidator.nameValidator(value ?? "", local),
            ),
            CustomTextField(
              cont: lastNameController,
              hint: local.lastName,
              icon: Icons.person_outline,
              validator: (value) => DataValidator.nameValidator(value ?? "", local),
            ),
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
            CustomTextField(
              cont: confirmPasswordController,
              hint: local.confirmPassword,
              isPassword: true,
              icon: Icons.lock_outline,
              validator: (value) => DataValidator.confirmPasswordValidator(
                passwordController.text,
                value ?? "",
                local,
              ),
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: local.signUp,
              isLoading: _isLoading, // ربط حالة التحميل بالزر
              onPressed: () => _handleRegister(context, local),
            ),
            const SizedBox(height: 18),
            _buildLoginRow(context, local, isDark),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister(BuildContext context, AppLocalizations local) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // بدء التحميل

    try {
      final result = await AuthService().register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (context.mounted) {
        CustomSnackBar.show(context, message: result['message'] ?? local.registerSuccess);
        Navigator.pushNamed(context, AppRouter.login);
      }
    } on DioException catch (e) {
      String errorMessage = "Registration failed";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['description'] ?? e.response?.data['message'] ?? errorMessage;
      }
      if (context.mounted) CustomSnackBar.show(context, message: errorMessage, isError: true);
    } catch (e) {
      if (context.mounted) CustomSnackBar.show(context, message: "An error occurred", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false); // إنهاء التحميل
    }
  }

  Widget _buildLoginRow(BuildContext context, AppLocalizations local, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          local.haveAccount,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            local.login,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
