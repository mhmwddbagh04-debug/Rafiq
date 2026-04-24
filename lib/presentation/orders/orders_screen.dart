import 'package:Rafiq/core/api/order_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:Rafiq/data/models/order_model.dart';
import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:Rafiq/widgets/state_widgets.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderResponse>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = OrderService().getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    var local = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(local.myOrders),
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrderResponse>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorStateWidget(
              errorMessage: snapshot.error.toString(),
              onRetry: _loadOrders,
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(local, theme);
          }

          final orders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], local, theme);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations local, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "No orders yet",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.shopNow),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderResponse order, AppLocalizations local, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(
          "Order #${order.id}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text("Date: ${order.orderDate.split('T')[0]}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildStatusBadge(order.status),
          ],
        ),
        trailing: Text(
          "${order.totalAmount} ${local.egp}",
          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          const Divider(),
          if (order.status.toLowerCase() == 'pending')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton.icon(
                onPressed: () => _handleCancel(order.id),
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text("Cancel Order", style: TextStyle(color: Colors.red)),
              ),
            ),
          // هنا يمكن إضافة قائمة بالمنتجات داخل الأوردر إذا كان الباك اند يرسلها
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleCancel(int orderId) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      await OrderService().cancelOrder(orderId);
      if (!mounted) return;
      Navigator.pop(context); // إغلاق التحميل
      _loadOrders(); // تحديث القائمة
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order cancelled successfully")));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }
}
