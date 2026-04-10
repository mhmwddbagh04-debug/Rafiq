import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/presentation/home/tabs/home_tab.dart';
import 'package:Rafiq/presentation/home/tabs/interaction_tab.dart';
import 'package:Rafiq/presentation/home/tabs/pharmacy_tab.dart';
import 'package:Rafiq/presentation/home/tabs/search_tab.dart';
import 'package:Rafiq/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    HomeTab(),
    SearchTab(),
    InteractionsTab(),
    PharmacyTab(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var local = AppLocalizations.of(context)!;
    var provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: provider.isDarkMode
          ? AppColors.backgroundDark
          : theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 2,
        backgroundColor: provider.isDarkMode
            ? AppColors.backgroundDark
            : Color(0xFFDCF8FC),

        title: Image.asset('assets/image/rafiq2.png', width: 80, height: 50),
        actions: [
          InkWell(
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: _pages[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: provider.isDarkMode ? Colors.blue : Color(0xff173E90),
        child: const Icon(Icons.wechat_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: CustomDrawer(),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(25, 10, 25, 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            elevation: 0,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            backgroundColor: provider.isDarkMode
                ? Color(0xff173E90)
                : Color(0xFFDCF8FC),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: provider.isDarkMode
                ? Colors.blue
                : Color(0xff173E90),
            unselectedItemColor: provider.isDarkMode
                ? Colors.white
                : Colors.black.withOpacity(0.6),
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
      ),
    );
  }
}
