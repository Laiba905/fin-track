import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Date aur Time formatting k liye
import '../../core/utils/responsive_helper.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/spending_breakdown_chart.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Text(
              'FinTrack',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark ? Colors.amber : Colors.black87,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 10.0,
          ),
          child: Consumer<FinanceProvider>(
            builder: (context, financeProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildMainBalanceCard(context, financeProvider),
                  const SizedBox(height: 16),
                  _buildSplitStatCards(context, financeProvider),
                  const SizedBox(height: 24),
                  const SpendingBreakdownChart(), // Yeh ab vertical layout render karega
                  const SizedBox(height: 24),

                  // --- RECENT ACTIVITY HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(3); // Main holder ko History tab pr bhejega
                          }
                        },
                        child: Text('See All', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  financeProvider.transactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionFeedList(context, financeProvider, isDark),

                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- TOP DYNAMIC CARD BLOCK ---
  Widget _buildMainBalanceCard(BuildContext context, FinanceProvider provider) {
    double expense = provider.totalExpenses;
    double income = provider.totalIncome;
    String dynamicMessage = "No usage activity this month";
    Color indicatorBg = Colors.grey.withValues(alpha: 0.15);
    Color indicatorText = Colors.grey;

    if (income > 0) {
      double usagePercent = (expense / income) * 100;
      if (usagePercent > 75) {
        dynamicMessage = "Alert: Spent ${usagePercent.toStringAsFixed(0)}% of income!";
        indicatorBg = const Color(0xFFEF4444).withValues(alpha: 0.2);
        indicatorText = const Color(0xFFF87171);
      } else {
        dynamicMessage = "Good: Spent only ${usagePercent.toStringAsFixed(0)}% of income";
        indicatorBg = const Color(0xFF10B981).withValues(alpha: 0.2);
        indicatorText = const Color(0xFF34D399);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance', style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500)),
              //const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rs. ${provider.totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: indicatorBg, borderRadius: BorderRadius.circular(20)),
            child: Text(
              dynamicMessage,
              style: TextStyle(color: indicatorText, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- INCOME & EXPENSE SPLIT TILES ---
  Widget _buildSplitStatCards(BuildContext context, FinanceProvider provider) {
    return Column(
      children: [
        _buildSingleStatTile(context: context, title: 'Monthly Income', amount: provider.totalIncome, icon: Icons.arrow_upward_rounded, iconColor: const Color(0xFF10B981)),
        const SizedBox(height: 12),
        _buildSingleStatTile(context: context, title: 'Monthly Expenses', amount: provider.totalExpenses, icon: Icons.arrow_downward_rounded, iconColor: const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildSingleStatTile({required BuildContext context, required String title, required double amount, required IconData icon, required Color iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: iconColor.withValues(alpha: 0.12), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('Rs. ${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // --- EMPTY PLACEHOLDER STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No activities recorded.\nPress (+) to log transactions.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }

  // --- RECENT RECENT ACTIVITY FEED (MAX 3 ITEMS WITH SYNCED DATE COLUMN) ---
  Widget _buildTransactionFeedList(BuildContext context, FinanceProvider provider, bool isDark) {
    final recentTransactions = provider.transactions.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTransactions.length,
      itemBuilder: (context, index) {
        final tx = recentTransactions[index];

        // Proper Date and Time structure formatting
        final formattedDate = DateFormat('dd MMM • hh:mm a').format(tx.date);

        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.horizontal,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 26),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 26),
          ),
          onDismissed: (direction) {
            _performDeleteWithUndo(context, provider, tx);
          },
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmationDialog(context, tx.category);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _navigateToEdit(context, tx), // Tap row opens Edit view full mode
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    // Icon Node
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: tx.isIncome ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      child: Icon(tx.isIncome ? Icons.account_balance_wallet_outlined : Icons.shopping_bag_outlined, color: tx.isIncome ? const Color(0xFF10B981) : const Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: 14),

                    // Left Text Column: Category & Note Title safely wrapped
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(tx.note.isEmpty ? 'No description' : tx.note, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Text Column: Price and Date Timestamp in Perfect Geometry Alignment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${tx.isIncome ? "+" : "-"} Rs.${tx.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: tx.isIncome ? const Color(0xFF10B981) : (isDark ? Colors.white : Colors.black87)
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _performDeleteWithUndo(BuildContext context, FinanceProvider provider, var transaction) {
    provider.deleteTransaction(transaction.id);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${transaction.category} deleted', style: TextStyle(color: Colors.red)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amber,
          onPressed: () {
            provider.addTransaction(transaction);
          },
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, var transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(existingTransaction: transaction),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Transaction?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the "$category" transaction?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}