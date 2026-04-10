import 'package:Rafiq/core/api/profile_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/data/models/user_model.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:icons_plus/icons_plus.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          FutureBuilder<UserModel>(
            future: ProfileService().getProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const LoadingWidget(),
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text(
                    "خطأ في جلب البيانات",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Text("لا توجد بيانات مستخدم"),
                );
              } else {
                final user = snapshot.data!;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 70,
                    bottom: 30,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.gradientDark),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Iconsax.user_outline,
                          size: 45,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : "مستخدم",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email.isNotEmpty ? user.email : "no-email@example.com",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 20),

          // أزرار اللغة والثيم
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Iconsax.language_square_outline,
                  title: provider.isArabic ? 'English' : 'اللغة العربية',
                  trailing: Switch(
                    value: provider.isArabic,
                    onChanged: (value) {
                      provider.changeLanguage(value ? 'ar' : 'en');
                    },
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: provider.isDarkMode
                      ? Iconsax.moon_outline
                      : Iconsax.sun_1_outline,
                  title: provider.isArabic ? 'الوضع الليلي' : 'Dark Mode',
                  trailing: Switch(
                    value: provider.isDarkMode,
                    onChanged: (value) {
                      provider.changeTheme(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // زر تسجيل الخروج
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListTile(
              onTap: () async {
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.login,
                        (route) => false,
                  );
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
              ),
              leading: const Icon(Iconsax.logout_outline, color: Colors.red),
              title: Text(
                provider.isArabic ? 'تسجيل الخروج' : 'Logout',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget trailing,
      }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing,
      ),
    );
  }
}
