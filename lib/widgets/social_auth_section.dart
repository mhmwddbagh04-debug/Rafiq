import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SocialAuthSection extends StatelessWidget {
  final String label;

  const SocialAuthSection({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Expanded(child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _socialButton(
              context: context,
              text: "Google",
              icon: Iconsax.google_1_bold,
              color: Colors.black,
              isDark: isDark,
              onPressed: () {},
            ),
            _socialButton(
              context: context,
              text: "Facebook",
              icon: Icons.facebook,
              color: Colors.blue,
              isDark: isDark,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
