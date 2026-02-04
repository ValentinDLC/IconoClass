// Planning tab screen - Weekly schedule
// Displays user's weekly overview and today's sessions
// Highlights the current day and lists all sessions for today

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';

class PlanningTab extends StatelessWidget {
  const PlanningTab({super.key});

  // Generate a list of dates for the current week (Monday to Saturday)
  List<Map<String, dynamic>> _getWeekDates() {
    final today = DateTime.now(); // Current date
    final weekday = today.weekday; // Day of week (1=Monday)
    final monday =
        today.subtract(Duration(days: weekday - 1)); // Calculate Monday

    // Create a list of 6 days (Monday to Saturday) with info for each day
    return List.generate(6, (index) {
      final date = monday.add(Duration(days: index));
      return {
        'day': ['L', 'M', 'M', 'J', 'V', 'S'][index], // Day abbreviation
        'num': date.day, // Day number
        'isToday': date.day == today.day &&
            date.month == today.month, // Highlight today
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appDataProvider = Provider.of<AppDataProvider>(context);
    final user = authProvider.currentUser; // Get current user

    // Return empty widget if user is not logged in
    if (user == null) return const SizedBox();

    final weekDates = _getWeekDates(); // Weekly dates for display

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row - App title and user avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ICONO\nCLASS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              // User avatar with first letter
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    user.firstLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section title - Planning
          const Text(
            'Planning',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Weekly days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final date = weekDates[index];
              return Container(
                decoration: BoxDecoration(
                  color:
                      date['isToday'] ? Colors.yellow.shade200 : Colors.white,
                  border: Border.all(
                    color: date['isToday']
                        ? Colors.yellow.shade300
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day abbreviation (L, M, J, etc.)
                    Text(
                      date['day'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Day number
                    Text(
                      '${date['num']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Section title - Today's sessions
          const Text(
            'Aujourd\'hui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // List of today's sessions
          ...appDataProvider.todaySessions.map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session time
                  Text(
                    session.time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Session title
                  Text(
                    session.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  // Instructor name
                  Text(
                    session.instructor,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
