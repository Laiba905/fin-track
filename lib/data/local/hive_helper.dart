import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class HiveHelper {
  // Database box key parameter naming setup
  static const String transactionBoxName = 'transaction_box';

  // 1. Initializer execution code pipeline for main memory setup
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Safety guard register logic implementation check
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    await Hive.openBox<Transaction>(transactionBoxName);
  }

  // 2. Direct helper controller configuration getter block execution code
  static Box<Transaction> getTransactionBox() {
    return Hive.box<Transaction>(transactionBoxName);
  }
}