import 'package:Rafiq/core/api/profile_service.dart';
import 'package:Rafiq/core/data-validator.dart';
import 'package:Rafiq/data/models/user_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/custom_button.dart';
import 'package:Rafiq/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  bool _isChangingPassword = false;
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
      _phoneController.text = user.phoneNumber ?? "";
      _addressController.text = user.address ?? "";
      _selectedGender = user.gender;
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
      await ProfileService().updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _selectedGender,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.profileUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final local = AppLocalizations.of(context)!;
    setState(() => _isChangingPassword = true);

    try {
      await ProfileService().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(local.passwordChanged),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.isEmpty ? local.passwordChangeFailed : errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
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
      body: _isFetching 
          ? const Center(child: CircularProgressIndicator()) 
          : _buildContent(local),
    );
  }

  Widget _buildContent(AppLocalizations local) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(local),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          _buildPasswordSection(local),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileSection(AppLocalizations local) {
    return Form(
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
            enabled: false, // البريد عادة لا يعدل من هنا في هذا الـ API
          ),
          CustomTextField(
            cont: _phoneController,
            hint: local.phone,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          CustomTextField(
            cont: _addressController,
            hint: local.address,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 10),
          _buildGenderDropdown(local),
          const SizedBox(height: 30),
          CustomButton(
            text: local.saveChanges,
            isLoading: _isLoading,
            onPressed: _updateProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown(AppLocalizations local) {
    // التأكد من أن القيمة المختارة موجودة ضمن القائمة لتجنب الخطأ
    final List<String> allowedGenders = ["Male", "Female"];
    final String? safeValue = allowedGenders.contains(_selectedGender) ? _selectedGender : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        hintText: local.gender,
        prefixIcon: const Icon(Icons.wc_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        DropdownMenuItem(value: "Male", child: Text(local.male)),
        DropdownMenuItem(value: "Female", child: Text(local.female)),
      ],
      onChanged: (val) => setState(() => _selectedGender = val),
      validator: (value) => value == null ? local.gender : null,
    );
  }

  Widget _buildPasswordSection(AppLocalizations local) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.changePassword,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            cont: _currentPasswordController,
            hint: local.currentPassword,
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) return local.passwordRequired;
              return null;
            },
          ),
          CustomTextField(
            cont: _newPasswordController,
            hint: local.newPassword,
            icon: Icons.lock_reset_outlined,
            isPassword: true,
            validator: (value) => DataValidator.passwordValidator(value ?? "", local),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: local.changePassword,
            isLoading: _isChangingPassword,
            onPressed: _changePassword,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
