import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';

class FinanceProvider extends ChangeNotifier {
  final List<Transaction> _transactions = []; // Aap ka main storage list (Hive local sync)

  List<Transaction> get transactions {
    // Newest transactions top par show karne k liye sorted array
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

  // --- 🛠️ MUTATION DATA OPERATIONS ---

  Future<void> addTransaction(Transaction tx) async {
    // If transaction with same ID exists, update it, otherwise add new
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
    } else {
      _transactions.add(tx);
    }
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  // Mocking loadTransactions for now as requested by UI logic
  Future<void> loadTransactions() async {
    notifyListeners();
  }
}
