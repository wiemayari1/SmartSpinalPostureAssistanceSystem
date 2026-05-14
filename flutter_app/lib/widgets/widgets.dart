import 'package:flutter/material.dart';
import '../models/posture_data.dart';
import '../utils/app_localizations.dart';
import '../utils/app_colors.dart';

// ── PostureRing — sans emoji, icône SVG/Icons propre ────────────
class PostureRing extends StatelessWidget {
  final PostureData data;
  const PostureRing({super.key, required this.data});

  String _stateLabel(BuildContext context) {
    final loc = AppLocalizations.of(context);
    switch (data.state) {
      case PostureState.good:     return loc.stateGood;
      case PostureState.warning:  return loc.stateWarning;
      case PostureState.bad:      return loc.stateBad;
      case PostureState.critical: return loc.stateCritical;
      default:                    return loc.stateUnknown;
    }
  }

  IconData get _stateIcon {
    switch (data.state) {
      case PostureState.good:     return Icons.verified_rounded;
      case PostureState.warning:  return Icons.error_outline_rounded;
      case PostureState.bad:      return Icons.cancel_outlined;
      case PostureState.critical: return Icons.gpp_bad_rounded;
      default:                    return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final color = data.color;
    final progress = (data.deviation / 50.0).clamp(0.0, 1.0);
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.15), c.card]),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 32,
              spreadRadius: 4)
        ],
      ),
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 9,
            strokeCap: StrokeCap.round,
            backgroundColor: c.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          // Icône propre à la place de l'emoji
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(_stateIcon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(_stateLabel(context),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: color)),
          const SizedBox(height: 3),
          Text('${data.deviation.toStringAsFixed(1)}°',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: c.textMuted)),
        ]),
      ]),
    );
  }
}

// ── AngleCard — design épuré ───────────────────────────────────
class AngleCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  const AngleCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: c.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Text('${value.toStringAsFixed(1)}°',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: c.textPrimary)),
      ]),
    );
  }
}

// ── StatsCard — design cartes stats pro ───────────────────────
class StatsCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = const Color(0xFF00D4AA),
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: c.textPrimary)),
        const SizedBox(height: 2),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: c.textMuted)),
      ]),
    );
  }
}
