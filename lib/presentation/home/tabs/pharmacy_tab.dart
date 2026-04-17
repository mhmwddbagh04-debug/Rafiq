import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/product_card.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PharmacyTab extends StatefulWidget {
  const PharmacyTab({super.key});

  @override
  State<PharmacyTab> createState() => _PharmacyTabState();
}

class _PharmacyTabState extends State<PharmacyTab> {
  late Future<List<Product>> _productsFuture;
  late Future<HomeResponse> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = HomeService().getAllProducts();
    _homeDataFuture = HomeService().getHomeData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _productsFuture = HomeService().getAllProducts();
      _homeDataFuture = HomeService().getHomeData();
    });
    await Future.wait([_productsFuture, _homeDataFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> categories = [
      {'name': 'Medicine', 'image': 'assets/image/medicin.png', 'color': const Color(0xFFE3F2FD)},
      {'name': 'Hair care', 'image': 'assets/image/haircare.png', 'color': const Color(0xFFF3E5F5)},
      {'name': 'Skin care', 'image': 'assets/image/skincare.png', 'color': const Color(0xFFE8F5E9)},
      {'name': 'Makeup', 'image': 'assets/image/makeup.png', 'color': const Color(0xFFFFF3E0)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: provider.isDarkMode ? AppColors.backgroundDark : theme.scaffoldBackgroundColor,
      ),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<HomeResponse>(
                future: _homeDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.advertisements.isNotEmpty) {
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 155, autoPlay: true, enlargeCenterPage: true, aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn, enableInfiniteScroll: true, viewportFraction: 0.85,
                      ),
                      items: snapshot.data!.advertisements.map((ad) => 
                        _buildImageWidget("https://rafiq1.runasp.net/Advertisement_images/${ad.imageUrl}")
                      ).toList(),
                    );
                  }
                  return const SizedBox(height: 155, child: Center(child: CircularProgressIndicator()));
                },
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.categories,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCircularCategories(context, categories, provider),
                    const SizedBox(height: 35),
                    _buildSecHeader(theme, local.products, local),
                    const SizedBox(height: 14),
                    
                    FutureBuilder<List<Product>>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ));
                        } else if (snapshot.hasError) {
                          return ErrorStateWidget(
                            errorMessage: snapshot.error.toString(),
                            onRetry: _refreshData,
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemBuilder: (context, index) => ProductCard(
                            product: snapshot.data![index],
                            heroPrefix: 'pharmacy',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildSecHeader(ThemeData theme, String title, AppLocalizations local) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        TextButton(onPressed: () {}, child: Text(local.viewAll, style: TextStyle(color: theme.colorScheme.secondary))),
      ],
    );
  }

  Widget _buildCircularCategories(BuildContext context, List<Map<String, dynamic>> categories, SettingsProvider provider) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) => InkWell(
          onTap: () => Navigator.pushNamed(context, AppRouter.allProducts, arguments: {'title': categories[index]['name']!, 'products': <Product>[]}),
          child: Column(
            children: [
              Container(
                width: 75, height: 75,
                decoration: BoxDecoration(
                  color: provider.isDarkMode ? categories[index]['color'].withValues(alpha: 0.1) : categories[index]['color'],
                  shape: BoxShape.circle,
                ),
                child: Center(child: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset(categories[index]['image']!, fit: BoxFit.contain))),
              ),
              const SizedBox(height: 8),
              Text(categories[index]['name']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: provider.isDarkMode ? Colors.white70 : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
