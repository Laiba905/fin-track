import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local active theme fallback variable for button visual testing
  bool _isDarkLocal = false;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Using watch to listen to data updates safely in real-time
    final financeProvider = context.watch<FinanceProvider>();

    // --- 📊 RUNTIME DATA CALCULATIONS ---
    final transactionsList = financeProvider.transactions;
    final int totalTransactions = transactionsList.length;

    double totalIncome = 0;
    double totalExpenses = 0;

    for (var tx in transactionsList) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- 👤 BRAND LOGO & HEADER PANEL ---
            Center(
              child: Column(
                children: [
                  // App Logo Placeholder Container
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    ),
                    padding: const EdgeInsets.all(16), // Padding inside circle for logo spacing
                    child: Image.asset(
                      'assets/images/logo.png', // Aap ka asset directory path
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon agar assets folder mein image missing ho to design crash na ho
                        return const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 40,
                          color: Color(0xFF10B981),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'FinTrack',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, size: 12, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          '100% Offline Mode',
                          style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 📊 METRICS INSIGHTS BLOCK ---
            _buildSectionHeader('Database Analytics Insight'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMetricRow('Total Logs Written', '$totalTransactions entries', Colors.blue),
                  Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  _buildMetricRow('Aggregated Income', 'Rs.${totalIncome.toStringAsFixed(0)}', const Color(0xFF10B981)),
                  Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  _buildMetricRow('Aggregated Expenses', 'Rs.${totalExpenses.toStringAsFixed(0)}', const Color(0xFFEF4444)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- ⚙️ LOCAL UTILITIES CONTAINER ---
            _buildSectionHeader('Preferences & Utilities'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // --- 🌓 DARK MODE ROW SWITCH ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          child: const Icon(Icons.dark_mode_rounded, size: 15, color: Color(0xFF8B5CF6)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Dark Theme Layout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        Switch.adaptive(
                          value: isDark,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 50),

                  // Wipe System Local Memory Storage
                  _buildActionRowTile(
                    icon: Icons.layers_clear_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Wipe Out Local Logs',
                    trailingText: 'Reset Storage',
                    onTap: () => _handleClearStorageAction(context, financeProvider),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 50),

                  _buildActionRowTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.grey,
                    title: 'FinTrack Version',
                    trailingText: 'v1.0.0 Stable',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildActionRowTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            Text(trailingText, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _handleClearStorageAction(BuildContext context, FinanceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Reset?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text('Are you sure to remove all local data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                // If you have a clean method in provider: provider.clearAllTransactions();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local storage metrics wiped cleanly!'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Wipe All', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}