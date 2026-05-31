import 'order_details_screen.dart';
import 'package:Rafiq/core/api/order_service.dart';
import 'package:Rafiq/core/api/payment_service.dart';
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
    _ordersFuture = OrderService().getMyOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _ordersFuture = OrderService().getMyOrders();
    });
    await _ordersFuture.catchError((_) => <OrderResponse>[]);
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
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: FutureBuilder<List<OrderResponse>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  child: ErrorStateWidget(
                    errorMessage: snapshot.error.toString(),
                    onRetry: _loadOrders,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  child: _buildEmptyState(local, theme),
                ),
              );
            }

            final orders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index], local, theme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations local, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          local.noOrders,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(local.shopNow),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderResponse order, AppLocalizations local, ThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ExpansionTile(
          title: Text(
            "${local.orderNumber}${order.id}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              "${local.orderDate}: ${order.orderDate.contains('T') ? order.orderDate.split('T')[0] : order.orderDate}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.address != null && order.address!.isNotEmpty)
                  _buildDetailRow(Icons.location_on, "العنوان", order.address!),
                if (order.phone != null && order.phone!.isNotEmpty)
                  _buildDetailRow(Icons.phone, "الهاتف", order.phone!),
                if (order.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _handleCancel(order.id, local),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        label: Text(local.cancelOrder, style: const TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _handlePayNow(order, local),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text("دفع الآن"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (order.items != null && order.items!.isNotEmpty) ...[
            const Divider(),
            ...order.items!.map((item) => ListTile(
                  dense: true,
                  title: Text(item.productName, style: const TextStyle(fontSize: 13)),
                  subtitle: Text("${item.quantity} x ${item.price} ${local.egp}"),
                  trailing: Text("${(item.quantity * item.price).toStringAsFixed(2)} ${local.egp}"),
                )),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String statusDisplay = status;
    
    switch (status.toLowerCase()) {
      case 'delivered': 
        color = Colors.green; 
        statusDisplay = "تم التوصيل";
        break;
      case 'shipped': 
        color = Colors.teal; 
        statusDisplay = "جاري الشحن";
        break;
      case 'paid': 
        color = Colors.blue; 
        statusDisplay = "تم الدفع";
        break;
      case 'pending': 
        color = Colors.orange; 
        statusDisplay = "قيد الانتظار";
        break;
      case 'cancelled': 
        color = Colors.red; 
        statusDisplay = "ملغي";
        break;
      default: 
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusDisplay.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleCancel(int orderId, AppLocalizations local) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      await OrderService().cancelOrder(orderId);
      if (!mounted) return;
      Navigator.pop(context); // إغلاق التحميل
      _loadOrders(); // تحديث القائمة
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(local.orderCancelled)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _loadOrders(); // تحديث القائمة لرؤية الحالة الحالية
      String message = e.toString();
      if (message.startsWith("Exception: ")) {
        message = message.replaceFirst("Exception: ", "");
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  Future<void> _handlePayNow(OrderResponse order, AppLocalizations local) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      final result = await PaymentService().makePayment(
        context: context,
        amount: order.totalAmount,
        orderId: order.id,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result == 'redirected') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("جاري فتح صفحة الدفع..."), backgroundColor: Colors.blue));
      } else if (result == 'server_error' || result == 'pending_order_error') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل فتح صفحة الدفع لهذا الطلب المعلق. يرجى محاولة إلغائه والطلب من جديد."), backgroundColor: Colors.red, duration: Duration(seconds: 5)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ ما"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }
}
