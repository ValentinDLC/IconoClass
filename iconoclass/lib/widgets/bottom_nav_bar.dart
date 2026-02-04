/*
  bottom_nav_bar.dart
  IconoClass - Learning Platform
  Custom bottom navigation bar widget used to switch between main screens.
*/

import 'package:flutter/material.dart';

/// Custom bottom navigation bar widget
/// Displays navigation icons and labels and handles tab selection
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        color: Colors.white,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
            _buildNavItem(
              icon: Icons.calendar_today,
              label: 'Planning',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.chat_bubble,
              label: 'Questions',
              index: 2,
            ),
            _buildNavItem(icon: Icons.person, label: 'Profil', index: 3),
            _buildNavItem(icon: Icons.settings, label: 'Admin', index: 4),
          ],
        ),
      ),
    );
  }

  /// Builds a single navigation item (icon + label)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
