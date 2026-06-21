import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/finance_provider.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedPeriodIndex = 1; // 0 = Weekly, 1 = Monthly, 2 = Yearly

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financeProvider = Provider.of<FinanceProvider>(context);

    // --- 1. FILTER TRANSACTIONS ACCORDING TO TIMELINE ---
    var activeTransactions = financeProvider.transactions;
    if (_selectedPeriodIndex == 0) {
      activeTransactions = financeProvider.weeklyTransactions;
    } else if (_selectedPeriodIndex == 1) {
      activeTransactions = financeProvider.monthlyTransactions;
    } else if (_selectedPeriodIndex == 2) {
      activeTransactions = financeProvider.yearlyTransactions;
    }

    // --- 2. CALCULATE LIVE BALANCES ---
    double periodIncome = 0;
    double periodExpense = 0;
    Map<String, double> categoryExpenseMap = {};

    for (var tx in activeTransactions) {
      if (tx.isIncome) {
        periodIncome += tx.amount;
      } else {
        periodExpense += tx.amount;
        categoryExpenseMap[tx.category] = (categoryExpenseMap[tx.category] ?? 0) + tx.amount;
      }
    }
    final netSavings = periodIncome - periodExpense;

    final sortedCategories = categoryExpenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String highestSpendingCategory = "None";
    if (sortedCategories.isNotEmpty) {
      highestSpendingCategory = sortedCategories.first.key;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Analytics',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(isDark),
            const SizedBox(height: 24),

            _buildInsightSummaryRow(periodIncome, periodExpense, netSavings, isDark),
            const SizedBox(height: 24),

            // --- PREMIUM SMOOTH LINE CHART CARD ---
            _buildLineChartCard(context, periodIncome, periodExpense, isDark),
            const SizedBox(height: 24),

            _buildSmartInsightMessage(periodIncome, periodExpense, highestSpendingCategory, isDark),
            const SizedBox(height: 28),

            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),

            categoryExpenseMap.isEmpty
                ? _buildEmptyBreakdownState()
                : _buildCategoryBreakdownList(context, sortedCategories, periodExpense, isDark),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    final periods = ['Weekly', 'Monthly', 'Yearly'];
    return Container(
      width: double.infinity,
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPeriodIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? Colors.black : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periods[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInsightSummaryRow(double income, double expense, double savings, bool isDark) {
    return Row(
      children: [
        _buildStatBox('Income', income, const Color(0xFF10B981), isDark),
        const SizedBox(width: 8),
        _buildStatBox('Expenses', expense, const Color(0xFFEF4444), isDark),
        const SizedBox(width: 8),
        _buildStatBox('Savings', savings, const Color(0xFF3B82F6), isDark),
      ],
    );
  }

  Widget _buildStatBox(String label, double amount, Color accentColor, bool isDark) {
    final String sign = amount < 0 ? "-" : "";
    final double absAmount = amount.abs();
    final String displayAmount = absAmount > 9999 ? "${(absAmount / 1000).toStringAsFixed(0)}k" : absAmount.toStringAsFixed(0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$sign Rs.$displayAmount',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- 🔥 NEW PREMIUM SMOOTH LINE CHART LAYOUT ---
  Widget _buildLineChartCard(BuildContext context, double income, double expense, bool isDark) {
    final bool hasNoData = income == 0 && expense == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cash Flow Wave', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Chart Legends Matrix Indicator Labels
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildLegendIndicator(const Color(0xFF10B981), 'Income'),
              _buildLegendIndicator(const Color(0xFFEF4444), 'Expense'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: hasNoData
                ? Center(child: Text('No data found for this period.', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)))
                : LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 1:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Start', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)));
                          case 5:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Mid-Way', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)));
                          case 9:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('End', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)));
                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: (income > expense ? income : expense) * 1.2,
                lineBarsData: [
                  // 1. Income Spline Curve Stream Line
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 0),
                      FlSpot(3, income * 0.3),
                      FlSpot(7, income * 0.8),
                      FlSpot(10, income),
                    ],
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    ),
                  ),
                  // 2. Expense Spline Curve Stream Line
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 0),
                      FlSpot(3, expense * 0.4),
                      FlSpot(7, expense * 0.6),
                      FlSpot(10, expense),
                    ],
                    isCurved: true,
                    color: const Color(0xFFEF4444),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFEF4444).withValues(alpha: 0.08),
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

  Widget _buildLegendIndicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSmartInsightMessage(double income, double expense, String highestCategory, bool isDark) {
    String insightMessage = "Log transactions to unlock real-time intelligence analytics matrix!";
    IconData insightIcon = Icons.lightbulb_outline_rounded;
    Color iconColor = Colors.amber;

    if (income > 0 || expense > 0) {
      if (expense > income) {
        insightMessage = "Warning: Total period cash burn rate is high. Your maximum leakage occurred in '$highestCategory'.";
        insightIcon = Icons.warning_amber_rounded;
        iconColor = Colors.redAccent;
      } else {
        insightMessage = "Good job! You are in the green zone. Most of your utility budget went towards '$highestCategory'.";
        insightIcon = Icons.verified_user_rounded;
        iconColor = const Color(0xFF10B981);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(insightIcon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insightMessage,
              style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownList(BuildContext context, List<MapEntry<String, double>> categories, double totalExpense, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final percentage = totalExpense > 0 ? (category.value / totalExpense) * 100 : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        child: const Icon(Icons.label_important_outline_rounded, color: Color(0xFF3B82F6), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(category.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rs.${category.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyBreakdownState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          'No breakdown logic data metrics to compute.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ),
    );
  }
}