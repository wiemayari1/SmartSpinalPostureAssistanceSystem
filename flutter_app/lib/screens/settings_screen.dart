import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posture_provider.dart';
import '../providers/language_provider.dart';
import '../providers/chatbot_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ipCtrl = TextEditingController();
  String? _testResult;
  bool _testOk = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _ipCtrl.text = context.read<PostureProvider>().esp32Ip;
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc    = AppLocalizations.of(context);
    final p      = context.watch<PostureProvider>();
    final lang   = context.watch<LanguageProvider>();
    final chat   = context.watch<ChatbotProvider>();
    final theme  = context.watch<ThemeProvider>();
    final c      = Theme.of(context).extension<AppColors>()!;

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
            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(loc.settings,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: c.textPrimary)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.primary.withValues(alpha: 0.12)),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // ── Apparence (Thème) ──────────────────────────────────
        _Section(
            title: loc.appearance,
            c: c,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: c.cardInner,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(
                          theme.isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: theme.isDark
                              ? const Color(0xFFB388FF)
                              : const Color(0xFFFFB400),
                          size: 22),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                theme.isDark
                                    ? loc.darkMode
                                    : loc.lightMode,
                                style: TextStyle(
                                    fontSize: 13, color: c.textPrimary)),
                            Text(loc.themeSubtitle,
                                style: TextStyle(
                                    fontSize: 10, color: c.textMuted)),
                          ]),
                    ]),
                    Switch(
                        value: theme.isDark,
                        activeColor: const Color(0xFFB388FF),
                        inactiveThumbColor: const Color(0xFFFFB400),
                        inactiveTrackColor:
                            const Color(0xFFFFB400).withValues(alpha: 0.3),
                        onChanged: (_) => theme.toggleTheme()),
                  ]),
            )),

        // ── IP ESP32 ───────────────────────────────────────────
        _Section(
            title: loc.esp32Ip,
            c: c,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: _ipCtrl,
                style: TextStyle(color: c.textPrimary),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: loc.ipHint,
                  hintStyle: TextStyle(color: c.textMuted),
                  filled: true,
                  fillColor: c.cardInner,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.save, color: c.primary),
                    onPressed: () {
                      p.setEsp32Ip(_ipCtrl.text);
                      setState(() => _testResult = null);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(loc.ipSaved),
                          backgroundColor: c.primary));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: c.cardInner,
                      foregroundColor: c.textPrimary,
                      side: BorderSide(color: c.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: _isTesting
                      ? null
                      : () async {
                          p.setEsp32Ip(_ipCtrl.text);
                          setState(() {
                            _isTesting = true;
                            _testResult = null;
                          });
                          final err = await p.testConnection();
                          setState(() {
                            _isTesting = false;
                            _testOk = err == null;
                            _testResult = err == null ? loc.testSuccess : err;
                          });
                        },
                  icon: _isTesting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: c.primary))
                      : const Icon(Icons.wifi_find, size: 18),
                  label: Text(_isTesting ? loc.testInProgress : loc.testConnection),
                ),
              ),
              if (_testResult != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: _testOk
                          ? c.primary.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _testOk
                              ? c.primary.withValues(alpha: 0.4)
                              : Colors.red.withValues(alpha: 0.4))),
                  child: Row(children: [
                    Icon(
                      _testOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 14,
                      color: _testOk ? c.primary : const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_testResult!,
                          style: TextStyle(
                              fontSize: 12,
                              color: _testOk
                                  ? c.primary
                                  : const Color(0xFFFF6B6B))),
                    ),
                  ]),
                ),
              ],
            ])),

        // ── Langue + Voix ──────────────────────────────────────
        _Section(
            title: loc.language,
            c: c,
            child: Column(children: [
              Row(children: [
                _LangBtn('🇫🇷', 'Français', lang.currentLanguageIndex == 0,
                    c, () {
                  lang.setLanguage(0);
                  chat.setLanguage(0);
                  p.updateSettings(language: 0);
                }),
                const SizedBox(width: 8),
                _LangBtn('🇹🇳', 'عربي', lang.currentLanguageIndex == 1, c, () {
                  lang.setLanguage(1);
                  chat.setLanguage(1);
                  p.updateSettings(language: 1);
                }),
                const SizedBox(width: 8),
                _LangBtn('🇬🇧', 'English', lang.currentLanguageIndex == 2,
                    c, () {
                  lang.setLanguage(2);
                  chat.setLanguage(2);
                  p.updateSettings(language: 2);
                }),
              ]),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: c.cardInner,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(
                            chat.ttsEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: chat.ttsEnabled
                                ? c.primary
                                : c.textMuted,
                            size: 20),
                        const SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chat.ttsEnabled ? loc.voice : loc.voiceOff,
                                  style: TextStyle(
                                      fontSize: 13, color: c.textPrimary)),
                              Text(loc.voiceSubtitle,
                                  style: TextStyle(
                                      fontSize: 10, color: c.textMuted)),
                            ]),
                      ]),
                      Switch(
                          value: chat.ttsEnabled,
                          activeColor: c.primary,
                          onChanged: (_) => chat.toggleTts()),
                    ]),
              ),
            ])),

        // ── Mode silencieux ────────────────────────────────────
        _Section(
            title: loc.silentMode,
            c: c,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: c.cardInner,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.notifications_off_outlined,
                          color: c.textMuted, size: 20),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.silentMode,
                                style: TextStyle(
                                    fontSize: 13, color: c.textPrimary)),
                            Text(loc.silentSubtitle,
                                style: TextStyle(
                                    fontSize: 10, color: c.textMuted)),
                          ]),
                    ]),
                    Switch(
                        value: p.currentData?.silentMode ?? false,
                        activeColor: c.primary,
                        onChanged: (v) => p.updateSettings(silentMode: v)),
                  ]),
            )),

        // ── Reset ──────────────────────────────────────────────
        _Section(
            title: loc.resetSession,
            c: c,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  final ok = await p.resetSession();
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(ok ? loc.resetSuccess : loc.resetError),
                        backgroundColor: ok ? c.primary : Colors.red));
                },
                icon: const Icon(Icons.refresh),
                label: Text(loc.resetBtn),
              ),
            )),

        // ── À propos ───────────────────────────────────────────
        _Section(
            title: loc.about,
            c: c,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: c.cardInner,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre app
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.accessibility_new_rounded,
                            color: c.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text('SpineGuard',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary)),
                    ]),
                    const SizedBox(height: 10),
                    // Description
                    Text(loc.aboutDescription,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: c.textMuted)),
                    const SizedBox(height: 12),
                    // Séparateur
                    Container(height: 1, color: c.border),
                    const SizedBox(height: 10),
                    // Auteurs
                    Text(loc.aboutAuthors,
                        style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: c.textMuted)),
                    const SizedBox(height: 6),
                    // Hardware
                    Text(loc.aboutHardware,
                        style: TextStyle(fontSize: 11, color: c.textMuted)),
                    const SizedBox(height: 4),
                    // Cloud
                    Text(loc.aboutCloud,
                        style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ]),
            )),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final AppColors c;
  const _Section({required this.title, required this.child, required this.c});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: c.card, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  color: c.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          child,
        ]),
      );
}

class _LangBtn extends StatelessWidget {
  final String flag, label;
  final bool selected;
  final AppColors c;
  final VoidCallback onTap;
  const _LangBtn(this.flag, this.label, this.selected, this.c, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: selected
                    ? c.primary.withValues(alpha: 0.15)
                    : c.cardInner,
                border: Border.all(
                    color: selected
                        ? c.primary
                        : c.border,
                    width: 1.5),
                borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: selected ? c.primary : c.textMuted)),
            ]),
          ),
        ),
      );
}
