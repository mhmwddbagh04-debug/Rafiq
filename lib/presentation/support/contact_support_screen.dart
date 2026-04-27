import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../core/settings_provider.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح التطبيق المطلوب')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ ما، يرجى المحاولة لاحقاً')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final local = AppLocalizations.of(context)!;
    
    // البيانات التي طلبت إضافتها
    const phoneNumber = "01144279380";
    const email = "mhmwddbagh04@gmail.com";

    return Scaffold(
      appBar: AppBar(
        title: Text(local.supportTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSupportHeader(isDark, local),
            const SizedBox(height: 40),
            _buildContactCard(
              context: context,
              title: local.callUs,
              subtitle: phoneNumber,
              icon: Iconsax.call_outline,
              color: Colors.blue,
              onTap: () => _launchUrl(context, 'tel:$phoneNumber'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              title: local.whatsapp,
              subtitle: phoneNumber,
              icon: FontAwesome.whatsapp_brand,
              color: Colors.green,
              onTap: () => _launchUrl(context, 'https://wa.me/2$phoneNumber'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context: context,
              title: local.emailSupport,
              subtitle: email,
              icon: Iconsax.direct_outline,
              color: Colors.orange,
              onTap: () => _launchUrl(context, 'mailto:$email'),
            ),
            const SizedBox(height: 40),
            Text(
              local.availableTime,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader(bool isDark, AppLocalizations local) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.info_circle_outline,
            size: 60,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          local.howCanWeHelp,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          local.supportDesc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
