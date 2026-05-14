import 'package:flutter/material.dart';

/// Extension de thème personnalisée pour SpineGuard.
/// Accessible via : Theme.of(context).extension<AppColors>()!
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // ─── Fonds ───────────────────────────────────────────────────
  final Color scaffold;     // fond de l'app
  final Color card;         // fond des cartes
  final Color cardInner;    // fond des sous-cartes (champs, sections internes)

  // ─── Textes ──────────────────────────────────────────────────
  final Color textPrimary;  // texte principal
  final Color textMuted;    // texte secondaire / labels

  // ─── Bordures ────────────────────────────────────────────────
  final Color border;       // bordures subtiles

  // ─── Primaire (identique dans les deux modes) ────────────────
  final Color primary;
  final Color primaryDark;

  const AppColors({
    required this.scaffold,
    required this.card,
    required this.cardInner,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.primary,
    required this.primaryDark,
  });

  // ═══════════════════════════════════════════════════════════
  // Mode SOMBRE (existant)
  // ═══════════════════════════════════════════════════════════
  static const dark = AppColors(
    scaffold:     Color(0xFF1A1A2E),
    card:         Color(0xFF16213E),
    cardInner:    Color(0xFF1A1A2E),
    textPrimary:  Colors.white,
    textMuted:    Color(0xFF8892B0),
    border:       Color(0x0DFFFFFF),   // white 5%
    primary:      Color(0xFF00D4AA),
    primaryDark:  Color(0xFF00A884),
  );

  // ═══════════════════════════════════════════════════════════
  // Mode CLAIR
  // ═══════════════════════════════════════════════════════════
  static const light = AppColors(
    scaffold:     Color(0xFFF0F4F8),
    card:         Color(0xFFFFFFFF),
    cardInner:    Color(0xFFEEF2F7),
    textPrimary:  Color(0xFF0F172A),
    textMuted:    Color(0xFF64748B),
    border:       Color(0x1A000000),   // black 10%
    primary:      Color(0xFF00A884),   // légèrement plus foncé pour contraste
    primaryDark:  Color(0xFF008F70),
  );

  // ═══════════════════════════════════════════════════════════
  // ThemeExtension boilerplate
  // ═══════════════════════════════════════════════════════════
  @override
  AppColors copyWith({
    Color? scaffold,
    Color? card,
    Color? cardInner,
    Color? textPrimary,
    Color? textMuted,
    Color? border,
    Color? primary,
    Color? primaryDark,
  }) =>
      AppColors(
        scaffold:    scaffold    ?? this.scaffold,
        card:        card        ?? this.card,
        cardInner:   cardInner   ?? this.cardInner,
        textPrimary: textPrimary ?? this.textPrimary,
        textMuted:   textMuted   ?? this.textMuted,
        border:      border      ?? this.border,
        primary:     primary     ?? this.primary,
        primaryDark: primaryDark ?? this.primaryDark,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      scaffold:    Color.lerp(scaffold,    other.scaffold,    t)!,
      card:        Color.lerp(card,        other.card,        t)!,
      cardInner:   Color.lerp(cardInner,   other.cardInner,   t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted:   Color.lerp(textMuted,   other.textMuted,   t)!,
      border:      Color.lerp(border,      other.border,      t)!,
      primary:     Color.lerp(primary,     other.primary,     t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
    );
  }
}
