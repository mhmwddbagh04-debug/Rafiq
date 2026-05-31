import 'package:flutter/material.dart';
import '../../core/api/order_service.dart';
import '../../core/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/state_widgets.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<OrderResponse> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _orderDetailsFuture = OrderService().getOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${local.orderNumber}${widget.orderId}"),
        centerTitle: true,
      ),
      body: FutureBuilder<OrderResponse>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorStateWidget(
              errorMessage: snapshot.error.toString(),
              onRetry: _loadDetails,
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("لا توجد بيانات"));
          }

          final order = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(order, local, theme),
                const SizedBox(height: 20),
                Text(
                  local.products,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (order.items == null || order.items!.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("لا توجد منتجات في هذا الطلب"),
                  ))
                else
                  ...order.items!.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text("${item.quantity} x ${item.price} ${local.egp}"),
                          trailing: Text("${(item.quantity * item.price).toStringAsFixed(2)} ${local.egp}"),
                        ),
                      )),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(local.totalAmount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${order.totalAmount.toStringAsFixed(2)} ${local.egp}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(OrderResponse order, AppLocalizations local, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.calendar_today, local.orderDate, 
                order.orderDate.contains('T') ? order.orderDate.split('T')[0] : order.orderDate),
            const Divider(),
            _buildInfoRow(Icons.info_outline, "الحالة", _getStatusText(order.status)),
            if (order.phone != null && order.phone!.isNotEmpty) ...[
              const Divider(),
              _buildInfoRow(Icons.phone, "رقم الهاتف", order.phone!),
            ],
            if (order.address != null && order.address!.isNotEmpty) ...[
              const Divider(),
              _buildInfoRow(Icons.location_on, "العنوان", order.address!),
            ],
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const Divider(),
              _buildInfoRow(Icons.note, "ملاحظات", order.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return "تم التوصيل";
      case 'shipped': return "جاري الشحن";
      case 'paid': return "تم الدفع";
      case 'pending': return "قيد الانتظار";
      case 'cancelled': return "ملغي";
      default: return status;
    }
  }
}
