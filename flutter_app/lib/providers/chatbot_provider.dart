import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/posture_data.dart';

class ChatbotProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _apiHistory = [];

  bool _isTyping = false;
  final FlutterTts _tts = FlutterTts();
  bool _ttsEnabled = true;
  int _currentLangIndex = 0;

  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get ttsEnabled => _ttsEnabled;
  int get currentLangIndex => _currentLangIndex;

  static const Map<int, String> _systemPrompts = {
    0: """Tu es SpineBot, un assistant médical intelligent intégré dans l'application SpineGuard.
SpineGuard est une application Flutter connectée à un capteur ESP32 (MPU6050) qui surveille la posture en temps réel.

Ton rôle :
- Répondre à TOUTES les questions liées à la posture, colonne vertébrale, ergonomie, douleurs dorsales, exercices, santé du dos.
- Donner des conseils personnalisés basés sur les données de posture de l'utilisateur quand elles sont disponibles.
- Rester dans le contexte médical/postural. Si la question est totalement hors sujet, rappelle gentiment ton rôle.
- Être bienveillant, professionnel, concis et pratique.
- Répondre TOUJOURS en français.""",
    1: """أنت سبايبوت، مساعد طبي ذكي مدمج في تطبيق SpineGuard.
SpineGuard تطبيق فلاتر متصل بحساس ESP32 (MPU6050) يراقب الوضعية في الوقت الحقيقي.

دورك:
- الإجابة على جميع الأسئلة المتعلقة بالوضعية، العمود الفقري، بيئة العمل، آلام الظهر، التمارين، صحة الظهر.
- تقديم نصائح مخصصة بناءً على بيانات وضعية المستخدم عند توفرها.
- البقاء في السياق الطبي/الوضعي. إذا كان السؤال خارج الموضوع تماماً، ذكّر بلطف بدورك.
- أن تكون ودوداً، محترفاً، موجزاً وعملياً.
- الإجابة دائماً باللغة العربية.""",
    2: """You are SpineBot, an intelligent medical assistant integrated into the SpineGuard app.
SpineGuard is a Flutter app connected to an ESP32 sensor (MPU6050) that monitors posture in real time.

Your role:
- Answer ALL questions related to posture, spine, ergonomics, back pain, exercises, back health.
- Give personalized advice based on the user's posture data when available.
- Stay within the medical/postural context. If a question is completely off-topic, gently remind about your role.
- Be kind, professional, concise and practical.
- ALWAYS reply in English.""",
  };

  static const Map<String, Map<int, String>> _voice = {
    'posture_good': {
      0: 'Bonne posture. Continuez ainsi.',
      1: 'وضعية جيدة. استمر هكذا.',
      2: 'Good posture. Keep it up.',
    },
    'posture_warning': {
      0: 'Attention. Votre posture se dégrade. Redressez-vous.',
      1: 'انتباه. وضعيتك تتدهور. قم بتقويم ظهرك.',
      2: 'Warning. Your posture is degrading. Straighten up.',
    },
    'posture_bad': {
      0: 'Mauvaise posture détectée. Redressez votre dos immédiatement.',
      1: 'تم اكتشاف وضعية سيئة. قوّم ظهرك فوراً.',
      2: 'Bad posture detected. Straighten your back immediately.',
    },
    'posture_critical': {
      0: 'Posture critique ! Corrigez immédiatement votre position.',
      1: 'وضعية خطيرة! صحح وضعيتك فوراً.',
      2: 'Critical posture! Correct your position immediately.',
    },
    'break_reminder': {
      0: 'Il est temps de faire une pause. Levez-vous et étirez-vous.',
      1: 'حان وقت الاستراحة. قم وتمدد قليلاً.',
      2: 'Time for a break. Stand up and stretch.',
    },
    'calibration_done': {
      0: 'Calibration terminée. Système prêt.',
      1: 'اكتملت المعايرة. النظام جاهز.',
      2: 'Calibration complete. System ready.',
    },
  };

  // Messages d'accueil SANS emojis — ton professionnel
  static const Map<int, String> _welcomeMessages = {
    0: "Bonjour ! Je suis SpineBot, votre assistant postural intelligent.\n\n"
        "Posez-moi n'importe quelle question sur votre dos, votre posture, "
        "l'ergonomie ou vos données SpineGuard.\n\n"
        "Exemples :\n"
        "• Pourquoi j'ai mal au bas du dos ?\n"
        "• Montre-moi ma posture actuelle\n"
        "• Quels exercices pour renforcer mon dos ?\n"
        "• Comment bien régler mon bureau ?",
    1: "مرحباً! أنا سبايبوت، مساعدك الذكي للوضعية.\n\n"
        "اسألني أي سؤال عن ظهرك أو وضعيتك أو بيئة عملك أو بيانات SpineGuard.\n\n"
        "أمثلة:\n"
        "• لماذا يؤلمني ظهري؟\n"
        "• أرني وضعيتي الحالية\n"
        "• ما هي تمارين تقوية الظهر؟",
    2: "Hello! I'm SpineBot, your intelligent posture assistant.\n\n"
        "Ask me anything about your back, posture, ergonomics, or SpineGuard data.\n\n"
        "Examples:\n"
        "• Why does my lower back hurt?\n"
        "• Show me my current posture\n"
        "• What exercises strengthen my back?",
  };

  // Messages d'erreur SANS emojis
  static const Map<int, String> _errorMessages = {
    0: "Impossible de contacter le serveur. Vérifiez votre connexion internet.",
    1: "تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.",
    2: "Unable to reach the server. Check your internet connection.",
  };

  ChatbotProvider() {
    _initTts();
    _addWelcomeMessage();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(0.9);
  }

  Future<void> setLanguage(int index) async {
    _currentLangIndex = index;
    const ttsLangs = ['fr-FR', 'ar-SA', 'en-US'];
    await _tts.setLanguage(ttsLangs[index]);
    _messages.clear();
    _apiHistory.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  Future<void> setTtsLanguage(int index) => setLanguage(index);
  void stopTts() => _tts.stop();

  void toggleTts() {
    _ttsEnabled = !_ttsEnabled;
    if (!_ttsEnabled) _tts.stop();
    notifyListeners();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage.bot(_welcomeMessages[_currentLangIndex]!));
  }

  void clearMessages() {
    _messages.clear();
    _apiHistory.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  Future<void> announcePostureState(PostureState state) async {
    if (!_ttsEnabled) return;
    final key = {
      PostureState.good: 'posture_good',
      PostureState.warning: 'posture_warning',
      PostureState.bad: 'posture_bad',
      PostureState.critical: 'posture_critical',
    }[state];
    if (key == null) return;
    final msg = _voice[key]![_currentLangIndex] ?? '';
    if (msg.isNotEmpty) await _tts.speak(msg);
  }

  Future<void> announce(String key) async {
    if (!_ttsEnabled) return;
    final msg = _voice[key]?[_currentLangIndex] ?? '';
    if (msg.isNotEmpty) await _tts.speak(msg);
  }

  Future<void> sendMessage(String text, {PostureData? currentPosture}) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage.user(text));
    _isTyping = true;
    notifyListeners();

    String userContent = text;
    if (currentPosture != null && currentPosture.isCalibrated) {
      userContent +=
          '\n\n[Données posture actuelles: ${_buildPostureContext(currentPosture)}]';
    }

    _apiHistory.add({'role': 'user', 'content': userContent});

    final response = await _callGroqApi();

    _isTyping = false;

    if (response != null) {
      _messages.add(ChatMessage.bot(response));
      _apiHistory.add({'role': 'assistant', 'content': response});
      if (_ttsEnabled) await _tts.speak(_cleanForTts(response));
    } else {
      final errMsg = _errorMessages[_currentLangIndex]!;
      _messages.add(ChatMessage.bot(errMsg, type: MessageType.alert));
      _apiHistory.removeLast();
    }

    notifyListeners();
  }

  Future<String?> _callGroqApi() async {
    try {
      final messages = [
        {'role': 'system', 'content': _systemPrompts[_currentLangIndex]},
        ..._apiHistory,
      ];

      final body = jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'messages': messages,
      });

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] as String;
      } else {
        debugPrint('Groq API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Groq API exception: $e');
    }
    return null;
  }

  String _buildPostureContext(PostureData posture) {
    return 'État=${posture.localizedLabel}, '
        'Inclinaison=${posture.pitch.toStringAsFixed(1)}°, '
        'Rotation=${posture.roll.toStringAsFixed(1)}°, '
        'Déviation=${posture.deviation.toStringAsFixed(1)}°, '
        'Durée=${_fmt(posture.sessionDuration)}, '
        'Alertes=${posture.totalAlerts}, '
        'BonnePosture=${(posture.goodPostureRatio * 100).toStringAsFixed(0)}%';
  }

  String _fmt(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}min';
    if (m > 0) return '${m}min ${s}s';
    return '${s}s';
  }

  String _cleanForTts(String text) => text
      .replaceAll(RegExp(r'[•\*#←→]'), '')
      .replaceAll(RegExp(r'\n+'), '. ')
      .trim();

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
