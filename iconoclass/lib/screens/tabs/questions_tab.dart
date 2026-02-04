// Questions tab screen - Contact instructors or team
// Displays a contact form and list of instructors
// Allows sending messages to a selected recipient (instructor or team)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_data_provider.dart';

class QuestionsTab extends StatefulWidget {
  const QuestionsTab({super.key});

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab> {
  String _selectedRecipient = 'Un intervenant'; // Default recipient
  String? _selectedInstructor; // Selected instructor if applicable
  final _messageController =
      TextEditingController(); // Message input controller

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appDataProvider = Provider.of<AppDataProvider>(context);
    final user = authProvider.currentUser;

    // Return empty widget if user is not logged in
    if (user == null) return const SizedBox();

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
                    fontSize: 24, fontWeight: FontWeight.w900, height: 1.1),
              ),
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
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section title - Questions
          const Text('Questions',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Contact form container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                const Text('💬 Contact',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),

                // Recipient dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedRecipient,
                  decoration: const InputDecoration(labelText: 'Destinataire'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Un intervenant', child: Text('Un intervenant')),
                    DropdownMenuItem(
                        value: 'L\'équipe', child: Text('L\'équipe')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRecipient = value!;
                      // Reset instructor selection when changing recipient
                      if (value != 'Un intervenant') {
                        _selectedInstructor = null;
                      }
                    });
                  },
                ),

                const SizedBox(height: 12),

                // Instructor selection dropdown (only if recipient is instructor)
                if (_selectedRecipient == 'Un intervenant')
                  DropdownButtonFormField<String>(
                    initialValue: _selectedInstructor,
                    decoration: const InputDecoration(labelText: 'Intervenant'),
                    items: [
                      // Add a default/placeholder item
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sélectionner un intervenant'),
                      ),
                      ...appDataProvider.instructors.map((i) =>
                          DropdownMenuItem(value: i.name, child: Text(i.name))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedInstructor = value;
                      });
                    },
                  ),

                const SizedBox(height: 12),

                // Message input field
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Votre message...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),

                const SizedBox(height: 12),

                // Send button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message envoyé!')),
                      );
                      _messageController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade200,
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                    child: const Text('📧 Envoyer',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section title - Instructors list
          const Text('Intervenants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // List of all instructors
          ...appDataProvider.instructors.map((instructor) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Instructor avatar with initials
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        instructor.initials,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Instructor details (name and role)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(instructor.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(instructor.role,
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
