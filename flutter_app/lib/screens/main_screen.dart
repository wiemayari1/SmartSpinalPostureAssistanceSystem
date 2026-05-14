import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chatbot_provider.dart';
import '../utils/app_localizations.dart';
import 'dashboard_screen.dart';
import 'chatbot_screen.dart';
import 'exercises_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  static const int _chatbotIndex = 1;

  static const _screens = [
    DashboardScreen(),
    ChatbotScreen(),
    ExercisesScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onTabTap(int newIndex) {
    if (_index == _chatbotIndex && newIndex != _chatbotIndex) {
      context.read<ChatbotProvider>().stopTts();
    }
    setState(() => _index = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: const Color(0xFF1F2944).withValues(alpha: 0.8),
                  width: 1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF16213E),
          selectedItemColor: const Color(0xFF00D4AA),
          unselectedItemColor: const Color(0xFF8892B0),
          currentIndex: _index,
          onTap: _onTabTap,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: loc.dashboard),
            BottomNavigationBarItem(
                icon: const Icon(Icons.psychology_alt_outlined),
                activeIcon: const Icon(Icons.psychology_alt),
                label: loc.chatbot),
            BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center_outlined),
                activeIcon: const Icon(Icons.fitness_center),
                label: loc.exercises),
            BottomNavigationBarItem(
                icon: const Icon(Icons.show_chart_outlined),
                activeIcon: const Icon(Icons.show_chart),
                label: loc.history),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: loc.settings),
          ],
        ),
      ),
    );
  }
}
