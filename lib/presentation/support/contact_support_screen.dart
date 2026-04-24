import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/settings_provider.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final local = AppLocalizations.of(context)!;

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
              title: local.callUs,
              subtitle: "+20 123 456 7890",
              icon: Iconsax.call_outline,
              color: Colors.blue,
              onTap: () {
                // TODO: Launch phone dialer
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: local.whatsapp,
              subtitle: local.whatsappDesc,
              icon: FontAwesome.whatsapp_brand,
              color: Colors.green,
              onTap: () {
                // TODO: Launch WhatsApp
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              title: local.emailSupport,
              subtitle: "support@rafiq.com",
              icon: Iconsax.direct_outline,
              color: Colors.orange,
              onTap: () {
                // TODO: Launch email app
              },
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
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(15),
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
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
