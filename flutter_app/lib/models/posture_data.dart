import 'package:flutter/material.dart';

enum PostureState { good, warning, bad, critical, unknown }

class PostureData {
  final PostureState state;
  final double pitch, roll, refPitch, refRoll, deviation;
  final int totalAlerts, badPostureTime, sessionDuration;
  final bool isCalibrated, silentMode, wifiConnected;
  final int language, rssi;

  PostureData({
    required this.state,
    required this.pitch,
    required this.roll,
    required this.refPitch,
    required this.refRoll,
    required this.deviation,
    required this.totalAlerts,
    required this.badPostureTime,
    required this.sessionDuration,
    required this.isCalibrated,
    required this.language,
    required this.silentMode,
    required this.wifiConnected,
    required this.rssi,
  });

  factory PostureData.fromJson(Map<String, dynamic> json) {
    return PostureData(
      state: _parseState(json['state']?.toString() ?? 'unknown'),
      pitch: (json['pitch'] ?? 0).toDouble(),
      roll: (json['roll'] ?? 0).toDouble(),
      refPitch: (json['ref_pitch'] ?? 0).toDouble(),
      refRoll: (json['ref_roll'] ?? 0).toDouble(),
      deviation: (json['deviation'] ?? 0).toDouble(),
      totalAlerts: (json['total_alerts'] ?? 0) as int,
      badPostureTime: (json['bad_posture_s'] ?? 0) as int,
      sessionDuration: (json['session_s'] ?? 0) as int,
      isCalibrated: json['is_calibrated'] ?? false,
      language: (json['language'] ?? 0) as int,
      silentMode: json['silent_mode'] ?? false,
      wifiConnected: json['wifi_connected'] ?? false,
      rssi: (json['rssi'] ?? 0) as int,
    );
  }

  static PostureState _parseState(String s) {
    switch (s.toLowerCase()) {
      case 'good':
        return PostureState.good;
      case 'warning':
        return PostureState.warning;
      case 'bad':
        return PostureState.bad;
      case 'critical':
        return PostureState.critical;
      default:
        return PostureState.unknown;
    }
  }

  // Label traduit selon la langue courante du contexte
  String localizedLabel(BuildContext context) {
    try {
      final loc = Localizations.of(context, _LocalizationHelper);
      if (loc != null) return loc.stateLabel(state);
    } catch (_) {}
    return _defaultLabel;
  }

  // Fallback sans contexte (utilisé par le chatbot)
  String get _defaultLabel {
    switch (state) {
      case PostureState.good:
        return 'Bonne posture';
      case PostureState.warning:
        return 'Avertissement';
      case PostureState.bad:
        return 'Mauvaise posture';
      case PostureState.critical:
        return 'Posture critique';
      default:
        return 'Inconnu';
    }
  }

  // Fallback pour le chatbot (sans contexte)
  String get localizedLabelFallback => _defaultLabel;

  Color get color {
    switch (state) {
      case PostureState.good:
        return const Color(0xFF00D4AA);
      case PostureState.warning:
        return const Color(0xFFFFB400);
      case PostureState.bad:
        return const Color(0xFFFF6B6B);
      case PostureState.critical:
        return const Color(0xFFFF3B3B);
      default:
        return const Color(0xFF8892B0);
    }
  }

  String get emoji {
    switch (state) {
      case PostureState.good:
        return '✅';
      case PostureState.warning:
        return '⚠️';
      case PostureState.bad:
        return '❌';
      case PostureState.critical:
        return '🚨';
      default:
        return '❓';
    }
  }

  double get goodPostureRatio {
    if (sessionDuration == 0) return 1.0;
    return 1.0 - (badPostureTime / sessionDuration);
  }
}

// Helper interne (non utilisé directement)
class _LocalizationHelper {
  String stateLabel(PostureState s) => '';
}
