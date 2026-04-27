import 'dart:async';
import 'dart:convert';
import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/core/app_router.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/search_product_card.dart';
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
    _debounce = Timer(const Duration(milliseconds: 600), () {
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
    if (q.trim().isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final results = await HomeService().searchProducts(q);
      setState(() {
        _filtered = results;
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
      backgroundColor: provider.isDarkMode ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _buildHeader(isAr, provider),
              const SizedBox(height: 20),
              _buildSearchBar(provider, local, isAr),
              const SizedBox(height: 15),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildMainContent(isAr, provider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr, SettingsProvider provider) {
    return Text(
      isAr ? "ابحث عن دواءك" : "Find Your Medicine",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: provider.isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildSearchBar(SettingsProvider provider, AppLocalizations local, bool isAr) {
    return Container(
      decoration: BoxDecoration(
        color: provider.isDarkMode ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: _onSearchChanged,
        style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: local.search,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                  onPressed: () {
                    _ctrl.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isAr, SettingsProvider provider) {
    if (_ctrl.text.isEmpty && !_isSearching && _filtered.isEmpty) {
      return _buildHistory(isAr, provider);
    }
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }
    return _buildResults(isAr, provider);
  }

  Widget _buildHistory(bool isAr, SettingsProvider provider) {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded, size: 60, color: Colors.grey.withOpacity(0.3)),
            ),
            const SizedBox(height: 15),
            Text(
              isAr ? "لا يوجد سجل بحث" : "No recent searches",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? "عمليات البحث الأخيرة" : "Recent Searches",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                setState(() => _history.clear());
                SharedPreferences.getInstance().then((p) => p.remove('search_history_v3'));
              },
              child: Text(
                isAr ? "مسح" : "Clear",
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final product = _history[i];
              return InkWell(
                onTap: () => _handleTap(product),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: provider.isDarkMode ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: provider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.medication, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults(bool isAr, SettingsProvider provider) {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 15),
            Text(
              isAr ? "لم نجد نتائج مطابقة" : "No results found",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isAr ? "نتائج البحث" : "Search Results",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 16),
              ),
              const Spacer(),
              Text(
                "${_filtered.length} ${isAr ? "نتيجة" : "results"}",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _filtered.length,
            itemBuilder: (context, i) => SearchProductCard(
              product: _filtered[i],
              heroPrefix: 'search',
              onTap: () => _handleTap(_filtered[i]),
            ),
          ),
        ),
      ],
    );
  }
}
