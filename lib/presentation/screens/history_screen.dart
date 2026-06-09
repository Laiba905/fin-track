import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/finance_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Clear filters utility method
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financeProvider = Provider.of<FinanceProvider>(context);

    // --- 🔥 DYNAMIC FILTERING LOGIC ---
    final filteredTransactions = financeProvider.transactions.where((tx) {
      // 1. Category Search Match (Case Insensitive)
      final matchesCategory = tx.category.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Date Selection Match
      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = tx.date.year == _selectedDate!.year &&
            tx.date.month == _selectedDate!.month &&
            tx.date.day == _selectedDate!.day;
      }

      return matchesCategory && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (_searchQuery.isNotEmpty || _selectedDate != null)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: Colors.grey.shade500),
              tooltip: 'Reset Filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // --- FILTER MATRIX INTERFACE WIDGET ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
            child: Row(
              children: [
                // 1. Category Search Input Field
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search category...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Modern Date Picker Selector Trigger
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: isDark ? ThemeData.dark() : ThemeData.light(),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _selectedDate != null
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedDate != null ? const Color(0xFF3B82F6) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: _selectedDate != null ? const Color(0xFF3B82F6) : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Pick Date'
                                  : DateFormat('MMM dd').format(_selectedDate!),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.w500,
                                color: _selectedDate != null ? const Color(0xFF3B82F6) : Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- LIST VIEW CORE DISPLAY MATRIX ---
          Expanded(
            child: filteredTransactions.isEmpty
                ? _buildEmptyState(_searchQuery.isNotEmpty || _selectedDate != null)
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: tx.isIncome
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            child: Icon(
                              tx.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: tx.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.category,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEE, dd MMM yyyy').format(tx.date),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${tx.isIncome ? "+" : "-"}\Rs.${tx.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: tx.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isFiltering) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltering ? Icons.search_off_rounded : Icons.receipt_long_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            isFiltering ? 'No transactions match your filters.' : 'No transactions recorded yet.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}