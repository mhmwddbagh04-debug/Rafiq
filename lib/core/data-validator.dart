import 'package:Rafiq/l10n/app_localizations.dart' hide AppLocalizations;

import '../l10n/app_localizations.dart';

abstract class DataValidator {
  // التحقق من الاسم

  static String? nameValidator(String name, AppLocalizations localization) {
    if (name.isEmpty) {
      return localization.nameRequired;
    }
    final RegExp nameExp = RegExp(r'^[a-zA-Z ]+$');
    if (!nameExp.hasMatch(name)) {
      return localization.nameInvalid;
    }
    return null;
  }

  // التحقق من البريد الإلكتروني
  static String? emailValidator(String email, AppLocalizations localization) {
    if (email.isEmpty) {
      return localization.emailRequired;
    }
    final RegExp emailExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailExp.hasMatch(email)) {
      return localization.emailInvalid;
    }
    return null;
  }

  // التحقق من كلمة المرور
  static String? passwordValidator(String password, AppLocalizations localization) {
    if (password.isEmpty) {
      return localization.passwordRequired;
    }
    final RegExp passwordExp =
    RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    if (!passwordExp.hasMatch(password)) {
      return localization.passwordWeak;
    }
    return null;
  }

  // التحقق من تأكيد كلمة المرور
  static String? confirmPasswordValidator(
      String password, String confirmPassword, AppLocalizations localization) {
    if (confirmPassword.isEmpty) {
      return localization.passwordRequired;
    }
    if (password != confirmPassword) {
      return localization.passwordMismatch;
    }
    return null;
  }
}
