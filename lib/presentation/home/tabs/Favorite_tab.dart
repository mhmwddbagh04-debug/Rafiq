import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/favorite_provider.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: provider.isDarkMode ? AppColors.backgroundDark : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(local.wishlist, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, child) {
          final favorites = favProvider.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.heart_outline, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 15),
                  Text(
                    local.wishlistEmpty,
                    style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(local.wishlistSubtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                // استخدام الـ ProductCard الموحد لضمان نفس التصميم في كل مكان
                return ProductCard(
                  product: favorites[index],
                  heroPrefix: 'fav',
                );
              },
            ),
          );
        },
      ),
    );
  }
}
