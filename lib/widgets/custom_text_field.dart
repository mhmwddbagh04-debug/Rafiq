import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController cont;
  final bool isPassword;
  final IconData? icon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.cont,
    this.isPassword = false,
    this.icon,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // نبدأ بوضعية الإخفاء إذا كان الحقل كلمة مرور
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(

        style: TextStyle(
          fontSize: 18,
          color: provider.isDarkMode ? AppColors.mainTextLight : AppColors.mainTextLight,
        ),
        controller: widget.cont,
        keyboardType: widget.isPassword ? TextInputType.visiblePassword : TextInputType.text,
        obscureText: _obscureText,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.grey) : null,
          
          // إضافة أيقونة العين في النهاية إذا كان الحقل كلمة مرور
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,

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
