import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/posture_data.dart';

class PostureProvider extends ChangeNotifier {
  String _esp32Ip = '';
  PostureData? _currentData;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _lastError;
  final List<double> _pitchHistory = [];
  final List<double> _rollHistory = [];
  Timer? _pollingTimer;

  String get esp32Ip => _esp32Ip;
  PostureData? get currentData => _currentData;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  List<double> get pitchHistory => List.unmodifiable(_pitchHistory);
  List<double> get rollHistory => List.unmodifiable(_rollHistory);

  PostureProvider() {
    _init();
  }

  // ── CORRECTION : charge l'IP D'ABORD, puis démarre le polling ──
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _esp32Ip = prefs.getString('esp32_ip') ?? '192.168.103.185';
    notifyListeners();
    _startPolling();
  }

  Future<void> setEsp32Ip(String ip) async {
    _esp32Ip = ip.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('esp32_ip', _esp32Ip);
    notifyListeners();
    // Redémarre le polling avec la nouvelle IP
    _pollingTimer?.cancel();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => fetchStatus(),
    );
    fetchStatus();
  }

  /// Vérifie si l'IP a un format valide (xxx.xxx.xxx.xxx)
  bool get isIpValid {
    final parts = _esp32Ip.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255;
    });
  }

  Future<void> fetchStatus() async {
    if (_isLoading) return;
    if (_esp32Ip.isEmpty) return;
    _isLoading = true;
    try {
      final url = Uri.parse('http://$_esp32Ip/api/status');
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        _currentData = PostureData.fromJson(jsonDecode(response.body));
        _isConnected = true;
        _lastError = null;
        if (_pitchHistory.length >= 30) _pitchHistory.removeAt(0);
        if (_rollHistory.length >= 30) _rollHistory.removeAt(0);
        _pitchHistory.add(_currentData!.pitch);
        _rollHistory.add(_currentData!.roll);
      } else {
        _isConnected = false;
        _lastError = 'Erreur HTTP ${response.statusCode}';
      }
    } on TimeoutException {
      _isConnected = false;
      _lastError = 'Timeout – ESP32 ne répond pas (IP: $_esp32Ip)';
    } on SocketException catch (e) {
      _isConnected = false;
      _lastError = 'Réseau inaccessible – vérifiez le WiFi (${e.message})';
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Test explicite de connectivité, retourne le message d'erreur ou null si OK
  Future<String?> testConnection() async {
    if (_esp32Ip.isEmpty) return 'IP non configurée';
    if (!isIpValid) return 'Format IP invalide ($_esp32Ip)';
    try {
      final response = await http
          .get(Uri.parse('http://$_esp32Ip/api/status'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) return null; // succès
      return 'HTTP ${response.statusCode}';
    } on TimeoutException {
      return 'Timeout – L\'ESP32 ne répond pas à l\'adresse $_esp32Ip';
    } on SocketException catch (e) {
      return 'Réseau inaccessible: ${e.message}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> calibrate() async {
    try {
      final response = await http
          .post(Uri.parse('http://$_esp32Ip/api/calibrate'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        await fetchStatus();
        return true;
      }
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> resetSession() async {
    try {
      final r = await http
          .post(Uri.parse('http://$_esp32Ip/api/reset'))
          .timeout(const Duration(seconds: 3));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateSettings({int? language, bool? silentMode}) async {
    try {
      final body = <String, dynamic>{};
      if (language != null) body['language'] = language;
      if (silentMode != null) body['silent_mode'] = silentMode;
      final r = await http
          .post(
            Uri.parse('http://$_esp32Ip/api/settings'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 3));
      if (r.statusCode == 200) {
        await fetchStatus();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<List<String>> fetchRecommendations() async {
    try {
      final r = await http
          .get(Uri.parse('http://$_esp32Ip/api/recommendations'))
          .timeout(const Duration(seconds: 3));
      if (r.statusCode == 200) {
        return List<String>.from(jsonDecode(r.body)['recommendations'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
