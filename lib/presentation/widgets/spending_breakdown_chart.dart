import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';

class SpendingBreakdownChart extends StatelessWidget {
  const SpendingBreakdownChart({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expensesOnly = financeProvider.transactions.where((tx) => !tx.isIncome).toList();
    final totalExpense = financeProvider.totalExpenses;

    Map<String, double> categoryMap = {};
    for (var tx in expensesOnly) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }

    if (expensesOnly.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, Color> categoryColors = {
      'Housing': Colors.black,
      'Food & Drink': const Color(0xFF065F46),
      'Travel': const Color(0xFFB91C1C),
      'Bills': const Color(0xFFB45309),
      'Others': const Color(0xFF9CA3AF),
    };

    Color getColor(String category) {
      if (categoryColors.containsKey(category)) {
        return categoryColors[category]!;
      }
      // Generate a deterministic color for custom categories
      return Color((category.hashCode * 0xFFFFFF).toInt()).withValues(alpha: 1.0);
    }

    List<PieChartSectionData> sections = categoryMap.entries.map((entry) {
      return PieChartSectionData(
        color: getColor(entry.key),
        value: entry.value,
        title: '',
        radius: 22, // Slightly thicker ring for full-width layout
        showTitle: false,
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 24),

          // --- 1. CHART AREA (UPER CENTER MEIN) ---
          Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 52,
                      startDegreeOffset: -90,
                      sections: sections,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Rs.${totalExpense > 999 ? "${(totalExpense / 1000).toStringAsFixed(1)}k" : totalExpense.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // --- 2. CATEGORIES AREA (NEECHE FULL WIDTH MEIN) ---
          Column(
            children: categoryMap.keys.map((cat) {
              final amount = categoryMap[cat]!;
              final double percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: getColor(cat), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),

                    // Custom long category name support safely
                    Expanded(
                      child: Text(
                        cat,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),

                    Text(
                      'Rs.${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}