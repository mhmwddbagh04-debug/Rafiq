import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/favorite_provider.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  int quantity = 1;
  Product? _fullProduct;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fullProduct == null) {
      final product = ModalRoute.of(context)!.settings.arguments as Product;
      _fullProduct = product;
      if (_fullProduct!.description == null || _fullProduct!.description!.isEmpty) {
        _fetchProductDetails();
      }
    }
  }

  Future<void> _fetchProductDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await HomeService().getAllProducts(page: 1, pageSize: 50);
      final matchingProduct = response.products.firstWhere(
        (p) => p.id == _fullProduct!.id,
        orElse: () => _fullProduct!,
      );
      
      if (mounted) {
        setState(() {
          _fullProduct = matchingProduct;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fullProduct == null) return const Scaffold(body: LoadingWidget());
    
    final local = AppLocalizations.of(context)!;
    var provider = Provider.of<SettingsProvider>(context);
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.primary),
        ),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favProvider, child) {
              bool isFavorite = favProvider.isFavorite(_fullProduct!.id);
              return IconButton(
                onPressed: () => favProvider.toggleFavorite(_fullProduct!),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : theme.colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: provider.isDarkMode ? AppColors.cardDark : const Color(0xFFDCF8FC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                child: Hero(
                  tag: 'product-${_fullProduct!.id}',
                  child: Image.network(
                    "https://rafiq1.runasp.net/Images/${_fullProduct!.imageUrl}",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.medication, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _fullProduct!.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "${_fullProduct!.price} ${local.egp}",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_fullProduct!.totalSold > 0)
                    Text(
                      "${local.sold}: ${_fullProduct!.totalSold}",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    local.description,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _isLoading 
                    ? const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(),
                      )
                    : Text(
                        _fullProduct!.description ?? "No description available",
                        style: const TextStyle(height: 1.5, fontSize: 15),
                      ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => setState(() => quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            local.addToCart,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
