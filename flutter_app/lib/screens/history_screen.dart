import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posture_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  List<FlSpot> _toSpots(List<double> v) =>
      List.generate(v.length, (i) => FlSpot(i.toDouble(), v[i]));

  String _fmt(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final c   = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.history)),
      body: Consumer<PostureProvider>(builder: (_, p, __) {
        if (p.pitchHistory.isEmpty) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Icons.show_chart, size: 60, color: c.textMuted),
                const SizedBox(height: 14),
                Text(loc.noDataYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textMuted)),
              ]));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _ChartCard(loc.pitchChart, _toSpots(p.pitchHistory),
                c.primary, c),
            const SizedBox(height: 14),
            _ChartCard(loc.rollChart, _toSpots(p.rollHistory),
                const Color(0xFFFFB400), c),
            const SizedBox(height: 14),
            if (p.currentData != null)
              _SummaryCard(p: p, fmt: _fmt, loc: loc, c: c),
          ]),
        );
      }),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final Color color;
  final AppColors c;
  const _ChartCard(this.title, this.spots, this.color, this.c);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: c.card, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary)),
          const SizedBox(height: 14),
          SizedBox(
              height: 160,
              child: LineChart(LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (_) => FlLine(
                        color: c.border, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: -90,
                maxY: 90,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: color.withValues(alpha: 0.12)),
                  )
                ],
              ))),
        ]),
      );
}

class _SummaryCard extends StatelessWidget {
  final PostureProvider p;
  final String Function(int) fmt;
  final AppLocalizations loc;
  final AppColors c;
  const _SummaryCard(
      {required this.p, required this.fmt, required this.loc, required this.c});

  @override
  Widget build(BuildContext context) {
    final d = p.currentData!;
    final ratio = (d.goodPostureRatio * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c.primary, c.primaryDark]),
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.sessionSummary,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        _line(loc.goodPosture, '$ratio%'),
        _line(loc.totalDuration, fmt(d.sessionDuration)),
        _line(loc.badPostureTime, fmt(d.badPostureTime)),
        _line(loc.totalAlerts, '${d.totalAlerts}'),
      ]),
    );
  }

  Widget _line(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ]),
      );
}
