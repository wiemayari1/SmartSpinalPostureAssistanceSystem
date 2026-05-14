import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

enum ExerciseAnimation {
  shoulderRoll,
  neckTilt,
  catCow,
  breathing,
  walking,
  eyeRule,
  squat,
  plank,
}

class ExerciseData {
  final IconData icon;
  final Color color;
  final String duration;
  final int durationSeconds;
  final ExerciseAnimation animation;
  final String Function(AppLocalizations) getTitle;
  final String Function(AppLocalizations) getCategory;
  final String Function(AppLocalizations) getDesc;
  final List<String> Function(AppLocalizations) getSteps;
  final List<String> Function(AppLocalizations) getBenefits;

  const ExerciseData({
    required this.icon,
    required this.color,
    required this.duration,
    required this.durationSeconds,
    required this.animation,
    required this.getTitle,
    required this.getCategory,
    required this.getDesc,
    required this.getSteps,
    required this.getBenefits,
  });
}

final List<ExerciseData> exerciseList = [
  ExerciseData(
    icon: Icons.rotate_right_rounded,
    color: const Color(0xFF00D4AA),
    duration: '30s',
    durationSeconds: 30,
    animation: ExerciseAnimation.shoulderRoll,
    getTitle: (l) => l.ex1Title,
    getCategory: (l) => l.catStretching,
    getDesc: (l) => l.ex1Desc,
    getSteps: (l) => l.ex1Steps,
    getBenefits: (l) => l.ex1Benefits,
  ),
  ExerciseData(
    icon: Icons.swap_horiz_rounded,
    color: const Color(0xFF4FC3F7),
    duration: '20s',
    durationSeconds: 20,
    animation: ExerciseAnimation.neckTilt,
    getTitle: (l) => l.ex2Title,
    getCategory: (l) => l.catStretching,
    getDesc: (l) => l.ex2Desc,
    getSteps: (l) => l.ex2Steps,
    getBenefits: (l) => l.ex2Benefits,
  ),
  ExerciseData(
    icon: Icons.self_improvement_rounded,
    color: const Color(0xFF00D4AA),
    duration: '45s',
    durationSeconds: 45,
    animation: ExerciseAnimation.catCow,
    getTitle: (l) => l.ex3Title,
    getCategory: (l) => l.catStretching,
    getDesc: (l) => l.ex3Desc,
    getSteps: (l) => l.ex3Steps,
    getBenefits: (l) => l.ex3Benefits,
  ),
  ExerciseData(
    icon: Icons.air_rounded,
    color: const Color(0xFF4FC3F7),
    duration: '1 min',
    durationSeconds: 60,
    animation: ExerciseAnimation.breathing,
    getTitle: (l) => l.ex4Title,
    getCategory: (l) => l.catBreathing,
    getDesc: (l) => l.ex4Desc,
    getSteps: (l) => l.ex4Steps,
    getBenefits: (l) => l.ex4Benefits,
  ),
  ExerciseData(
    icon: Icons.directions_walk_rounded,
    color: const Color(0xFFFFB400),
    duration: '2 min',
    durationSeconds: 120,
    animation: ExerciseAnimation.walking,
    getTitle: (l) => l.ex5Title,
    getCategory: (l) => l.catCardio,
    getDesc: (l) => l.ex5Desc,
    getSteps: (l) => l.ex5Steps,
    getBenefits: (l) => l.ex5Benefits,
  ),
  ExerciseData(
    icon: Icons.remove_red_eye_rounded,
    color: const Color(0xFFFFB400),
    duration: '20s',
    durationSeconds: 20,
    animation: ExerciseAnimation.eyeRule,
    getTitle: (l) => l.ex6Title,
    getCategory: (l) => l.catEye,
    getDesc: (l) => l.ex6Desc,
    getSteps: (l) => l.ex6Steps,
    getBenefits: (l) => l.ex6Benefits,
  ),
  ExerciseData(
    icon: Icons.airline_seat_legroom_normal_rounded,
    color: const Color(0xFFFF6B6B),
    duration: '1 min',
    durationSeconds: 60,
    animation: ExerciseAnimation.squat,
    getTitle: (l) => l.ex7Title,
    getCategory: (l) => l.catStrength,
    getDesc: (l) => l.ex7Desc,
    getSteps: (l) => l.ex7Steps,
    getBenefits: (l) => l.ex7Benefits,
  ),
  ExerciseData(
    icon: Icons.fitness_center_rounded,
    color: const Color(0xFFFF6B6B),
    duration: '30s',
    durationSeconds: 30,
    animation: ExerciseAnimation.plank,
    getTitle: (l) => l.ex8Title,
    getCategory: (l) => l.catStrength,
    getDesc: (l) => l.ex8Desc,
    getSteps: (l) => l.ex8Steps,
    getBenefits: (l) => l.ex8Benefits,
  ),
];

// ============================================================
// Liste des exercices groupée par catégorie
// ============================================================
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final Map<String, List<ExerciseData>> grouped = {};
    for (final ex in exerciseList) {
      grouped.putIfAbsent(ex.getCategory(loc), () => []).add(ex);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.exercises),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
                child: Text(
              loc.exCount(exerciseList.length),
              style: const TextStyle(fontSize: 12, color: Color(0xFF8892B0)),
            )),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries
            .map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 4),
                      child: Text(entry.key.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8892B0),
                              letterSpacing: 1.2)),
                    ),
                    ...entry.value.map((ex) => _ExerciseCard(ex: ex, loc: loc)),
                    const SizedBox(height: 8),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseData ex;
  final AppLocalizations loc;
  const _ExerciseCard({required this.ex, required this.loc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => _DetailScreen(ex: ex))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ex.color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ex.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(ex.icon, color: ex.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ex.getTitle(loc),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(ex.getDesc(loc),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF8892B0))),
              const SizedBox(height: 8),
              Row(children: [
                _Badge(
                    Icons.timer_outlined, ex.duration, const Color(0xFF8892B0)),
                const SizedBox(width: 8),
                _Badge(Icons.local_fire_department_rounded, ex.getCategory(loc),
                    ex.color),
              ]),
            ],
          )),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ex.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded, color: ex.color, size: 18),
          ),
        ]),
      ),
    );
  }
}

// ============================================================
// Page détaillée
// ============================================================
class _DetailScreen extends StatefulWidget {
  final ExerciseData ex;
  const _DetailScreen({required this.ex});
  @override
  State<_DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<_DetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _anim;
  Timer? _clock;
  int _left = 0;
  bool _running = false, _done = false;

  @override
  void initState() {
    super.initState();
    _left = widget.ex.durationSeconds;
    _anim =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    _clock?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _done = false;
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_left > 0) {
          _left--;
        } else {
          _running = false;
          _done = true;
          t.cancel();
        }
      });
    });
  }

  void _reset() {
    _clock?.cancel();
    setState(() {
      _left = widget.ex.durationSeconds;
      _running = false;
      _done = false;
    });
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return m > 0 ? '$m:${sec.toString().padLeft(2, '0')}' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final ex = widget.ex;
    final progress = 1.0 - (_left / ex.durationSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(ex.getTitle(loc)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Illustration SVG animée
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ex.color.withValues(alpha: 0.25)),
            ),
            child: Stack(children: [
              Center(
                  child: Icon(ex.icon,
                      size: 80, color: ex.color.withValues(alpha: 0.06))),
              Center(
                  child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  size: const Size(180, 180),
                  painter: _Painter(
                      anim: ex.animation, color: ex.color, t: _anim.value),
                ),
              )),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ex.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ex.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(ex.icon, color: ex.color, size: 12),
                    const SizedBox(width: 4),
                    Text(ex.getCategory(loc),
                        style: TextStyle(
                            color: ex.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Timer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor:
                        AlwaysStoppedAnimation(_done ? Colors.green : ex.color),
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_done ? Icons.check_circle_rounded : Icons.timer_rounded,
                      color: _done ? Colors.green : ex.color, size: 24),
                  const SizedBox(height: 4),
                  Text(_done ? loc.exDone : _fmt(_left),
                      style: TextStyle(
                          fontSize: _done ? 20 : 30,
                          fontWeight: FontWeight.bold,
                          color: _done ? Colors.green : Colors.white)),
                  if (!_done)
                    Text(ex.duration,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF8892B0))),
                ]),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (!_running && !_done)
                  _ActionBtn(
                      Icons.play_arrow_rounded, loc.exStart, ex.color, _start),
                if (_running)
                  _ActionBtn(
                      Icons.stop_rounded, loc.exStop, Colors.red, _reset),
                if (_done)
                  _ActionBtn(
                      Icons.replay_rounded, loc.exRestart, ex.color, _reset),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // Stats rapides
          Row(children: [
            Expanded(
                child: _StatBox(Icons.timer_rounded, ex.duration,
                    loc.exDuration, ex.color)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatBox(Icons.repeat_rounded,
                    '${ex.getSteps(loc).length}', loc.exSteps, ex.color)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatBox(Icons.local_fire_department_rounded,
                    ex.getCategory(loc), loc.exType, ex.color)),
          ]),
          const SizedBox(height: 12),

          // Description
          _Section(
              Icons.info_outline_rounded,
              loc.exDescription,
              ex.color,
              Text(ex.getDesc(loc),
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFFCCD6F6), height: 1.6))),
          const SizedBox(height: 10),

          // Étapes
          _Section(
            Icons.format_list_numbered_rounded,
            loc.exHowTo,
            ex.color,
            Column(
                children: ex
                    .getSteps(loc)
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: ex.color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle),
                                child: Text('${e.key + 1}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: ex.color)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(e.value,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFCCD6F6),
                                        height: 1.4)),
                              )),
                            ]),
                      ),
                    )
                    .toList()),
          ),
          const SizedBox(height: 10),

          // Bénéfices
          _Section(
            Icons.verified_rounded,
            loc.exBenefits,
            ex.color,
            Column(
                children: ex
                    .getBenefits(loc)
                    .map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Icon(Icons.check_circle_rounded,
                              color: ex.color, size: 18),
                          const SizedBox(width: 10),
                          Text(b,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFCCD6F6))),
                        ]),
                      ),
                    )
                    .toList()),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ============================================================
// Peintre SVG
// ============================================================
class _Painter extends CustomPainter {
  final ExerciseAnimation anim;
  final Color color;
  final double t;
  _Painter({required this.anim, required this.color, required this.t});

  Paint get _p => Paint()
    ..color = color
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  Paint get _f => Paint()
    ..color = color.withValues(alpha: 0.2)
    ..style = PaintingStyle.fill;

  void _head(Canvas c, double x, double y, [double r = 14]) {
    c.drawCircle(Offset(x, y), r, _f);
    c.drawCircle(Offset(x, y), r, _p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    switch (anim) {
      case ExerciseAnimation.shoulderRoll:
        _shoulder(canvas, cx, cy);
        break;
      case ExerciseAnimation.neckTilt:
        _neck(canvas, cx, cy);
        break;
      case ExerciseAnimation.catCow:
        _cat(canvas, cx, cy);
        break;
      case ExerciseAnimation.breathing:
        _breath(canvas, cx, cy);
        break;
      case ExerciseAnimation.walking:
        _walk(canvas, cx, cy);
        break;
      case ExerciseAnimation.eyeRule:
        _eye(canvas, cx, cy);
        break;
      case ExerciseAnimation.squat:
        _squat(canvas, cx, cy);
        break;
      case ExerciseAnimation.plank:
        _plank(canvas, cx, cy);
        break;
    }
  }

  void _shoulder(Canvas c, double cx, double cy) {
    _head(c, cx, cy - 55);
    c.drawLine(Offset(cx, cy - 41), Offset(cx, cy + 10), _p);
    final a = t * 2 * pi;
    c.drawLine(Offset(cx, cy - 22),
        Offset(cx - 30 + cos(a + pi) * 8, cy - 22 + sin(a + pi) * 8), _p);
    c.drawLine(Offset(cx, cy - 22),
        Offset(cx + 30 + cos(a) * 8, cy - 22 + sin(a) * 8), _p);
    c.drawLine(Offset(cx, cy + 10), Offset(cx - 15, cy + 42), _p);
    c.drawLine(Offset(cx, cy + 10), Offset(cx + 15, cy + 42), _p);
    c.drawArc(
        Rect.fromCenter(center: Offset(cx, cy - 22), width: 68, height: 28),
        -pi / 2,
        pi * 1.5,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
  }

  void _neck(Canvas c, double cx, double cy) {
    final tilt = (t - 0.5) * 30 * pi / 180;
    c.save();
    c.translate(cx, cy - 40);
    c.rotate(tilt);
    _head(c, 0, -20);
    c.restore();
    c.drawLine(Offset(cx, cy - 39), Offset(cx, cy - 20), _p);
    c.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 15), _p);
    c.drawLine(Offset(cx - 28, cy - 15), Offset(cx + 28, cy - 15), _p);
    c.drawLine(Offset(cx, cy + 15), Offset(cx - 14, cy + 45), _p);
    c.drawLine(Offset(cx, cy + 15), Offset(cx + 14, cy + 45), _p);
  }

  void _cat(Canvas c, double cx, double cy) {
    final bend = (t - 0.5) * 28;
    final path = Path()..moveTo(cx - 50, cy);
    path.cubicTo(cx - 25, cy + bend, cx + 25, cy + bend, cx + 50, cy);
    c.drawPath(path, _p);
    _head(c, cx - 56, cy - 4, 12);
    c.drawLine(Offset(cx + 50, cy), Offset(cx + 65, cy - 14), _p);
    for (final x in [-30.0, -10.0, 10.0, 30.0]) {
      c.drawLine(Offset(cx + x, cy), Offset(cx + x, cy + 30), _p);
    }
    c.drawLine(
        Offset(cx - 70, cy + 30),
        Offset(cx + 70, cy + 30),
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 2);
  }

  void _breath(Canvas c, double cx, double cy) {
    final r = 28 + t * 28;
    c.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill);
    c.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke);
    c.drawCircle(
        Offset(cx, cy),
        18,
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill);
    for (int i = 1; i <= 3; i++) {
      c.drawCircle(
          Offset(cx, cy),
          r + i * 11,
          Paint()
            ..color = color.withValues(alpha: max(0, 0.07 - i * 0.02))
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }
  }

  void _walk(Canvas c, double cx, double cy) {
    _head(c, cx, cy - 56, 13);
    c.drawLine(Offset(cx, cy - 43), Offset(cx, cy - 5), _p);
    final s = (t - 0.5) * 38 * pi / 180;
    c.drawLine(Offset(cx, cy - 28),
        Offset(cx - 18 + cos(s) * 5, cy - 10 + sin(s) * 10), _p);
    c.drawLine(Offset(cx, cy - 28),
        Offset(cx + 18 - cos(s) * 5, cy - 10 - sin(s) * 10), _p);
    c.drawLine(Offset(cx, cy - 5), Offset(cx - 14 + sin(s) * 16, cy + 22), _p);
    c.drawLine(Offset(cx - 14 + sin(s) * 16, cy + 22),
        Offset(cx - 20 + sin(s) * 22, cy + 44), _p);
    c.drawLine(Offset(cx, cy - 5), Offset(cx + 14 - sin(s) * 16, cy + 22), _p);
    c.drawLine(Offset(cx + 14 - sin(s) * 16, cy + 22),
        Offset(cx + 20 - sin(s) * 22, cy + 44), _p);
    c.drawLine(
        Offset(cx - 60, cy + 44),
        Offset(cx + 60, cy + 44),
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = 2);
  }

  void _eye(Canvas c, double cx, double cy) {
    final blink = t < 0.08 || t > 0.92;
    final h = blink ? 2.0 : 16.0;
    for (final ox in [-28.0, 28.0]) {
      c.drawOval(
          Rect.fromCenter(center: Offset(cx + ox, cy), width: 36, height: h),
          Paint()
            ..color = color.withValues(alpha: 0.25)
            ..style = PaintingStyle.fill);
      c.drawOval(
          Rect.fromCenter(center: Offset(cx + ox, cy), width: 36, height: h),
          _p);
      if (!blink)
        c.drawCircle(
            Offset(cx + ox, cy),
            6,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
    }
  }

  void _squat(Canvas c, double cx, double cy) {
    final d = t * 32;
    final ty = cy - 18 + d;
    _head(c, cx, ty - 50, 13);
    c.drawLine(Offset(cx, ty - 37), Offset(cx, ty), _p);
    c.drawLine(Offset(cx - 22, ty - 28), Offset(cx + 22, ty - 28), _p);
    c.drawLine(Offset(cx - 22, ty - 28), Offset(cx - 36, ty - 10), _p);
    c.drawLine(Offset(cx + 22, ty - 28), Offset(cx + 36, ty - 10), _p);
    c.drawLine(Offset(cx, ty), Offset(cx - 20, ty + 20 - d * 0.4), _p);
    c.drawLine(Offset(cx, ty), Offset(cx + 20, ty + 20 - d * 0.4), _p);
    c.drawLine(
        Offset(cx - 20, ty + 20 - d * 0.4), Offset(cx - 18, cy + 40), _p);
    c.drawLine(
        Offset(cx + 20, ty + 20 - d * 0.4), Offset(cx + 18, cy + 40), _p);
    final ch = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    c.drawLine(Offset(cx - 30, cy + 40), Offset(cx + 30, cy + 40), ch);
    c.drawLine(Offset(cx - 30, cy + 40), Offset(cx - 30, cy + 58), ch);
    c.drawLine(Offset(cx + 30, cy + 40), Offset(cx + 30, cy + 58), ch);
  }

  void _plank(Canvas c, double cx, double cy) {
    final sag = sin(t * pi) * 7;
    final path = Path()..moveTo(cx - 65, cy);
    path.cubicTo(cx - 30, cy + sag, cx + 30, cy + sag, cx + 65, cy);
    c.drawPath(path, _p);
    _head(c, cx - 72, cy - 3, 11);
    c.drawLine(Offset(cx - 45, cy), Offset(cx - 45, cy + 26), _p);
    c.drawLine(Offset(cx - 20, cy), Offset(cx - 20, cy + 26), _p);
    c.drawLine(
        Offset(cx - 55, cy + 26),
        Offset(cx - 8, cy + 26),
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);
    c.drawLine(Offset(cx + 58, cy), Offset(cx + 58, cy + 22), _p);
    c.drawLine(
        Offset(cx + 68, cy + 22),
        Offset(cx + 48, cy + 22),
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round);
    c.drawLine(
        Offset(cx - 80, cy + 26),
        Offset(cx + 80, cy + 26),
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_Painter old) => old.t != t;
}

// ============================================================
// Widgets utilitaires
// ============================================================
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatBox(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8892B0))),
        ]),
      );
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _Section(this.icon, this.title, this.color, this.child);
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      );
}
