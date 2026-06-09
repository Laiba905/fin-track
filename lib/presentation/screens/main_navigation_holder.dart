import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'charts_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart'; // Import updated profile screen container
import 'add_transaction_screen.dart';

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  // Real screens wrapper block with proper dashboard contextual listeners
  List<Widget> _getScreens() {
    return [
      // Index 0 (Home Dashboard)
      DashboardScreen(
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index; // See All tap toggles view to History Log
          });
        },
      ),
      // Index 1 (Analytics / Charts Screen)
      const ChartsScreen(),
      // Index 2 (Spacer Node for FAB Alignment)
      const SizedBox(),
      // Index 3 (Transaction History Log Window)
      const HistoryScreen(),
      // Index 4 (Profile Component Integrated)
      const ProfileScreen(), // Placeholder text configuration successfully removed
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = _getScreens();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex, // Safe fallback route guard
        children: screens,
      ),

      // --- PREMIUM DOCKED BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side Items (Home & Charts)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavButton(Icons.home_filled, 'Home', 0),
                  _buildNavButton(Icons.bar_chart_rounded, 'Charts', 1),
                ],
              ),
              const SizedBox(width: 40), // Notch cavity absolute spacing threshold

              // Right Side Items (History & Profile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavButton(Icons.history_toggle_off_rounded, 'History', 3),
                  _buildNavButton(Icons.person_rounded, 'Profile', 4), // Solid icon for selection alignment
                ],
              ),
            ],
          ),
        ),
      ),

      // --- CENTER ELEVATED FULLSCREEN FAB ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981), // Shifted to secure green for core action identity
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }

  // Mini Nav Button Component Template
  Widget _buildNavButton(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    // Theme aware color profiles sync with our secure personal finance green tint accent
    final activeColor = const Color(0xFF10B981);
    final inactiveColor = Colors.grey.shade400;

    return MaterialButton(
      minWidth: MediaQuery.of(context).size.width * 0.20,
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}