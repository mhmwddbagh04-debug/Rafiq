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
  late Future<PaginatedProductResponse> _productsFuture;
  late Future<HomeResponse> _homeDataFuture;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _productsFuture = HomeService().getAllProducts(page: 1, pageSize: 8);
    _homeDataFuture = HomeService().getHomeData();
    _categoriesFuture = HomeService().getCategories();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
    await Future.wait([_productsFuture, _homeDataFuture, _categoriesFuture]);
  }

  Map<String, dynamic> _getCategoryStyle(String name) {
    name = name.toLowerCase();
    if (name.contains('medicine') || name.contains('دواء')) {
      return {'img': 'assets/image/medicin.png', 'color': const Color(0xFFE3F2FD)};
    } else if (name.contains('hair') || name.contains('شعر')) {
      return {'img': 'assets/image/haircare.png', 'color': const Color(0xFFF3E5F5)};
    } else if (name.contains('skin') || name.contains('بشرة')) {
      return {'img': 'assets/image/skincare.png', 'color': const Color(0xFFE8F5E9)};
    } else if (name.contains('makeup') || name.contains('مكياج')) {
      return {'img': 'assets/image/makeup.png', 'color': const Color(0xFFFFF3E0)};
    } else {
      return {'img': 'assets/image/medicin.png', 'color': Colors.grey[100]};
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                        _buildImageWidget(ad.imageUrl)
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
                    Text(local.categories, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 20),
                    FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));
                        }
                        if (snapshot.hasData) return _buildCircularCategories(context, snapshot.data!, provider);
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 35),
                    _buildSecHeader(theme, local.products, local),
                    const SizedBox(height: 14),
                    
                    FutureBuilder<PaginatedProductResponse>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()));
                        } else if (snapshot.hasError) {
                          return ErrorStateWidget(errorMessage: snapshot.error.toString(), onRetry: _refreshData);
                        } else if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        final products = snapshot.data!.products;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemBuilder: (context, index) => ProductCard(
                            product: products[index],
                            heroPrefix: 'pharmacy',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
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
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.allProducts, arguments: {'title': title, 'categoryId': null});
          },
          child: Text(local.viewAll, style: TextStyle(color: theme.colorScheme.secondary)),
        ),
      ],
    );
  }

  Widget _buildCircularCategories(BuildContext context, List<Category> categories, SettingsProvider provider) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final category = categories[index];
          final style = _getCategoryStyle(category.name);
          return InkWell(
            onTap: () {
               // نرسل الـ ID والاسم والافتراض أن الصفحة التالية ستجلب المنتجات بصورها
               Navigator.pushNamed(context, AppRouter.allProducts, arguments: {
                 'title': category.name, 
                 'categoryId': category.id
               });
            },
            child: Column(
              children: [
                Container(
                  width: 75, height: 75,
                  decoration: BoxDecoration(
                    color: provider.isDarkMode ? (style['color'] as Color).withValues(alpha: 0.1) : style['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(style['img'], fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: provider.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
