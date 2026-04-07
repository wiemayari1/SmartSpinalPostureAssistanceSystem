import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(PostureApp());
}

class PostureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posture Intelligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: MainScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN avec BottomNavigationBar
// ─────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    PostureScreen(),
    ExercisesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.accessibility_new_outlined), selectedIcon: Icon(Icons.accessibility_new), label: 'Posture'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Exercices'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _angle = 5.0;
  String _status = 'Bonne posture';
  Color _statusColor = Colors.green;
  int _sessionMinutes = 0;
  int _alerts = 0;
  Timer? _timer;
  Timer? _angleTimer;

  @override
  void initState() {
    super.initState();
    // Simuler données ESP32
    _timer = Timer.periodic(Duration(seconds: 60), (_) {
      setState(() => _sessionMinutes++);
    });
    _angleTimer = Timer.periodic(Duration(seconds: 3), (_) {
      setState(() {
        _angle = 5 + Random().nextDouble() * 35;
        if (_angle < 15) {
          _status = 'Bonne posture';
          _statusColor = Colors.green;
        } else if (_angle < 25) {
          _status = 'Posture acceptable';
          _statusColor = Colors.orange;
        } else {
          _status = 'Mauvaise posture !';
          _statusColor = Colors.red;
          _alerts++;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _angleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour 👋', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      Text('Tableau de bord', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(icon: Icon(Icons.notifications_outlined, size: 28), onPressed: () {}),
                      if (_alerts > 0)
                        Positioned(right: 8, top: 8,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Center(child: Text('$_alerts', style: TextStyle(color: Colors.white, fontSize: 10))),
                          )),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Status Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Color(0xFF1565C0).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Text('État actuel', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(_status, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('Angle : ${_angle.toStringAsFixed(1)}°', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _angle / 40,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation(_statusColor),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(height(20),

              // Stats Row
              Row(
                children: [
                  _StatCard(icon: Icons.timer, label: 'Session', value: '${_sessionMinutes}min', color: Colors.blue),
                  SizedBox(width: 12),
                  _StatCard(icon: Icons.warning_amber, label: 'Alertes', value: '$_alerts', color: Colors.orange),
                  SizedBox(width: 12),
                  _StatCard(icon: Icons.bluetooth, label: 'ESP32', value: 'Connecté', color: Colors.green),
                ],
              ),
              SizedBox(height: 20),

              // Quick actions
              Text('Actions rapides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                children: [
                  _ActionCard(icon: Icons.pause_circle_outline, label: 'Pause', color: Colors.purple, onTap: () {}),
                  SizedBox(width: 12),
                  _ActionCard(icon: Icons.self_improvement, label: 'Exercice', color: Colors.teal, onTap: () {}),
                  SizedBox(width: 12),
                  _ActionCard(icon: Icons.history, label: 'Historique', color: Colors.indigo, onTap: () {}),
                ],
              ),
              SizedBox(height: 20),

              // Conseil du jour
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.green, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conseil du jour', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                          SizedBox(height: 4),
                          Text('Faites une pause toutes les 30 minutes. Levez-vous et marchez 2 minutes pour reposer votre dos.',
                              style: TextStyle(fontSize: 13, color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// POSTURE SCREEN — Visualisation temps réel
// ─────────────────────────────────────────────
class PostureScreen extends StatefulWidget {
  @override
  _PostureScreenState createState() => _PostureScreenState();
}

class _PostureScreenState extends State<PostureScreen> with SingleTickerProviderStateMixin {
  double _angle = 8.0;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(_controller);
    _timer = Timer.periodic(Duration(seconds: 2), (_) {
      setState(() => _angle = 5 + Random().nextDouble() * 30);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _postureColor {
    if (_angle < 15) return Colors.green;
    if (_angle < 25) return Colors.orange;
    return Colors.red;
  }

  String get _postureLabel {
    if (_angle < 15) return 'Excellente posture ✅';
    if (_angle < 25) return 'Posture à corriger ⚠️';
    return 'Mauvaise posture ❌';
  }

  String get _postureAdvice {
    if (_angle < 15) return 'Continuez ainsi ! Votre dos est bien droit.';
    if (_angle < 25) return 'Redressez légèrement le dos et rentrez le menton.';
    return 'Attention ! Corrigez immédiatement votre posture pour éviter les douleurs.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FF),
      appBar: AppBar(title: Text('Posture en temps réel'), backgroundColor: Color(0xFF1565C0), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Silhouette posturale animée
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(scale: _animation.value, child: child);
              },
              child: Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: CustomPaint(
                  painter: PosturePainter(_angle),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 240),
                      child: Text('Angle : ${_angle.toStringAsFixed(1)}°',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _postureColor)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Status
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _postureColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _postureColor),
              ),
              child: Column(
                children: [
                  Text(_postureLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _postureColor)),
                  SizedBox(height: 8),
                  Text(_postureAdvice, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Jauge
            Text('Niveau d\'inclinaison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_angle / 40).clamp(0.0, 1.0),
                minHeight: 20,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_postureColor),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0°', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text('15°', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text('25°+', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),

            // Langue alerte vocale
            Text('Langue alerte vocale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LangButton(flag: '🇫🇷', lang: 'Français'),
                _LangButton(flag: '🇸🇦', lang: 'العربية'),
                _LangButton(flag: '🇬🇧', lang: 'English'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EXERCISES SCREEN
// ─────────────────────────────────────────────
class ExercisesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exercises = [
    {'title': 'Étirement cervical', 'duration': '2 min', 'icon': Icons.self_improvement, 'color': Colors.teal, 'desc': 'Inclinez doucement la tête à droite, puis à gauche. Maintenez 10 secondes de chaque côté.'},
    {'title': 'Rotation des épaules', 'duration': '1 min', 'icon': Icons.rotate_right, 'color': Colors.blue, 'desc': 'Faites des cercles avec vos épaules, 10 fois en avant et 10 fois en arrière.'},
    {'title': 'Respiration profonde', 'duration': '3 min', 'icon': Icons.air, 'color': Colors.green, 'desc': 'Inspirez par le nez pendant 4 secondes, retenez 4 secondes, expirez par la bouche 4 secondes.'},
    {'title': 'Étirement du dos', 'duration': '2 min', 'icon': Icons.accessibility, 'color': Colors.purple, 'desc': 'Assis, penchez-vous en avant, bras tendus vers le sol. Maintenez 15 secondes.'},
    {'title': 'Gainage abdominal', 'duration': '1 min', 'icon': Icons.fitness_center, 'color': Colors.orange, 'desc': 'Contractez les abdominaux en position assise pendant 10 secondes, relâchez, répétez 10 fois.'},
    {'title': 'Marche active', 'duration': '5 min', 'icon': Icons.directions_walk, 'color': Colors.indigo, 'desc': 'Levez-vous et marchez dans la pièce, en gardant le dos droit et les épaules relâchées.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FF),
      appBar: AppBar(title: Text('Micro-exercices'), backgroundColor: Color(0xFF1565C0), foregroundColor: Colors.white),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: (ex['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(ex['icon'] as IconData, color: ex['color'] as Color, size: 28),
              ),
              title: Text(ex['title'] as String, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(ex['desc'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.timer_outlined, size: 14, color: ex['color'] as Color),
                    SizedBox(width: 4),
                    Text(ex['duration'] as String, style: TextStyle(color: ex['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ]),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _startExercise(context, ex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ex['color'] as Color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text('Démarrer', style: TextStyle(fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startExercise(BuildContext context, Map<String, dynamic> ex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(ex['title'] as String, style: TextStyle(color: ex['color'] as Color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ex['icon'] as IconData, size: 60, color: ex['color'] as Color),
            SizedBox(height: 16),
            Text(ex['desc'] as String, textAlign: TextAlign.center),
            SizedBox(height: 12),
            Chip(label: Text('Durée : ${ex['duration']}'), backgroundColor: (ex['color'] as Color).withOpacity(0.1)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: ex['color'] as Color, foregroundColor: Colors.white),
            child: Text('Commencer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE SCREEN
// ─────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FF),
      appBar: AppBar(title: Text('Mon Profil'), backgroundColor: Color(0xFF1565C0), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1565C0),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text('Utilisateur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Projet ESP32 — 1ING03', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 24),

            // Stats personnelles
            Row(
              children: [
                _ProfileStat(label: 'Jours actifs', value: '12'),
                _ProfileStat(label: 'Sessions', value: '34'),
                _ProfileStat(label: 'Score', value: '87%'),
              ],
            ),
            SizedBox(height: 24),

            // Paramètres
            _SettingsTile(icon: Icons.language, title: 'Langue alerte vocale', subtitle: 'Français', color: Colors.blue),
            _SettingsTile(icon: Icons.timer, title: 'Rappel de pause', subtitle: 'Toutes les 30 min', color: Colors.orange),
            _SettingsTile(icon: Icons.bluetooth, title: 'Connexion ESP32', subtitle: 'PostureBelt_001', color: Colors.teal),
            _SettingsTile(icon: Icons.notifications, title: 'Notifications', subtitle: 'Activées', color: Colors.purple),
            _SettingsTile(icon: Icons.bar_chart, title: 'Historique & rapports', subtitle: 'Voir les données', color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS RÉUTILISABLES
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)]),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ]),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

class _LangButton extends StatefulWidget {
  final String flag, lang;
  const _LangButton({required this.flag, required this.lang});
  @override
  _LangButtonState createState() => _LangButtonState();
}

class _LangButtonState extends State<_LangButton> {
  bool _selected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _selected ? Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF1565C0)),
        ),
        child: Column(children: [
          Text(widget.flag, style: TextStyle(fontSize: 24)),
          SizedBox(height: 4),
          Text(widget.lang, style: TextStyle(fontSize: 12, color: _selected ? Colors.white : Color(0xFF1565C0), fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 8)]),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black08, blurRadius: 6)]),
      child: ListTile(
        leading: Container(width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM PAINTER — Silhouette posturale
// ─────────────────────────────────────────────
class PosturePainter extends CustomPainter {
  final double angle;
  PosturePainter(this.angle);

  Color get _color {
    if (angle < 15) return Colors.green;
    if (angle < 25) return Colors.orange;
    return Colors.red;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _color..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fill = Paint()..color = _color.withOpacity(0.15)..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final rad = angle * pi / 180;

    // Tête
    canvas.drawCircle(Offset(cx, 50), 22, fill);
    canvas.drawCircle(Offset(cx, 50), 22, paint);

    // Colonne vertébrale inclinée
    final spineEnd = Offset(cx + sin(rad) * 120, 80 + cos(rad) * 120);
    canvas.drawLine(Offset(cx, 80), spineEnd, paint);

    // Épaules
    canvas.drawLine(Offset(cx - 40, 90), Offset(cx + 40, 90), paint);

    // Bras
    canvas.drawLine(Offset(cx - 40, 90), Offset(cx - 55, 160), paint);
    canvas.drawLine(Offset(cx + 40, 90), Offset(cx + 55, 160), paint);

    // Bassin
    canvas.drawLine(spineEnd, Offset(spineEnd.dx - 30, spineEnd.dy + 10), paint);
    canvas.drawLine(spineEnd, Offset(spineEnd.dx + 30, spineEnd.dy + 10), paint);

    // Jambes
    canvas.drawLine(Offset(spineEnd.dx - 30, spineEnd.dy + 10), Offset(spineEnd.dx - 25, spineEnd.dy + 70), paint);
    canvas.drawLine(Offset(spineEnd.dx + 30, spineEnd.dy + 10), Offset(spineEnd.dx + 25, spineEnd.dy + 70), paint);

    // Indicateur d'angle
    final textPainter = TextPainter(
      text: TextSpan(text: angle < 15 ? '✓' : '!', style: TextStyle(color: _color, fontSize: 28, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(cx + 60, 40));
  }

  @override
  bool shouldRepaint(PosturePainter old) => old.angle != angle;
}
