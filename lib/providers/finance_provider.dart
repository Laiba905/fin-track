import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/local/hive_helper.dart'; // Make sure path is correct

class FinanceProvider extends ChangeNotifier {
  // Main storage list jo UI aur Hive box ke darmiyan sync rahegi
  List<Transaction> _transactions = [];

  List<Transaction> get transactions {
    // Newest transactions hamesha top par rakhne ke liye sorting hook
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return _transactions;
  }

  // --- 📅 TIME PERIOD FILTER GETTERS ---
  List<Transaction> get weeklyTransactions {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return _transactions.where((tx) => tx.date.isAfter(lastWeek)).toList();
  }

  List<Transaction> get monthlyTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();
  }

  List<Transaction> get yearlyTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) => tx.date.year == now.year).toList();
  }

  // --- 💰 GLOBAL BALANCES CONTROLLERS ---
  double get totalBalance {
    double balance = 0;
    for (var tx in _transactions) {
      if (tx.isIncome) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  double get totalIncome {
    return _transactions.where((tx) => tx.isIncome).fold(0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpenses {
    return _transactions.where((tx) => !tx.isIncome).fold(0, (sum, tx) => sum + tx.amount);
  }

  // --- 🛠️ MUTATION DATA OPERATIONS (FIXED) ---

  // 1. App start hote hi data database se memory list mein khichne ke liye
  Future<void> loadTransactions() async {
    try {
      final box = HiveHelper.getTransactionBox();
      // Hive se saara data utha kar local array list ko pass kar diya
      _transactions = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading from Hive: $e");
    }
  }

  // 2. Transaction ko permanent persistent memory mein save karne ke liye
  Future<void> addTransaction(Transaction tx) async {
    try {
      final box = HiveHelper.getTransactionBox();

      // FIX CRITICAL: Database mein permanent file layer par save kiya
      await box.put(tx.id, tx);

      // Local list UI management state update sync context
      final index = _transactions.indexWhere((t) => t.id == tx.id);
      if (index != -1) {
        _transactions[index] = tx; // Edit optimization override
      } else {
        _transactions.add(tx); // Fresh entry insertion
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error saving to Hive: $e");
    }
  }

  // 3. Transaction ko database se hatane ke liye
  Future<void> deleteTransaction(String id) async {
    try {
      final box = HiveHelper.getTransactionBox();

      // FIX CRITICAL: Local disk block storage se entry remove ki
      await box.delete(id);

      _transactions.removeWhere((tx) => tx.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting from Hive: $e");
    }
  }

  // 4. Poore local database logs ko wipe karne k liye (Settings Reset)
  Future<void> clearAllTransactions() async {
    try {
      final box = HiveHelper.getTransactionBox();
      await box.clear();
      _transactions.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing database: $e");
    }
  }
}