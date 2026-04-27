import 'dart:async';
import 'dart:convert';
import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _ctrl = TextEditingController();
  List<Product> _filtered = [], _history = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('search_history_v3') ?? [];
    setState(() {
      _history = list.map((e) => Product.fromJson(jsonDecode(e))).toList();
    });
  }

  void _onSearchChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (q.isNotEmpty) {
        _performSearch(q);
      } else {
        setState(() {
          _filtered = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String q) async {
    setState(() => _isSearching = true);
    try {
      final response = await HomeService().getAllProducts(
        page: 1,
        pageSize: 500,
        search: q,
      );

      setState(() {
        _filtered = response.products
            .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
            .toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _handleTap(Product p) async {
    setState(() {
      _history.removeWhere((x) => x.id == p.id);
      _history.insert(0, p);
      if (_history.length > 10) _history.removeLast();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'search_history_v3',
      _history.map((e) => jsonEncode(e.toJson())).toList(),
    );
    if (mounted) Navigator.pushNamed(context, AppRouter.item, arguments: p);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final local = AppLocalizations.of(context)!;
    final isAr = local.noAccount.contains("حساب");

    return Scaffold(
      backgroundColor: provider.isDarkMode
          ? AppColors.backgroundDark
          : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(provider, local),
              const SizedBox(height: 20),
              Expanded(
                child: _ctrl.text.isEmpty
                    ? _buildHistory(isAr, provider)
                    : _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _buildResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(SettingsProvider provider, AppLocalizations local) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: provider.isDarkMode ? AppColors.cardDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: _onSearchChanged,
        style: TextStyle(
          color: provider.isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: local.search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _ctrl.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildHistory(bool isAr, SettingsProvider provider) {
    if (_history.isEmpty)
      return Center(
        child: Text(
          isAr ? "ابدأ البحث عن منتجاتك" : "Start searching for products",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? "آخر عمليات البحث" : "Recent Searches",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                setState(() => _history.clear());
                SharedPreferences.getInstance().then(
                  (p) => p.remove('search_history_v3'),
                );
              },
              child: Text(
                isAr ? "مسح الكل" : "Clear",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _history.length,
            itemBuilder: (context, i) {
              final product = _history[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: provider.isDarkMode
                        ? Colors.white10
                        : Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl.startsWith("http") 
                          ? product.imageUrl 
                          : "https://rafiq1.runasp.net/Images/${product.imageUrl}",
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.history, size: 20),
                    ),
                  ),
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: provider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: const Icon(
                  Icons.north_west,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () => _handleTap(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_filtered.isEmpty) {
      return const Center(
        child: Icon(Icons.search_off, size: 50, color: Colors.grey),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => ProductCard(
        product: _filtered[i], 
        heroPrefix: 'search',
        onTap: () => _handleTap(_filtered[i]), // استدعاء دالة الحفظ عند الضغط
      ),
    );
  }
}
