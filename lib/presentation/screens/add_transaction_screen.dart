import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();

  final List<String> _categories = ['Housing', 'Food & Drink', 'Travel', 'Bills', 'Salary', 'Investment', 'Others'];
  String _selectedCategory = 'Food & Drink';
  String _selectedCurrency = 'Rs.';
  bool _isIncome = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note;
      _isIncome = tx.isIncome;
      _selectedDate = tx.date;
      _selectedTime = TimeOfDay(hour: tx.date.hour, minute: tx.date.minute);

      if (!_categories.contains(tx.category)) {
        _categories.insert(_categories.length - 1, tx.category);
      }
      _selectedCategory = tx.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // --- 📅 FIXED DARK MODE DATE PICKER ---
  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: Color(0xFF10B981), onPrimary: Colors.white, surface: Color(0xFF1E1E1E), onSurface: Colors.white)
                : const ColorScheme.light(primary: Color(0xFF10B981), onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // --- ⏰ FIXED DARK MODE TIME PICKER ---
  Future<void> _pickTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: Color(0xFF10B981), onPrimary: Colors.white, surface: Color(0xFF1E1E1E), onSurface: Colors.white)
                : const ColorScheme.light(primary: Color(0xFF10B981), onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showAddCategoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('New Category', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: _customCategoryController,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'e.g., Gym, Freelance',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              final newCat = _customCategoryController.text.trim();
              if (newCat.isNotEmpty && !_categories.contains(newCat)) {
                setState(() {
                  _categories.insert(_categories.length - 1, newCat);
                  _selectedCategory = newCat;
                });
                _customCategoryController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingTransaction != null ? 'Edit Transaction' : 'Add Transaction',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TOGGLE BUTTONS ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(child: _buildTypeButton('Expense', !_isIncome, const Color(0xFFEF4444))),
                  Expanded(child: _buildTypeButton('Income', _isIncome, const Color(0xFF10B981))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. AMOUNT FIELD ---
            Text('Amount', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      value: _selectedCurrency,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                      items: ['Rs.', '\$', '€', '£'].map((curr) => DropdownMenuItem(value: curr, child: Text(curr))).toList(),
                      onChanged: (val) => setState(() => _selectedCurrency = val!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 3. CATEGORY DROPDOWN ---
            Text('Category', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              value: _selectedCategory,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              items: [
                ..._categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                const DropdownMenuItem(value: 'ADD_NEW_CUSTOM', child: Text('+ Add New Category', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
              ],
              onChanged: (val) => val == 'ADD_NEW_CUSTOM' ? _showAddCategoryDialog() : setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 24),

            // --- 4. DATE & TIME ---
            Row(
              children: [
                Expanded(child: _buildPickerTile(Icons.calendar_month_rounded, "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", _pickDate)),
                const SizedBox(width: 12),
                Expanded(child: _buildPickerTile(Icons.access_time_rounded, _selectedTime.format(context), _pickTime)),
              ],
            ),
            const SizedBox(height: 24),

            // --- 5. NOTES ---
            Text('Notes', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Add a small note...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            // --- 6. SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _saveTransaction,
                child: Text(widget.existingTransaction != null ? 'Update Record' : 'Save Transaction', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, bool isActive, Color activeColor) {
    return GestureDetector(
      onTap: () => setState(() => _isIncome = title == 'Income'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isActive ? activeColor : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey.shade500))),
      ),
    );
  }

  Widget _buildPickerTile(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [Icon(icon, size: 18, color: const Color(0xFF10B981)), const SizedBox(width: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]),
      ),
    );
  }

  void _saveTransaction() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null) return;

    final finalDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    final updatedTransaction = Transaction(
      id: widget.existingTransaction?.id ?? const Uuid().v4(),
      amount: double.parse(amountText),
      category: _selectedCategory,
      date: finalDateTime,
      note: _noteController.text.trim(),
      isIncome: _isIncome,
    );

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    if (widget.existingTransaction != null) {
      provider.addTransaction(updatedTransaction).then((_) => provider.loadTransactions());
    } else {
      provider.addTransaction(updatedTransaction);
    }
    Navigator.pop(context);
  }
}