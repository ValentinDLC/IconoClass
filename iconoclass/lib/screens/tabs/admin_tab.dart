// Admin tab for instructors - Manage sessions and app content
// Allows instructors to create, edit, and delete sessions
// Provides interface for managing app data and syncing with Google Sheets

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';

class AdminTab extends StatelessWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null || (!authProvider.isInstructor && !authProvider.isAdmin)) {
      return const Center(
        child: Text('Accès refusé'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Back-Office',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Modifiez le contenu de l\'application',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // User Info Section
          _AdminSection(
            title: '👤 Utilisateur',
            child: Column(
              children: [
                _AdminField(
                  label: 'Prénom',
                  value: user.firstName,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                _AdminField(
                  label: 'Nom',
                  value: user.lastName,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                _AdminField(
                  label: 'Email',
                  value: user.email,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sync Button
          Consumer<AppDataProvider>(
            builder: (context, appDataProvider, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: appDataProvider.isLoading
                      ? null
                      : () async {
                          await appDataProvider.syncWithSheets();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Synchronisation terminée!'),
                              ),
                            );
                          }
                        },
                  icon: appDataProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    appDataProvider.isLoading
                        ? 'Synchronisation...'
                        : 'Synchroniser avec Google Sheets',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Sessions List
          _AdminSection(
            title: '📅 Sessions',
            child: Consumer<AppDataProvider>(
              builder: (context, appDataProvider, _) {
                return Column(
                  children: [
                    // Spread operator without unnecessary toList()
                    ...appDataProvider.sessions.map((session) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${session.time} - ${session.instructor}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _AdminSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AdminField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _AdminField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
      ),
      onChanged: onChanged,
    );
  }
}
