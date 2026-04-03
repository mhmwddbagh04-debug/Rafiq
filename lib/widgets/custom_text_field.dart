import 'package:Rafiq/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController cont;
  final bool isPassword;
  final IconData? icon;
  final String? Function(String?)? validator; // ← أضفنا هنا

  const CustomTextField({
    super.key,
    required this.hint,
    required this.cont,
    this.isPassword = false,
    this.icon,
    this.validator, // ← أضفنا هنا
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: cont,
        obscureText: isPassword,
        validator: validator, // ← أضفنا هنا
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.secTextLight),
          filled: true,
          fillColor: const Color(0xffF4F6F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
