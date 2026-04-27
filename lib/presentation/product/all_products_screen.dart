import 'dart:async';
import 'package:Rafiq/core/api/home_service.dart';
import 'package:Rafiq/core/settings_provider.dart';
import 'package:Rafiq/data/models/home_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/product_card.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _products = [];
  String _searchQuery = "";
  bool _isSearchingFieldVisible = false;
  bool _isInitialized = false;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  String? _errorMessage;
  int? _categoryId;
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _categoryId = args['categoryId'];
      _fetchProducts();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // نطلب 500 منتج لضمان الوصول لكل المنتجات عند البحث
      int requestedPageSize = _searchQuery.isNotEmpty ? 500 : 8;

      final PaginatedProductResponse response = _categoryId != null
          ? await HomeService().getProductsByCategory(_categoryId!, page: _currentPage, pageSize: requestedPageSize, search: _searchQuery)
          : await HomeService().getAllProducts(page: _currentPage, pageSize: requestedPageSize, search: _searchQuery);

      print("📡 [AllProducts DEBUG] Received ${response.products.length} products for search: '$_searchQuery'");

      setState(() {
        if (_searchQuery.isNotEmpty) {
          _products = response.products.where((p) => 
            p.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        } else {
          _products = response.products;
        }
        
        _totalPages = response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String v) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = v;
        _currentPage = 1; 
      });
      _fetchProducts();
    });
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    setState(() {
      _currentPage = page;
    });
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String title = args['title'];
    final local = AppLocalizations.of(context)!;

    var provider = Provider.of<SettingsProvider>(context);
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchingFieldVisible
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: local.searchHint, border: InputBorder.none),
                style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black),
                onChanged: _onSearchChanged,
              )
            : Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.primary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchingFieldVisible = !_isSearchingFieldVisible;
                if (!_isSearchingFieldVisible && _searchQuery.isNotEmpty) {
                  _searchQuery = "";
                  _currentPage = 1;
                  _fetchProducts();
                }
              });
            },
            icon: Icon(_isSearchingFieldVisible ? Icons.close : Icons.search, color: theme.colorScheme.primary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorStateWidget(errorMessage: _errorMessage!, onRetry: _fetchProducts)
              : _buildContent(theme, provider.isDarkMode, local),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDarkMode, AppLocalizations local) {
    if (_products.isEmpty) {
      return Center(child: Text(local.noProductsFound));
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 15, mainAxisSpacing: 15,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) => ProductCard(product: _products[index], heroPrefix: 'all'),
            ),
          ),
        ),
        if (_searchQuery.isEmpty) _buildPagination(theme, isDarkMode, local),
      ],
    );
  }

  Widget _buildPagination(ThemeData theme, bool isDarkMode, AppLocalizations local) {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _navButton(label: local.previous, icon: Icons.arrow_back_ios, onTap: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null, isDarkMode: isDarkMode),
            const SizedBox(width: 10),
            ...List.generate(_totalPages, (index) {
              int pageNum = index + 1;
              bool isSelected = pageNum == _currentPage;
              return GestureDetector(
                onTap: () => _goToPage(pageNum),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: isSelected ? (isDarkMode ? Colors.white : Colors.black) : Colors.transparent, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: Text("$pageNum", style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? (isDarkMode ? Colors.white : Colors.black) : (isDarkMode ? Colors.white54 : Colors.black54))),
                ),
              );
            }),
            const SizedBox(width: 10),
            _navButton(label: local.next, icon: Icons.arrow_forward_ios, onTap: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null, isDarkMode: isDarkMode, isNext: true),
          ],
        ),
      ),
    );
  }

  Widget _navButton({required String label, required IconData icon, required VoidCallback? onTap, required bool isDarkMode, bool isNext = false}) {
    bool enabled = onTap != null;
    Color color = enabled ? (isDarkMode ? Colors.white : Colors.black) : (isDarkMode ? Colors.white24 : Colors.black26);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNext) Icon(icon, size: 14, color: color),
            if (!isNext) const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
            if (isNext) const SizedBox(width: 4),
            if (isNext) Icon(icon, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
