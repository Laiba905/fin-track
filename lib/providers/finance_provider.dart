import 'package:flutter/material.dart';
import '../../data/local/hive_helper.dart';
import '../../data/models/transaction_model.dart';

class FinanceProvider extends ChangeNotifier{
  // 1. private list jo memory mae transactions ko hold kry gi
  List<Transaction> _transactions = [];

  // getters taky UI screens data ko read kr sky
  List<Transaction> get transactions => _transactions;

  double _totalBalance = 0.0;
  double get totalBalance => _totalBalance;

  double _totalIncome = 0.0;
  double get totalIncome => _totalIncome;

  double _totalExpenses = 0.0;
  double get totalExpenses => _totalExpenses;

  // 2. load transactions from hive
  void loadTransactions(){
    final box = HiveHelper.getTransactionBox();

    // hive box sy sari values nikaal kr list mae convert krna
    _transactions = box.values.toList();
    // transactions ko date k hisaab sy sort krna (newest first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    // nayi values k aty hi totals calculate krna
    _calculateTotals();
    // refresh ui
    notifyListeners();
  }

  // 3. add transaction to hive
  Future<void> addTransaction(Transaction transaction) async{
    final box = HiveHelper.getTransactionBox();
    // hive mae transaction save krna id ko key bna kr
    await box.put(transaction.id, transaction);
    // local list update and recalculate
    loadTransactions();
  }

  // 4. delete transactions from hive
  Future<void> deleteTransaction(String id) async{
    final box = HiveHelper.getTransactionBox();
    await box.delete(id);
    loadTransactions();
  }

  // 5. bgc calculator logic (private func)
  void _calculateTotals(){
    _totalBalance = 0.0;
    _totalIncome = 0.0;
    _totalExpenses = 0.0;

    for(var tx in _transactions){
      if(tx.isIncome){
        _totalIncome += tx.amount;
        _totalBalance += tx.amount;
      } else{
        _totalExpenses += tx.amount;
        _totalBalance += tx.amount;
      }
    }
  }
}

















