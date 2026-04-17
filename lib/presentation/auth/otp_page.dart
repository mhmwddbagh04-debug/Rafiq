import 'package:Rafiq/core/api/auth_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/auth_screen_wrapper.dart';
import 'package:Rafiq/widgets/custom_snackbar.dart';
import 'package:Rafiq/widgets/custom_button.dart';
import 'package:Rafiq/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;

    return AuthScreenWrapper(
      title: "Together towards\nbetter care",
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
            local.pleaseEnterYourEmail,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.secTextDark : AppColors.secTextLight,
            ),
          ),
          const SizedBox(height: 22),

          // حقل إدخال الإيميل
          CustomTextField(
            cont: emailController,
            hint: local.email,
            icon: Icons.email_outlined,
            validator: (value) =>
                DataValidator.emailValidator(value ?? "", local),
          ),

          const SizedBox(height: 20),

          CustomButton(
            text: "Send OTP",
            isLoading: _isLoading,
            onPressed: () => _handleSendOtp(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendOtp(BuildContext context) async {
    if (emailController.text.isEmpty) {
      CustomSnackBar.show(
        context,
        message: "Please enter your email",
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().forgetPassword(emailController.text.trim());
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: "OTP sent to your email successfully",
        );
        Navigator.pushNamed(
          context,
          AppRouter.otpConfirm,
          arguments: emailController.text.trim(),
        );
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to send OTP";
      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['description'] ??
            e.response?.data['message'] ??
            errorMessage;
      }
      if (context.mounted) {
        CustomSnackBar.show(context, message: errorMessage, isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: "An error occurred",
          isError: true,
        );
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
