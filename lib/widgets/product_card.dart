import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/cart_provider.dart';
import 'package:Rafiq/core/favorite_provider.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String heroPrefix;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.heroPrefix = 'product',
    this.width,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<SettingsProvider>(context);
    final local = AppLocalizations.of(context)!;

    return Consumer2<FavoriteProvider, CartProvider>(
      builder: (context, favProvider, cartProvider, child) {
        bool isFavorite = favProvider.isFavorite(widget.product.id);

        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRouter.item, arguments: widget.product);
          },
          child: Container(
            width: widget.width,
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Hero(
                            tag: '${widget.heroPrefix}-${widget.product.id}',
                            child: _buildProductImage(provider.isDarkMode),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 4),
                      Text(local.pharmacy, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${widget.product.price.toStringAsFixed(2)} ${local.egp}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: _isAdding ? null : () async {
                              setState(() => _isAdding = true);
                              await cartProvider.addItem(widget.product);
                              if (mounted) {
                                setState(() => _isAdding = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${widget.product.name} ${local.addedToCart}")),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isAdding 
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Iconsax.shopping_cart_outline, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => favProvider.toggleFavorite(widget.product),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: provider.isDarkMode ? Colors.black26 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(bool isDarkMode) {
    String rawImageUrl = widget.product.imageUrl.trim();
    
    // طباعة رابط الصورة الحالي لنتأكد ماذا يصلنا من السيرفر في صفحة الأقسام
    print("📸 [DEBUG] Product: ${widget.product.name}, ImagePath: '$rawImageUrl'");

    if (rawImageUrl.isEmpty || rawImageUrl == "null") {
      return const Icon(Icons.medication, size: 50, color: Colors.grey);
    }

    String imgUrl = rawImageUrl;
    if (!imgUrl.startsWith("http")) {
      imgUrl = "https://rafiq1.runasp.net/Images/$imgUrl";
    }

    return CachedNetworkImage(
      imageUrl: imgUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(color: Colors.white, width: double.infinity, height: double.infinity),
      ),
      errorWidget: (context, url, error) {
         print("❌ [DEBUG] Image Load Failed: $url");
         return const Icon(Icons.medication, size: 50, color: Colors.grey);
      },
    );
  }
}
