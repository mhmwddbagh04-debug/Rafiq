import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/cart_provider.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/presentation/home/tabs/home_tab.dart';
import 'package:Rafiq/presentation/home/tabs/Favorite_tab.dart';
import 'package:Rafiq/presentation/home/tabs/pharmacy_tab.dart';
import 'package:Rafiq/presentation/home/tabs/search_tab.dart';
import 'package:Rafiq/widgets/custom_drawer.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
    const HomeTab(),
    const SearchTab(),
    const FavoriteTab(),
    const PharmacyTab(),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: provider.isDarkMode
          ? AppColors.backgroundDark
          : theme.scaffoldBackgroundColor,
      // نغلف الـ AppBar بـ Directionality LTR ليبقى ثابتاً دائماً
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Iconsax.menu_outline),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            elevation: 0,
            backgroundColor: provider.isDarkMode
                ? AppColors.backgroundDark
                : const Color(0xFFDCF8FC),
            centerTitle: false,
            title: Image.asset(
              !provider.isDarkMode
                  ? 'assets/image/rafiq2.png'
                  : 'assets/image/Copilot_20260417_184551.png',
              width: 70,
              height: 40,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => provider.changeTheme(
                  provider.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  provider.changeLanguage(provider.isArabic ? 'en' : 'ar');
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Badge(
                      label: Text('${cart.itemCount}'),
                      isLabelVisible: cart.itemCount > 0,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.cart);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
      body: _pages[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.ai);
        },
        backgroundColor: provider.isDarkMode
            ? Colors.blue
            : const Color(0xff173E90),
        child: const Icon(Icons.wechat_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: const CustomDrawer(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 70,
        items: [
          Icon(
            Iconsax.home_1_outline,
            color: provider.isDarkMode ? Colors.white : Colors.indigo,
            size: 30,
          ),
          Icon(
            Icons.search,
            color: provider.isDarkMode ? Colors.white : Colors.indigo,
            size: 30,
          ),
          Icon(
            Icons.favorite_border,
            color: provider.isDarkMode ? Colors.white : Colors.indigo,
            size: 30,
          ),
          Icon(
            Icons.local_pharmacy_outlined,
            color: provider.isDarkMode ? Colors.white : Colors.indigo,
            size: 30,
          ),
        ],
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 600),
        index: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        color: provider.isDarkMode
            ? const Color(0xff173E90)
            : const Color(0xFFDCF8FC),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: provider.isDarkMode
            ? const Color(0xff173E90)
            : const Color(0xFFDCF8FC),
        letIndexChange: (index) => true,
      ),
    );
  }
}
