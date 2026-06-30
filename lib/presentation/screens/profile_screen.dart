import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/google_drive_service.dart';
import '../../data/local/hive_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isBackupEnabled = false; // Cloud backup switch status
  bool _isBackupLoading = false; // Loading indicator toggle handler
  String _lastSyncedText = "Never"; // Last sync timestamp text

  @override
  void initState() {
    super.initState();
    _loadBackupPreferences();
  }

  // App start hote hi SharedPreferences se check karein k kya pehle backup active tha
  Future<void> _loadBackupPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isBackupEnabled = prefs.getBool('isCloudBackupEnabled') ?? false;
        _lastSyncedText = prefs.getString('lastSyncedAt') ?? "Never";
      });

      // Restore session background mein (Bina pop-up ke)
      if (_isBackupEnabled) {
        await GoogleDriveService.restoreSession();
      }
    } catch (e) {
      debugPrint("Preferences load error: $e");
    }
  }

  // Manual Backup logic for one-tap sync
  Future<void> _manualSync(FinanceProvider financeProvider) async {
    setState(() => _isBackupLoading = true);
    try {
      final account = await GoogleDriveService.signIn();
      if (account != null) {
        String localDataJson = await HiveHelper.getDatabaseAsJsonString();
        bool success = await GoogleDriveService.backupData(localDataJson);
        if (success) {
          final now = DateTime.now();
          final timeStr = "${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastSyncedAt', timeStr);

          setState(() => _lastSyncedText = timeStr);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup successful!'), backgroundColor: Color(0xFF10B981)),
            );
          }
        }
      }
    } finally {
      setState(() => _isBackupLoading = false);
    }
  }

  /// --- 🔄 RESTORE WORKFLOW CONFIRMATION DIALOG INTERFACE ---
  void _triggerRestoreSequence(String backupJson, FinanceProvider financeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.cloud_download_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Text(
                'Backup Found',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'A previous backup was discovered in your Drive. Would you like to restore your history now?',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                // Even if skipped, we enable the backup toggle since login was successful
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isCloudBackupEnabled', true);
                setState(() => _isBackupEnabled = true);
              },
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                setState(() => _isBackupLoading = true);

                try {
                  // Perform restoration
                  await HiveHelper.restoreJsonStringToDatabase(backupJson);

                  // Force provider to reload memory list from the new Hive entries
                  await financeProvider.loadTransactions();

                  // Enable backup status
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isCloudBackupEnabled', true);

                  if (mounted) {
                    setState(() {
                      _isBackupEnabled = true;
                      _isBackupLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('History restored successfully!'),
                        backgroundColor: Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Restore error: $e");
                  if (mounted) setState(() => _isBackupLoading = false);
                }
              },
              child: const Text('Restore Now'),
            ),
          ],
        );
      },
    );
  }

  // Complete Robust Backup Toggle Handler Logic Block (With Automatic Restore Scanning)
  void _handleBackupToggle(bool value, FinanceProvider financeProvider) async {
    final prefs = await SharedPreferences.getInstance();

    if (value == false) {
      // User completely turns off the backup sync layout
      await prefs.setBool('isCloudBackupEnabled', false);
      setState(() {
        _isBackupEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud Backup disabled.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Start loading state for activation
    setState(() {
      _isBackupLoading = true;
    });

    try {
      // 1. Trigger Google Sign-In Sequence flow safely
      final account = await GoogleDriveService.signIn();

      if (account != null) {
        // --- 🔍 SCANNING FOR PRE-EXISTING CLOUD SNAPSHOTS ---
        String? existingCloudData = await GoogleDriveService.downloadBackupData();

        if (existingCloudData != null && existingCloudData.isNotEmpty) {
          // Pause and let user decide to restore or skip
          if (mounted) {
            setState(() => _isBackupLoading = false);
            _triggerRestoreSequence(existingCloudData, financeProvider);
          }
          // Note: Automatic sync for THIS specific toggle action stops here to prevent overwriting
          // Once user restores, they can use 'Sync Now' or toggle again.
          return;
        }

        // 2. Initial safe data push/sync setup if no existing backup found
        String localDataJson = await HiveHelper.getDatabaseAsJsonString();
        bool success = await GoogleDriveService.backupData(localDataJson);

        if (success) {
          await prefs.setBool('isCloudBackupEnabled', true);
          setState(() {
            _isBackupEnabled = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google Drive Backup Sync Successfully.', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        // User canceled the login window flow
        setState(() {
          _isBackupEnabled = false;
        });
      }
    } catch (error) {
      debugPrint("CRITICAL BACKUP OPERATION ERROR: $error");
      setState(() {
        _isBackupEnabled = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBackupLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to financial transactions dataset globally
    final financeProvider = context.watch<FinanceProvider>();

    // --- 📊 RUNTIME DATABASE METRICS GENERATOR ---
    final transactionsList = financeProvider.transactions;
    final int totalTransactions = transactionsList.length;

    double totalIncome = 0;
    double totalExpenses = 0;

    for (var tx in transactionsList) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- 👤 APPS SYSTEM BRAND IDENTITY DISPLAY ---
            Center(
              child: Column(
                children: [
                  const Text(
                    'FinTrack',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            _isBackupEnabled ? Icons.cloud_done_rounded : Icons.shield_rounded,
                            size: 12,
                            color: const Color(0xFF10B981)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isBackupEnabled ? 'Cloud Backup Active' : '100% Offline Mode',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 📊 DATA ENGINE ANALYTICS VIEW BLOCK ---
            _buildSectionHeader('Database Analytics Insight'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMetricRow('Total Logs Written', '$totalTransactions entries', Colors.blue),
                  Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  _buildMetricRow('Aggregated Income', 'Rs.${totalIncome.toStringAsFixed(0)}', const Color(0xFF10B981)),
                  Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  _buildMetricRow('Aggregated Expenses', 'Rs.${totalExpenses.toStringAsFixed(0)}', const Color(0xFFEF4444)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- ⚙️ USER PREFERENCES LIST UTILITIES ---
            _buildSectionHeader('Preferences & Utilities'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // --- 🌓 LIVE SYSTEM THEME SETTINGS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          child: const Icon(Icons.dark_mode_rounded, size: 15, color: Color(0xFF8B5CF6)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Dark Theme Layout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        Switch.adaptive(
                          value: isDark,
                          activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 50),

                  // --- ☁️ SECURE GOOGLE DRIVE LIVE BACKUP CONTROLLER SWITCH ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          child: const Icon(Icons.cloud_queue_rounded, size: 15, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Google Drive Backup', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('Sync encrypted database safely', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (_isBackupEnabled && !_isBackupLoading)
                          IconButton(
                            icon: const Icon(Icons.sync_rounded, size: 20, color: Color(0xFF10B981)),
                            onPressed: () => _manualSync(financeProvider),
                            tooltip: 'Sync Now',
                          ),
                        _isBackupLoading
                            ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).primaryColor),
                          ),
                        )
                            : Switch.adaptive(
                          value: _isBackupEnabled,
                          activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) => _handleBackupToggle(val, financeProvider),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 50),

                  // Wipe Local Database Device Storage Logs
                  _buildActionRowTile(
                    icon: Icons.layers_clear_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'Wipe Out Local Logs',
                    trailingText: 'Reset Storage',
                    onTap: () => _handleClearStorageAction(financeProvider),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 50),

                  _buildActionRowTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.grey,
                    title: 'Last Synced',
                    trailingText: _lastSyncedText,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildActionRowTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: iconColor.withValues(alpha: 0.15),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(trailingText, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _handleClearStorageAction(FinanceProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Clear all data?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'This will permanently delete all your transaction records. This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await provider.clearAllTransactions();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared.', style: TextStyle(color: Colors.white)),
                    backgroundColor: Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );
  }
}