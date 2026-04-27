import 'package:Rafiq/core/api/profile_service.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:Rafiq/data/models/user_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/custom_button.dart';
import 'package:Rafiq/widgets/custom_text_field.dart';
import 'package:Rafiq/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      UserModel user = await ProfileService().getProfile();
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final local = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      // تم التعديل: الدالة الآن ترمي استثناء في حال الفشل يحتوي على التفاصيل
      await ProfileService().updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.profileUpdated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // عرض رسالة الخطأ القادمة من السيرفر مباشرة
        String errorMessage = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.isEmpty ? local.updateFailed : errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.editProfile),
        centerTitle: true,
      ),
      body: _isFetching ? _buildSkeletonLoading() : _buildContent(local),
    );
  }

  Widget _buildContent(AppLocalizations local) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 35),
            CustomTextField(
              cont: _firstNameController,
              hint: local.firstName,
              icon: Icons.person_outline,
              validator: (value) => DataValidator.nameValidator(value ?? "", local),
            ),
            CustomTextField(
              cont: _lastNameController,
              hint: local.lastName,
              icon: Icons.person_outline,
              validator: (value) => DataValidator.nameValidator(value ?? "", local),
            ),
            CustomTextField(
              cont: _emailController,
              hint: local.email,
              icon: Icons.email_outlined,
              validator: (value) => DataValidator.emailValidator(value ?? "", local),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: local.saveChanges,
              isLoading: _isLoading,
              onPressed: _updateProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
