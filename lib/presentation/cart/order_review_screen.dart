import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/cart_provider.dart';
import '../../core/app_colors.dart';
import '../../core/api/order_service.dart';
import '../../core/api/profile_service.dart';
import '../../core/api/payment_service.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/user_model.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  UserModel? _userProfile;
  String? _initialPhone;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ProfileService().getProfile();
      setState(() {
        _userProfile = profile;
        _addressController.text = profile.address ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
        _initialPhone = profile.phoneNumber;
      });
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onConfirmAndPay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final local = AppLocalizations.of(context)!;
    final cart = Provider.of<CartProvider>(context, listen: false);

    try {
      // 1. Update profile if phone changed
      if (_phoneController.text != _initialPhone && _userProfile != null) {
        await ProfileService().updateProfile(
          firstName: _userProfile!.firstName,
          lastName: _userProfile!.lastName,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          gender: _userProfile!.gender,
        );
      }

      // 2. Checkout
      final checkoutData = await OrderService().checkout(
        address: _addressController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final int? orderId = checkoutData['orderId'] ?? checkoutData['id'];
      final bool isExisting = checkoutData['isExistingOrder'] ?? false;

      if (orderId == null) {
        throw Exception("فشل في إنشاء الطلب");
      }

      // 3. Create Payment Session
      try {
        final paymentUrl = await PaymentService().createSession(orderId);

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          final Uri url = Uri.parse(paymentUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            
            if (mounted) {
              cart.clear();
              Navigator.popUntil(context, (route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(local.orderSuccess), backgroundColor: Colors.green),
              );
            }
          } else {
            throw 'تعذر فتح رابط الدفع: $paymentUrl';
          }
        } else {
          throw 'فشل في الحصول على رابط الدفع من السيرفر';
        }
      } catch (paymentError) {
        if (isExisting) {
          // If it's an existing order and session creation fails, it's likely a server-side issue with that order
          if (mounted) _showExistingOrderError(orderId);
          return;
        }
        rethrow;
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showExistingOrderError(int orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("لديك طلب معلق"),
        content: Text("يوجد طلب سابق برقم (#$orderId) لم يكتمل. يرجى إلغاؤه من قائمة 'طلباتي' لتتمكن من إنشاء طلب جديد."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("حسناً"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await OrderService().cancelOrder(orderId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم إلغاء الطلب المعلق بنجاح، يمكنك المحاولة الآن"), backgroundColor: Colors.green),
                );
                _onConfirmAndPay(); // Retry
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("فشل إلغاء الطلب: $e"), backgroundColor: Colors.red),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("إلغاء الطلب السابق", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("مراجعة الطلب"),
        centerTitle: true,
      ),
      body: _isLoading && _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("بيانات التوصيل", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: local.phone,
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? "يرجى إدخال رقم الهاتف" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: local.address,
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "يرجى إدخال العنوان" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: "ملاحظات (اختياري)",
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 30),
                    Text("ملخص الطلب", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (ctx, i) {
                        final item = cart.items.values.toList()[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Image.network(
                              "https://rafiq1.runasp.net/Images/${item.productImg}",
                              width: 50, height: 50, fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.medication),
                            ),
                            title: Text(item.productName),
                            subtitle: Text("${item.quantity} x ${item.price} ${local.egp}"),
                            trailing: Text("${(item.quantity * item.price).toStringAsFixed(2)} ${local.egp}"),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(local.totalAmount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${cart.totalAmount.toStringAsFixed(2)} ${local.egp}", 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onConfirmAndPay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("تأكيد ودفع", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
