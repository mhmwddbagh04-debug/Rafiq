import 'package:Rafiq/core/api/profile_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/user_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = ProfileService().getProfile();
    });
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    final List<String> imgList = [
      'assets/image/right.png',
      'assets/image/left.png',
      'assets/image/ailan.jpg',
      'assets/image/ailan2.jpg',
      'assets/image/cursal1.jpg',
      'assets/image/cursal2.webp',
    ];

    return Container(
      decoration: BoxDecoration(
        color: provider.isDarkMode
            ? AppColors.backgroundDark
            : theme.scaffoldBackgroundColor,
      ),
      child: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _buildSayHi(theme, provider, local),
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  height: 155,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.85,
                ),
                items: imgList
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          child: Image.asset(
                            item,
                            fit: BoxFit.cover,
                            width: 1000,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    _buildSecHeader(theme, local.bestSellingDrugs, local),
                    const SizedBox(height: 14),
                    _buildDrugsList(theme, provider),
                    const SizedBox(height: 20),
                    _buildSecHeader(theme, local.newArrivals, local),
                    const SizedBox(height: 14),
                    _buildDrugsList(theme, provider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSayHi(
      ThemeData theme, SettingsProvider provider, AppLocalizations local) {
    return FutureBuilder<UserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        } else if (snapshot.hasError) {
          return ErrorStateWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: _refreshProfile,
          );
        } else if (!snapshot.hasData) {
          return const Text("لا توجد بيانات مستخدم");
        } else {
          final user = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi ${user.fullName}",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                local.findMedicalNeeds,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSecHeader(ThemeData theme, String title, AppLocalizations local) {
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

  Widget _buildDrugsList(ThemeData theme, SettingsProvider provider) {
    final drugs = [
      {
        'name': 'Panadol Advance',
        'tabs': '24 Tab',
        'price': '60 EGP',
        'image': 'assets/image/pandol.png',
      },
      {
        'name': 'Panadol Extra',
        'tabs': '191 Tab',
        'price': '240 EGP',
        'image': 'assets/image/product2.png',
      },
      {
        'name': 'Limitless women',
        'tabs': '38 Tab',
        'price': '40 EGP',
        'image': 'assets/image/panadol2.png',
      },
      {
        'name': 'Panadol Advance',
        'tabs': '24 Tab',
        'price': '60 EGP',
        'image': 'assets/image/pandol.png',
      },
    ];
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _buildDrugsCard(theme, provider, drugs[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: drugs.length,
      ),
    );
  }

  Widget _buildDrugsCard(
      ThemeData theme, SettingsProvider provider, Map<String, String> drug) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 130,
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
