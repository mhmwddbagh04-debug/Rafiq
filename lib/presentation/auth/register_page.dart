import 'package:Rafiq/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:Rafiq/core/api_service.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
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

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;

    // نفس الألوان المستخدمة في صفحة اللوجن
    Color mainTextColor = isDark ? AppColors.mainTextDark : AppColors.mainTextLight;
    Color secondaryTextColor = isDark ? AppColors.secTextDark : AppColors.secTextLight;
    List<Color> currentGradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;
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
                  local.registerTitle,
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
                  padding: const EdgeInsets.fromLTRB(24, 35, 24, 30),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          cont: firstNameController,
                          hint: local.firstName,
                          icon: Icons.person_outline,
                          validator: (value) =>
                              DataValidator.nameValidator(value ?? "", local),
                        ),
                        CustomTextField(
                          cont: lastNameController,
                          hint: local.lastName,
                          icon: Icons.person_outline,
                          validator: (value) =>
                              DataValidator.nameValidator(value ?? "", local),
                        ),
                        CustomTextField(
                          cont: emailController,
                          hint: local.email,
                          icon: Icons.email_outlined,
                          validator: (value) =>
                              DataValidator.emailValidator(value ?? "", local),
                        ),
                        CustomTextField(
                          cont: passwordController,
                          hint: local.password,
                          isPassword: true,
                          icon: Icons.lock_outline,
                          validator: (value) =>
                              DataValidator.passwordValidator(value ?? "", local),
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
                        const SizedBox(height: 10),
                        CustomButton(
                          text: local.signUp,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                final result = await ApiService.register(
                                  firstNameController.text.trim(),
                                  lastNameController.text.trim(),
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'] ?? local.registerSuccess)),
                                );

                                Navigator.pushNamed(context, AppRouter.login);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(local.haveAccount, style: TextStyle(color: secondaryTextColor)),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: Text(
                                local.login,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
