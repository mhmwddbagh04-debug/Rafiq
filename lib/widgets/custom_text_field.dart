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
  final Iterable<String>? autofillHints;
  final bool enabled;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.cont,
    this.isPassword = false,
    this.icon,
    this.validator,
    this.autofillHints,
    this.enabled = true,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        autofillHints: widget.autofillHints,
        enabled: widget.enabled,
        style: TextStyle(
          fontSize: 18,
          color: provider.isDarkMode ? Colors.white.withOpacity(0.9) : AppColors.mainTextLight,
        ),
        controller: widget.cont,
        keyboardType: widget.keyboardType ?? (widget.isPassword ? TextInputType.visiblePassword : TextInputType.text),
        obscureText: _obscureText,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.grey) : null,
          
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

          hintStyle: TextStyle(
            fontSize: 14, 
            color: provider.isDarkMode ? Colors.white54 : AppColors.secTextLight
          ),
          filled: true,
          fillColor: provider.isDarkMode 
              ? (widget.enabled ? const Color(0xff263350) : Colors.white10)
              : (widget.enabled ? const Color(0xffF4F6F9) : Colors.grey.withOpacity(0.1)),
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
