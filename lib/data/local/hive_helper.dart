import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class HiveHelper{
  // db box ka naam jo puri app mae call ho ga
  static const String transactionBoxName = 'transaction_box';
  // 1. func jo app start hoty hi db ko ready kry ga
  static Future<void> initHive() async{
    // phone ki local storage directory ko initialize krna
    await Hive.initFlutter();
    // jo adapter generate kiya tha usy register krna
    Hive.registerAdapter(TransactionAdapter());
    // transactions save krny k liayay permanent box open krna
    await Hive.openBox<Transaction>(transactionBoxName);
  }

  // 2. box ko direct access krny k liayay getter func
  static Box<Transaction> getTransactionBox(){
    return Hive.box<Transaction>(transactionBoxName);
  }

}