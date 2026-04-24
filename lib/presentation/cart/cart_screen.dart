import 'package:Rafiq/core/api/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/cart_provider.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.cart),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmDialog(context, cart, local),
            ),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? _buildEmptyCart(context, local)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          final item = cart.items.values.toList()[i];
                          return _buildCartItem(item, cart, isDark);
                        },
                      ),
                    ),
                    _buildTotalSection(context, cart, local, isDark),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations local) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(local.cartEmpty, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.shopNow),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item, CartProvider cart, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "https://rafiq1.runasp.net/Images/${item.productImg}",
                width: 70, height: 70, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.medication, size: 40),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  Text('${item.price} ${AppLocalizations.of(context)!.egp}', style: TextStyle(color: AppColors.primaryBlue)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: () => cart.removeSingleItem(item.productId),
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22, color: Colors.blue),
                  onPressed: () => cart.addItemById(item.productId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, CartProvider cart, AppLocalizations local, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.totalAmount, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('${cart.totalAmount.toStringAsFixed(2)} ${local.egp}', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => _handleCheckout(context, local),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(local.placeOrder, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context, AppLocalizations local) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      await OrderService().checkout();
      if (!mounted) return;
      Navigator.pop(context); 
      Provider.of<CartProvider>(context, listen: false).clear();
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.orderSuccess)));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, CartProvider cart, AppLocalizations local) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(local.clearCart),
        content: Text(local.clearCartConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(local.cancel)),
          TextButton(onPressed: () { cart.clear(); Navigator.pop(ctx); }, child: Text(local.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
