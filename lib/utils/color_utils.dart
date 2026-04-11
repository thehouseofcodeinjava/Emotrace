// TODO: color utilities | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

class AppColorUtils {
  static Color getMoodColor(int moodScore) {
    return moodColors[moodScore.clamp(1, 10)] ?? AppTheme.teal;
  }

  static String getMoodLabel(int moodScore) {
    return AppConstants.moodLabels[moodScore.clamp(1, 10)] ?? 'VIBE: UNKNOWN';
  }

  static String getMoodEmoji(int moodScore) {
    return AppConstants.moodEmojis[moodScore.clamp(1, 10)] ?? '🙂';
  }
}
