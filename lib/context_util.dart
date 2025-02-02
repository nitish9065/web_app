import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  void showToast(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(
          milliseconds: 500,
        ),
      ),
    );
  }
}
