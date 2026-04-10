import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class PharmacyTab extends StatelessWidget {
  const PharmacyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final List<String> categories = [
      local.painRelievers,
      local.antiInflammatory,
      local.antibiotics,
      local.gastrointestinal,
      local.respiratory,
      local.heartAndPressure,
      local.diabetes,
      local.nervousAndSleep,
      local.supplements,
      local.babyProducts,
      local.personalCare,
      local.medicalSupplies,
      local.cosmetics,
    ];

    final List<String> bannerImages = [
      'assets/image/ailan.jpg',
      'assets/image/ailan2.jpg',
    ];

    return Container(
      decoration: BoxDecoration(
        color: provider.isDarkMode
            ? AppColors.backgroundDark
            : theme.scaffoldBackgroundColor,
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 155,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
              ),
              items: bannerImages.map((i) => _buildBanner(i)).toList(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  _buildSecHeader(theme, local.categories, local),
                  const SizedBox(height: 10),
                  _buildCategoriesList(categories, provider),
                  const SizedBox(height: 20),
                  _buildSecHeader(theme, local.products, local),
                  const SizedBox(height: 14),
                  _buildProductsGrid(theme, provider, local),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(String imagePath) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(imagePath, fit: BoxFit.cover, width: 1000),
      ),
    );
  }

  Widget _buildSecHeader(
    ThemeData theme,
    String title,
    AppLocalizations local,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            local.viewAll,
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(
    List<String> categories,
    SettingsProvider provider,
  ) {
    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) => Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  categories[index].split(' ')[0],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 70,
              child: Text(
                categories[index],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: provider.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(
    ThemeData theme,
    SettingsProvider provider,
    AppLocalizations local,
  ) {
    final drugs = [
      {
        'name': 'Panadol Advance',
        'tabs': '24 ${local.tab}',
        'price': '60 ${local.egp}',
        'image': 'assets/image/pandol.png',
      },
      {
        'name': 'Panadol Extra',
        'tabs': '191 ${local.tab}',
        'price': '240 ${local.egp}',
        'image': 'assets/image/product2.png',
      },
      {
        'name': 'Limitless women',
        'tabs': '38 ${local.tab}',
        'price': '40 ${local.egp}',
        'image': 'assets/image/panadol2.png',
      },
      {
        'name': 'Panadol Advance',
        'tabs': '24 ${local.tab}',
        'price': '60 ${local.egp}',
        'image': 'assets/image/pandol.png',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: drugs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) =>
          _buildProductCard(theme, provider, drugs[index]),
    );
  }

  Widget _buildProductCard(
    ThemeData theme,
    SettingsProvider provider,
    Map<String, String> drug,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: provider.isDarkMode ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(drug['image']!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            drug['name']!,
            maxLines: 1,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
              color: provider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            drug['tabs']!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: provider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  drug['price']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: provider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.favorite_border,
                size: 18,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Icon(
                Iconsax.card_add_outline,
                size: 18,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
