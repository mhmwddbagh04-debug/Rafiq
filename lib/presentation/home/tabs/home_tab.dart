import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/api/profile_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/data/models/user_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/product_card.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/app_router.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<UserModel> _profileFuture;
  late Future<HomeResponse> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getProfile();
    _homeDataFuture = HomeService().getHomeData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _profileFuture = ProfileService().getProfile();
      _homeDataFuture = HomeService().getHomeData();
    });
    await Future.wait([_profileFuture, _homeDataFuture]);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
    var local = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: provider.isDarkMode
            ? AppColors.backgroundDark
            : theme.scaffoldBackgroundColor,
      ),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<HomeResponse>(
          future: _homeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            } else if (snapshot.hasError) {
              return ErrorStateWidget(
                errorMessage: snapshot.error.toString(),
                onRetry: _refreshData,
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text("لا توجد بيانات"));
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
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
                  if (data.advertisements.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 155, autoPlay: true, enlargeCenterPage: true, aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn, enableInfiniteScroll: true, viewportFraction: 0.85,
                      ),
                      items: data.advertisements.map((ad) => _buildImageWidget("https://rafiq1.runasp.net/Advertisement_images/${ad.imageUrl}")).toList(),
                    ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        _buildSecHeader(
                          theme: theme, title: local.bestSellingDrugs, local: local,
                          onPressed: () => Navigator.pushNamed(context, AppRouter.allProducts, arguments: {'title': local.bestSellingDrugs, 'products': data.topSellingProducts}),
                        ),
                        const SizedBox(height: 14),
                        _buildProductsList(theme, provider, data.topSellingProducts),
                        const SizedBox(height: 20),
                        _buildSecHeader(
                          theme: theme, title: local.newArrivals, local: local,
                          onPressed: () => Navigator.pushNamed(context, AppRouter.allProducts, arguments: {'title': local.newArrivals, 'products': data.newArrivals}),
                        ),
                        const SizedBox(height: 14),
                        _buildProductsList(theme, provider, data.newArrivals),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageWidget(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: CachedNetworkImage(
        imageUrl: url, fit: BoxFit.cover, width: 1000,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
      ),
    );
  }

  Widget _buildSayHi(ThemeData theme, SettingsProvider provider, AppLocalizations local) {
    return FutureBuilder<UserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi ${user?.fullName ?? "!"}", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(local.findMedicalNeeds, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        );
      },
    );
  }

  Widget _buildSecHeader({required ThemeData theme, required String title, required AppLocalizations local, required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        TextButton(onPressed: onPressed, child: Text(local.viewAll)),
      ],
    );
  }

  Widget _buildProductsList(ThemeData theme, SettingsProvider provider, List<Product> products) {
    if (products.isEmpty) return const SizedBox(height: 100, child: Center(child: Text("No products available")));
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => ProductCard(
          product: products[index],
          heroPrefix: 'home',
          width: 155,
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: products.length,
      ),
    );
  }
}
