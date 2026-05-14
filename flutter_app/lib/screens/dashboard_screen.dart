import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posture_provider.dart';
import '../providers/chatbot_provider.dart';
import '../models/posture_data.dart';
import '../utils/app_localizations.dart';
import '../utils/app_colors.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PostureState? _lastAnnouncedState;

  String _fmt(int s, AppLocalizations loc) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final c = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.card,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: LinearGradient(colors: [c.primary, c.primaryDark]),
              boxShadow: [
                BoxShadow(
                    color: c.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.accessibility_new_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(loc.dashboard,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: c.textPrimary)),
        ]),
        actions: [
          Consumer<PostureProvider>(
              builder: (_, p, __) => Container(
                    margin: const EdgeInsets.only(right: 14),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (p.isConnected ? c.primary : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: (p.isConnected ? c.primary : Colors.red)
                              .withValues(alpha: 0.25)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.isConnected ? c.primary : Colors.red,
                              boxShadow: [
                                BoxShadow(
                                    color: (p.isConnected
                                            ? c.primary
                                            : Colors.red)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 4),
                              ])),
                      const SizedBox(width: 5),
                      Text(p.isConnected ? loc.connected : loc.disconnected,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.isConnected ? c.primary : Colors.red)),
                    ]),
                  )),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: c.primary.withValues(alpha: 0.12),
          ),
        ),
      ),
      body: Consumer2<PostureProvider, ChatbotProvider>(
        builder: (context, posture, chatbot, _) {
          final data = posture.currentData;
          if (data != null && data.state != _lastAnnouncedState) {
            _lastAnnouncedState = data.state;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              chatbot.announcePostureState(data.state);
            });
          }
          return RefreshIndicator(
            color: c.primary,
            backgroundColor: c.card,
            onRefresh: () => posture.fetchStatus(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (!posture.isConnected)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.25))),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child:
                            const Icon(Icons.wifi_off, color: Colors.red, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              '${loc.disconnected} (${posture.esp32Ip})\n'
                              '${loc.esp32NotConnected.split('\n').last}',
                              style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: c.textPrimary))),
                    ]),
                  ),
                data != null
                    ? PostureRing(data: data)
                    : _NoDataRing(loc: loc, c: c),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: AngleCard(
                          label: loc.pitch,
                          value: data?.pitch ?? 0,
                          icon: Icons.rotate_right)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: AngleCard(
                          label: loc.roll,
                          value: data?.roll ?? 0,
                          icon: Icons.rotate_left)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: StatsCard(
                          label: loc.sessionDuration,
                          value: _fmt(data?.sessionDuration ?? 0, loc),
                          icon: Icons.timer_outlined)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: StatsCard(
                          label: loc.totalAlerts,
                          value: '${data?.totalAlerts ?? 0}',
                          icon: Icons.notifications_outlined,
                          color: const Color(0xFFFFB400))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: StatsCard(
                          label: loc.badPostureTime,
                          value: _fmt(data?.badPostureTime ?? 0, loc),
                          icon: Icons.warning_outlined,
                          color: const Color(0xFFFF6B6B))),
                ]),
                const SizedBox(height: 12),
                if (data != null)
                  _PostureBar(
                      ratio: data.goodPostureRatio,
                      label: loc.goodPosture,
                      c: c),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))).copyWith(
                      overlayColor: WidgetStateProperty.all(
                          Colors.white.withValues(alpha: 0.1))),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(loc.calibrating),
                          backgroundColor: c.card,
                          duration: const Duration(seconds: 4)));
                      final ok = await posture.calibrate();
                      if (context.mounted) {
                        if (ok) chatbot.announce('calibration_done');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                ok ? loc.calibrationDone : loc.calibrationFail),
                            backgroundColor:
                                ok ? c.primary : Colors.red));
                      }
                    },
                    icon: const Icon(Icons.center_focus_strong_rounded),
                    label: Text(loc.recalibrate,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _NoDataRing extends StatelessWidget {
  final AppLocalizations loc;
  final AppColors c;
  const _NoDataRing({required this.loc, required this.c});
  @override
  Widget build(BuildContext context) => Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.card,
            border: Border.all(color: c.border, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2),
            ]),
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.textMuted.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded, size: 36, color: c.textMuted),
          ),
          const SizedBox(height: 10),
          Text(loc.waitingEsp32,
              style: TextStyle(
                  color: c.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ])),
      );
}

class _PostureBar extends StatelessWidget {
  final double ratio;
  final String label;
  final AppColors c;
  const _PostureBar({required this.ratio, required this.label, required this.c});
  @override
  Widget build(BuildContext context) {
    final pct = (ratio * 100).toStringAsFixed(0);
    final barColor = ratio > 0.7
        ? c.primary
        : ratio > 0.4
            ? const Color(0xFFFFB400)
            : const Color(0xFFFF6B6B);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: barColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: barColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textMuted)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$pct%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: barColor)),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation(barColor),
            )),
      ]),
    );
  }
}
