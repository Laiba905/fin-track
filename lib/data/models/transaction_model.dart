import 'package:hive/hive.dart';

// ye line auto generated file ko is sy jory gi
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject{
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

}



















