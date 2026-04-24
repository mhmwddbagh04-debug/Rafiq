import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/settings_provider.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final isDark = provider.isDarkMode;
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(local.aboutRafiq),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Lottie.asset(
              'assets/animations/Hand.json',
              height: 200,
              fit: BoxFit.contain,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMainInfoCard(
                    isDark: isDark,
                    title: local.ourMission,
                    content: local.missionContent,
                  ),

                  const SizedBox(height: 25),

                  _buildSectionLabel(local.teamBehind, isDark),
                  const SizedBox(height: 15),

                  _buildModernDevCard(
                    name: local.devMahmoud,
                    role: local.flutterDeveloper,
                    isDark: isDark,
                  ),
                  _buildModernDevCard(
                    name: local.devYoussef,
                    role: local.flutterDeveloper,
                    isDark: isDark,
                  ),
                  _buildModernDevCard(
                    name: local.devAhmed,
                    role: local.flutterDeveloper,
                    isDark: isDark,
                  ),
                  _buildModernDevCard(
                    name: local.devMostafa,
                    role: local.backendDeveloper,
                    isDark: isDark,
                    icon: Icons.storage_rounded,
                  ),

                  const SizedBox(height: 30),

                  _buildDetailTile(
                    icon: Icons.auto_awesome,
                    title: local.aiIntegration,
                    desc: local.aiDesc,
                    isDark: isDark,
                  ),
                  _buildDetailTile(
                    icon: Icons.verified_user,
                    title: local.trustedSources,
                    desc: local.trustedDesc,
                    isDark: isDark,
                  ),
                  _buildDetailTile(
                    icon: Icons.security,
                    title: local.dataPrivacy,
                    desc: local.privacyDesc,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 40),

                  Image.asset(
                    isDark ? 'assets/image/Copilot_20260417_184551.png' : 'assets/image/rafiq2.png',
                    height: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${local.version} 1.0.0 Stable",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard({required bool isDark, required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildModernDevCard({
    required String name,
    required String role,
    required bool isDark,
    IconData icon = Icons.flutter_dash,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  role,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({required IconData icon, required String title, required String desc, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
