import 'package:Rafiq/core/api/auth_service.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/widgets/auth_screen_wrapper.dart';
import 'package:Rafiq/widgets/custom_snackbar.dart';
import 'package:Rafiq/widgets/custom_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OtpConfirmPage extends StatefulWidget {
  const OtpConfirmPage({super.key});

  @override
  State<OtpConfirmPage> createState() => _OtpConfirmPageState();
}

class _OtpConfirmPageState extends State<OtpConfirmPage> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return AuthScreenWrapper(
      title: "Together towards\nbetter care",
      child: Column(
        children: [
          const Text(
            "Verify OTP",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xff0D1B3E)),
          ),
          const SizedBox(height: 6),
          Text(
            "Enter the code sent to: $email",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 50,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xffF4F6F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) _focusNodes[index + 1].requestFocus();
                    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => _handleResendCode(context, email),
            child: const Text("Resend Code", style: TextStyle(color: Color(0xff6A8FB6), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Confirm OTP",
            isLoading: _isLoading,
            onPressed: () => _handleVerifyOtp(context, email),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResendCode(BuildContext context, String email) async {
    try {
      await AuthService().forgetPassword(email);
      if (context.mounted) CustomSnackBar.show(context, message: "A new code has been sent to your email");
    } catch (e) {
      if (context.mounted) CustomSnackBar.show(context, message: "Failed to resend code", isError: true);
    }
  }

  Future<void> _handleVerifyOtp(BuildContext context, String email) async {
    if (_otpCode.length < 4) return;
    setState(() => _isLoading = true);
    try {
      // استقبال الاستجابة في متغير
      final Map<String, dynamic> response = await AuthService().validateOTP(email, _otpCode);
      
      if (context.mounted) {
        CustomSnackBar.show(context, message: "OTP Verified Successfully");
        
        // تمرير الـ id القادم من السيرفر
        Navigator.pushNamed(
          context,
          AppRouter.reset,
          arguments: {
            'email': email,
            'userId': response['userId'] ?? response['id'] ?? "",
          },
        );
      }
    } on DioException catch (e) {
      String errorMessage = "Invalid OTP code";
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
}
