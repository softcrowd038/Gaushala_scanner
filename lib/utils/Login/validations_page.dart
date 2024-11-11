import 'package:flutter/material.dart';

String? validateUserId(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    showValidationErrorSnackbar(context, 'User ID cannot be empty');
    return 'User ID cannot be empty';
  }


  if (value.length < 6) {
    showValidationErrorSnackbar(
        context, 'User ID should be at least 6 characters');
    return 'User ID should be at least 6 characters';
  }

  return null;
}

String? validatePassword(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    showValidationErrorSnackbar(context, 'Password cannot be empty');
    return 'Password cannot be empty';
  }

  return null;
}

void showValidationErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ),
  );
}
