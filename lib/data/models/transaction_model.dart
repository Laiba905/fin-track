import 'package:hive/hive.dart';

// ye line auto generated file ko is sy jory gi
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  @HiveField(5)
  // true = income, false = expense
  final bool isIncome;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.isIncome,
  });

  // 1. Transaction Object ko Map (JSON ready format) mein convert karne k liye
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(), // DateTime ko string banana zaroori hai JSON k liye
      'note': note,
      'isIncome': isIncome,
    };
  }

  // 2. Backup se aane wale Map ko wapas Transaction Object banane k liye
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      amount: (map['amount'] as num).toDouble(), // Type casting safe rakhne k liye
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      isIncome: map['isIncome'] ?? false,
    );
  }
}