// TODO: validation utilities | Author: Rajat Mahajan

import '../config/constants.dart';

class ValidationUtils {
  static String? validateMoodScore(int? score) {
    if (score == null) return 'Please select a mood score';
    if (score < AppConstants.minMoodScore || score > AppConstants.maxMoodScore) {
      return 'Mood must be between ${AppConstants.minMoodScore} and ${AppConstants.maxMoodScore}';
    }
    return null;
  }

  static String? validateNotes(String? notes) {
    if (notes != null && notes.length > AppConstants.maxNotesLength) {
      return 'Notes limited to ${AppConstants.maxNotesLength} characters';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }
}
