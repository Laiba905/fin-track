import 'dart:convert'; // Yeh top par import lazmi add karein jsonEncode/jsonDecode k liye
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

  // ==========================================
  // CLOUD BACKUP & RESTORE HELPERS
  // ==========================================

  // 3. Poore local Hive data ko string/JSON banane ka function
  static Future<String> getDatabaseAsJsonString() async {
    // Aapka apna custom getter use karte hue box hasil kiya
    final box = getTransactionBox();

    // Saari transactions ko Map ki list mein convert karein
    List<Map<String, dynamic>> mappedList = box.values.map((txn) => txn.toMap()).toList();

    // Encode kar ke string bana dein
    return jsonEncode(mappedList);
  }

  // 4. Backup se aane wale JSON ko wapas Hive mein save karne ka function
  static Future<void> restoreJsonStringToDatabase(String jsonString) async {
    final List<dynamic> decodedList = jsonDecode(jsonString);
    final box = getTransactionBox();

    // Pehle local database khali karein taqe fresh backup data aaye aur duplicate na ho
    await box.clear();

    // Wapas objects bana kar save karein
    for (var item in decodedList) {
      final txn = Transaction.fromMap(item as Map<String, dynamic>);
      await box.put(txn.id, txn); // id ko key bana kar save karein taqe update asani se ho sake
    }
  }
}