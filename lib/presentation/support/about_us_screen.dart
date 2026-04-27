import 'package:Rafiq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 1. Curved Modern Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                local.aboutRafiq,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkBlue,
                          AppColors.primaryBlue.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -20,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/image/logo.png',
                        height: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mission Card with Glassmorphism feel
                  _buildGlassCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.rocket_launch,
                              color: AppColors.primaryBlue,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              local.ourMission,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          local.missionContent,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                  _buildSectionHeader(local.teamBehind, isDark),
                  const SizedBox(height: 15),

                  // Team Members Horizontal/Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildMemberCard(
                        local.devMahmoud,
                        local.flutterDeveloper,
                        Icons.code,
                        isDark,
                      ),
                      _buildMemberCard(
                        local.devYoussef,
                        local.flutterDeveloper,
                        Icons.smartphone,
                        isDark,
                      ),
                      _buildMemberCard(
                        local.devAhmed,
                        local.flutterDeveloper,
                        Icons.auto_fix_high,
                        isDark,
                      ),
                      _buildMemberCard(
                        local.devMostafa,
                        local.backendDeveloper,
                        Icons.storage,
                        isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  _buildSectionHeader(
                    local.loginTitle ?? "لماذا رفيق؟",
                    isDark,
                  ),
                  const SizedBox(height: 15),

                  // Feature Tiles
                  _buildFeatureItem(
                    icon: Icons.auto_awesome,
                    iconColor: Colors.orange,
                    title: local.aiIntegration,
                    desc: local.aiDesc,
                    isDark: isDark,
                  ),
                  _buildFeatureItem(
                    icon: Icons.verified_user,
                    iconColor: Colors.green,
                    title: local.trustedSources,
                    desc: local.trustedDesc,
                    isDark: isDark,
                  ),
                  _buildFeatureItem(
                    icon: Icons.security,
                    iconColor: Colors.blue,
                    title: local.dataPrivacy,
                    desc: local.privacyDesc,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 60),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          isDark
                              ? 'assets/image/Copilot_20260417_184551.png'
                              : 'assets/image/rafiq2.png',
                          height: 40,
                          opacity: const AlwaysStoppedAnimation(0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Rafiq App v1.0.0 Stable",
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.darkBlue,
      ),
    );
  }

  Widget _buildMemberCard(
    String name,
    String role,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Icon(icon, size: 18, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          Text(
            role,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
