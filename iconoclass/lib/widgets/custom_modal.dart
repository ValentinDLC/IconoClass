/*
  custom_modal.dart
  IconoClass - Learning Platform
  Reusable modal widget with title, scrollable content, and close action.
*/

import 'package:flutter/material.dart';

/// Custom modal overlay widget
/// Displays a centered dialog with a title and scrollable content
class CustomModal extends StatelessWidget {
  // Title displayed at the top of the modal
  final String title;

  // Main content inside the modal
  final Widget content;

  // Function called when the modal should close
  final VoidCallback onClose;

  const CustomModal({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Close modal when tapping outside the dialog
      onTap: onClose,
      child: Container(
        // Semi-transparent background overlay
        color: Colors.black.withAlpha(128),
        child: Center(
          child: GestureDetector(
            // Prevent closing when tapping inside the modal
            onTap: () {},
            child: Container(
              // Modal size relative to screen
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Header section (title + close button)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Modal title
                        Expanded(
                          // Ajouté pour éviter l'overflow si le titre est trop long
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Close button
                        IconButton(
                          onPressed: onClose,
                          padding: EdgeInsets.zero,
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
