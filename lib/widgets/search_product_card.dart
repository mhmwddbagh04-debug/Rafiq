import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/cart_provider.dart';
import 'package:Rafiq/core/favorite_provider.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class SearchProductCard extends StatefulWidget {
  final Product product;
  final String heroPrefix;
  final VoidCallback? onTap;

  const SearchProductCard({
    super.key,
    required this.product,
    this.heroPrefix = 'search_product',
    this.onTap,
  });

  @override
  State<SearchProductCard> createState() => _SearchProductCardState();
}

class _SearchProductCardState extends State<SearchProductCard> {
  bool _isAdding = false;
  bool _isLoadingSimilar = false;

  void _showSimilarProducts(BuildContext context, bool isAr) async {
    setState(() => _isLoadingSimilar = true);
    
    try {
      final similarProducts = await HomeService().getSimilarProducts(widget.product.id);
      
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  isAr ? "منتجات مشابهة" : "Similar Products",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: similarProducts.isEmpty 
                  ? Center(child: Text(isAr ? "لا توجد نتائج" : "No results found"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: similarProducts.length,
                      itemBuilder: (context, index) => ProductCard(product: similarProducts[index]),
                    ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "خطأ في تحميل البيانات" : "Error loading similar products")));
    } finally {
      if (mounted) setState(() => _isLoadingSimilar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<SettingsProvider>(context);
    final local = AppLocalizations.of(context)!;
    final isAr = local.noAccount.contains("حساب");

    return Consumer2<FavoriteProvider, CartProvider>(
      builder: (context, favProvider, cartProvider, child) {
        bool isFavorite = favProvider.isFavorite(widget.product.id);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: provider.isDarkMode ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(provider.isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.onTap ?? () => Navigator.pushNamed(context, AppRouter.item, arguments: widget.product),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: '${widget.heroPrefix}-${widget.product.id}',
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: provider.isDarkMode ? Colors.black26 : Colors.grey[50],
                          ),
                          child: _buildProductImage(provider.isDarkMode),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.product.name,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => favProvider.toggleFavorite(widget.product),
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.product.price.toStringAsFixed(2)} ${local.egp}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: theme.colorScheme.primary,
                                fontSize: 15
                              ),
                            ),
                            if (widget.product.description != null && widget.product.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  widget.product.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600], height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (widget.product.activeIngredients != null && widget.product.activeIngredients!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 0,
                    children: widget.product.activeIngredients!.split(',').take(4).map((ingredient) {
                      return Chip(
                        label: Text(ingredient.trim(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoadingSimilar ? null : () => _showSimilarProducts(context, isAr),
                        icon: _isLoadingSimilar 
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Iconsax.copy_outline, size: 16),
                        label: Text(isAr ? "بدائل" : "Similar", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAdding ? null : () {
                          setState(() => _isAdding = true);
                          cartProvider.addItem(widget.product).then((_) {
                            if (mounted) {
                              setState(() => _isAdding = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${widget.product.name} ${local.addedToCart}"), 
                                  duration: const Duration(milliseconds: 800),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          });
                        },
                        icon: _isAdding 
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Iconsax.shopping_cart_outline, size: 16),
                        label: Text(local.addToCart, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
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

  Widget _buildProductImage(bool isDarkMode) {
    String rawImageUrl = widget.product.imageUrl.trim();
    if (rawImageUrl.isEmpty || rawImageUrl == "null") {
      return const Icon(Icons.medication, size: 35, color: Colors.grey);
    }
    return CachedNetworkImage(
      imageUrl: rawImageUrl.startsWith("http") ? rawImageUrl : "https://rafiq1.runasp.net/Images/$rawImageUrl",
      fit: BoxFit.contain,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.medication, size: 35, color: Colors.grey),
    );
  }
}
