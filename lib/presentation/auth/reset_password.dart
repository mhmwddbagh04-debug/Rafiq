import 'package:Rafiq/core/api/auth_service.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/widgets/auth_screen_wrapper.dart';
import 'package:Rafiq/widgets/custom_snackbar.dart';
import 'package:Rafiq/widgets/custom_button.dart';
import 'package:Rafiq/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استقبال الـ userId (الذي هو تطبيق الـ applicationUserId المطلوب)
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String userId = args['userId'] ?? "";

    return AuthScreenWrapper(
      title: "Together towards\nbetter care",
      child: Column(
        children: [
          const Text(
            "Reset Password",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xff0D1B3E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Please enter your new password",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 22),
          CustomTextField(
            cont: passwordController,
            hint: "New Password",
            isPassword: true,
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            cont: confirmPasswordController,
            hint: "Confirm New Password",
            isPassword: true,
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 25),
          CustomButton(
            text: "Reset Password",
            isLoading: _isLoading,
            onPressed: () => _handleResetPassword(context, userId),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword(BuildContext context, String userId) async {
    if (passwordController.text.isEmpty) {
      CustomSnackBar.show(context, message: "Please enter a password", isError: true);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackBar.show(context, message: "Passwords do not match", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إرسال البيانات بالمفاتيح المطلوبة من الباك اند
      await AuthService().resetPassword(
        applicationUserId: userId,
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (context.mounted) {
        CustomSnackBar.show(context, message: "Password reset successfully");
        Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to reset password";
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['description'] ?? e.response?.data['message'] ?? errorMessage;
      }
      if (context.mounted) {
        CustomSnackBar.show(context, message: errorMessage, isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context, message: "An error occurred", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
