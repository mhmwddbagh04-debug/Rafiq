import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode;

    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 25), // تم تقليل المارجن العلوي قليلاً
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: isDark ? const Color(0xff173E90) : const Color(0xFFDCF8FC),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isDark ? Colors.blue : const Color(0xff173E90),
          unselectedItemColor: isDark ? Colors.white : Colors.black.withOpacity(0.6),
          iconSize: 28,
          items: [
            BottomNavigationBarItem(
              activeIcon: const Icon(Iconsax.home_1_bold),
              icon: const Icon(Iconsax.home_1_outline),
              label: local.home,
            ),
            BottomNavigationBarItem(
              activeIcon: const Icon(Iconsax.search_normal_1_bold),
              icon: const Icon(Icons.search),
              label: local.search,
            ),
            BottomNavigationBarItem(
              activeIcon: const Icon(Icons.science),
              icon: const Icon(Icons.science_outlined),
              label: local.interactions,
            ),
            BottomNavigationBarItem(
              activeIcon: const Icon(Icons.local_pharmacy),
              icon: const Icon(Icons.local_pharmacy_outlined),
              label: local.pharmacy,
            ),
          ],
        ),
      ),
    );
  }
}
