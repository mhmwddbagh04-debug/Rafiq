import 'package:Rafiq/core/api/profile_service.dart';
import 'package:Rafiq/core/api/token_manager.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/user_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var theme = Theme.of(context);
    var local = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: provider.isDarkMode
          ? AppColors.backgroundDark
          : Colors.white,
      child: Column(
        children: [
          _buildHeader(context, theme, provider),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.box_outline,
                  title: "My Orders",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.heart_outline,
                  title: "Wishlist",
                  onTap: () {},
                ),

                const Divider(indent: 20, endIndent: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Support & Info",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.info_circle_outline,
                  title: "About Us",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.call_outline,
                  title: "Contact Support",
                  onTap: () {},
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: InkWell(
              onTap: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await TokenManager.clearTokens();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.login,
                      (route) => false,
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.logout_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Logout",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    SettingsProvider provider,
  ) {
    List<Color> currentGradient = provider.isDarkMode
        ? AppColors.gradientDark
        : AppColors.gradientLight;

    return FutureBuilder<UserModel>(
      future: ProfileService().getProfile(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Container(
          padding: const EdgeInsets.only(
            top: 80,
            bottom: 40,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.topCenter,
              begin: Alignment.bottomCenter,
              colors: currentGradient,
            ),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? "Loading...",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: provider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      user?.email ?? "User Profile",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    var isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (isDark ? Colors.white70 : Colors.grey[700]),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
