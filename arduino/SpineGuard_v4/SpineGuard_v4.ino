/*
  =============================================================
  SpineGuard - Firmware ESP32 v4 (CORS + connectivite Flutter)
  -------------------------------------------------------------
  CORRECTIONS v4 :
    - Ajout des headers CORS sur tous les endpoints HTTP
      (Access-Control-Allow-Origin: *)
    - Gestion des requetes OPTIONS (preflight CORS)
    - Ces 2 corrections sont indispensables pour que
      l'application Flutter Android puisse communiquer
      avec l'ESP32 sans etre bloquee par le navigateur
      ou le systeme Android.

  Corrections precedentes conservees :
    - Filtre complementaire avec dt reel (v3)
    - Buzzer non-bloquant (v2)

  Auteurs : Wiem Ayari & Aya Sakroufi - 1ING03
  =============================================================
*/

#include <Wire.h>
#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <EEPROM.h>
#include "config.h"

// =============================================================
// 1. VARIABLES GLOBALES
// =============================================================
WebServer server(80);

enum PostureState { GOOD, WARNING, BAD, CRITICAL };
PostureState currentState  = GOOD;
PostureState previousState = GOOD;

float refPitch     = 0.0;
float refRoll      = 0.0;
bool  isCalibrated = false;

float pitchFilt = 0.0;
float rollFilt  = 0.0;

unsigned long lastMpuRead = 0;

float pitchHistory[10];
float rollHistory[10];
int   historyIndex = 0;

int           totalAlerts         = 0;
int           badPostureCount     = 0;
unsigned long totalBadPostureTime = 0;
unsigned long sessionStartTime    = 0;

unsigned long lastPostureCheck = 0;
unsigned long lastReminder     = 0;
unsigned long lastCloudSend    = 0;
unsigned long lastAlertSound   = 0;
unsigned long stateEntryTime   = 0;

unsigned long lastBlink = 0;
bool          blinkOn   = false;

bool silentMode      = false;
int  currentLanguage = 0;

// =============================================================
// 2. BUZZER NON-BLOQUANT
// =============================================================
bool          buzzerActive     = false;
int           buzzerBipCount   = 0;
int           buzzerBipTotal   = 0;
int           buzzerBipMs      = 0;
unsigned long buzzerPhaseStart = 0;
bool          buzzerInBip      = false;

void startBuzzerPattern(PostureState s) {
  if (silentMode) return;
  switch (s) {
    case WARNING:  buzzerBipTotal = 1; buzzerBipMs = 100; break;
    case BAD:      buzzerBipTotal = 2; buzzerBipMs = 200; break;
    case CRITICAL: buzzerBipTotal = 3; buzzerBipMs = 400; break;
    default: return;
  }
  buzzerBipCount   = 0;
  buzzerActive     = true;
  buzzerInBip      = true;
  buzzerPhaseStart = millis();
  digitalWrite(PIN_BUZZER, HIGH);
}

void stopBuzzer() {
  digitalWrite(PIN_BUZZER, LOW);
  buzzerActive   = false;
  buzzerInBip    = false;
  buzzerBipCount = 0;
}

void updateBuzzer() {
  if (!buzzerActive) return;
  unsigned long elapsed = millis() - buzzerPhaseStart;
  if (buzzerInBip) {
    if (elapsed >= (unsigned long)buzzerBipMs) {
      digitalWrite(PIN_BUZZER, LOW);
      buzzerBipCount++;
      if (buzzerBipCount >= buzzerBipTotal) {
        buzzerActive = false;
        return;
      }
      buzzerInBip      = false;
      buzzerPhaseStart = millis();
    }
  } else {
    if (elapsed >= 150UL) {
      digitalWrite(PIN_BUZZER, HIGH);
      buzzerInBip      = true;
      buzzerPhaseStart = millis();
    }
  }
}

// =============================================================
// 3. MPU6050 (Wire direct)
// =============================================================
int16_t mpuReadWord(uint8_t reg) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(reg);
  Wire.endTransmission(false);
  Wire.requestFrom((int)MPU_ADDR, 2);
  int16_t high = Wire.read();
  int16_t low  = Wire.read();
  return (high << 8) | low;
}

bool mpuInit() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(MPU_PWR_MGMT_1);
  Wire.write(0x00);
  return (Wire.endTransmission(true) == 0);
}

// =============================================================
// 4. FILTRE COMPLEMENTAIRE (dt reel)
// =============================================================
void readRawAngles(float &pitchAcc, float &rollAcc,
                   float &gx,       float &gy) {
  int16_t ax_raw = mpuReadWord(MPU_ACCEL_XOUT_H);
  int16_t ay_raw = mpuReadWord(MPU_ACCEL_XOUT_H + 2);
  int16_t az_raw = mpuReadWord(MPU_ACCEL_XOUT_H + 4);
  int16_t gx_raw = mpuReadWord(MPU_GYRO_XOUT_H);
  int16_t gy_raw = mpuReadWord(MPU_GYRO_XOUT_H + 2);

  float ax = ax_raw / 16384.0;
  float ay = ay_raw / 16384.0;
  float az = az_raw / 16384.0;
  gx = gx_raw / 131.0;
  gy = gy_raw / 131.0;

  pitchAcc = atan2(ax, sqrt(ay * ay + az * az)) * 180.0 / PI;
  rollAcc  = atan2(ay, sqrt(ax * ax + az * az)) * 180.0 / PI;
}

void updateFilter() {
  unsigned long now = millis();
  float dt = (now - lastMpuRead) / 1000.0;
  lastMpuRead = now;
  if (dt > 0.5) dt = 0.01;

  float pitchAcc, rollAcc, gx, gy;
  readRawAngles(pitchAcc, rollAcc, gx, gy);

  const float alpha = 0.1;
  pitchFilt = alpha * pitchAcc + (1.0 - alpha) * (pitchFilt + gx * dt);
  rollFilt  = alpha * rollAcc  + (1.0 - alpha) * (rollFilt  + gy * dt);
}

// =============================================================
// 5. LED RGB ANODE COMMUNE
// =============================================================
void rgb(uint8_t r, uint8_t g, uint8_t b) {
  analogWrite(PIN_LED_R, 255 - r);
  analogWrite(PIN_LED_G, 255 - g);
  analogWrite(PIN_LED_B, 255 - b);
}

void updateLED() {
  switch (currentState) {
    case GOOD:    rgb(0, 255, 0);   break;
    case WARNING: rgb(255, 180, 0); break;
    case BAD:     rgb(255, 0, 0);   break;
    case CRITICAL:
      if (millis() - lastBlink > 250) {
        lastBlink = millis();
        blinkOn = !blinkOn;
        rgb(blinkOn ? 255 : 0, 0, 0);
      }
      break;
  }
}

// =============================================================
// 6. CLASSIFICATION
// =============================================================
PostureState classifyPosture(float deviation) {
  if (deviation < THRESHOLD_WARNING)  return GOOD;
  if (deviation < THRESHOLD_BAD)      return WARNING;
  if (deviation < THRESHOLD_CRITICAL) return BAD;
  return CRITICAL;
}

const char* stateToString(PostureState s) {
  switch (s) {
    case GOOD:     return "good";
    case WARNING:  return "warning";
    case BAD:      return "bad";
    case CRITICAL: return "critical";
  }
  return "unknown";
}

// =============================================================
// 7. EEPROM
// =============================================================
void saveCalibrationToEEPROM() {
  EEPROM.writeFloat(EEPROM_ADDR_PITCH, refPitch);
  EEPROM.writeFloat(EEPROM_ADDR_ROLL,  refRoll);
  EEPROM.write(EEPROM_ADDR_FLAG, 1);
  EEPROM.commit();
  Serial.println(F("[EEPROM] Calibration sauvegardee."));
}

void loadSettingsFromEEPROM() {
  if (EEPROM.read(EEPROM_ADDR_FLAG) == 1) {
    refPitch     = EEPROM.readFloat(EEPROM_ADDR_PITCH);
    refRoll      = EEPROM.readFloat(EEPROM_ADDR_ROLL);
    isCalibrated = true;
    Serial.print(F("[EEPROM] Calibration restauree : pitch="));
    Serial.print(refPitch, 2);
    Serial.print(F("  roll="));
    Serial.println(refRoll, 2);
  } else {
    Serial.println(F("[EEPROM] Aucune calibration sauvegardee."));
  }
  byte lang = EEPROM.read(EEPROM_ADDR_LANG);
  if (lang <= 2) currentLanguage = lang;
  silentMode = (EEPROM.read(EEPROM_ADDR_SILENT) == 1);
}

// =============================================================
// 8. CALIBRATION
// =============================================================
void calibratePosture() {
  Serial.println(F("\n=== CALIBRATION ==="));
  Serial.println(F("Tenez-vous droit pendant 3 secondes..."));
  stopBuzzer();
  rgb(0, 0, 200);
  delay(2000);

  float sumP = 0, sumR = 0;
  for (int i = 0; i < 50; i++) {
    delay(10);
    updateFilter();
    sumP += pitchFilt;
    sumR += rollFilt;
  }
  refPitch     = sumP / 50.0;
  refRoll      = sumR / 50.0;
  isCalibrated = true;

  saveCalibrationToEEPROM();

  Serial.print(F("[OK] pitch_ref="));
  Serial.print(refPitch, 2);
  Serial.print(F("  roll_ref="));
  Serial.println(refRoll, 2);

  rgb(0, 255, 0);
  digitalWrite(PIN_BUZZER, HIGH); delay(500); digitalWrite(PIN_BUZZER, LOW);
  delay(300);
  lastMpuRead = millis();
}

// =============================================================
// 9. DETECTION POSTURALE
// =============================================================
void checkPosture() {
  if (!isCalibrated) return;

  float deviation = max(fabs(pitchFilt - refPitch),
                        fabs(rollFilt  - refRoll));

  pitchHistory[historyIndex] = pitchFilt;
  rollHistory[historyIndex]  = rollFilt;
  historyIndex = (historyIndex + 1) % 10;

  PostureState newState = classifyPosture(deviation);

  if (newState != currentState) {
    previousState  = currentState;
    currentState   = newState;
    stateEntryTime = millis();

    Serial.print(F("[ETAT] "));
    Serial.print(stateToString(previousState));
    Serial.print(F(" -> "));
    Serial.print(stateToString(currentState));
    Serial.print(F("  pitch="));
    Serial.print(pitchFilt, 1);
    Serial.print(F("  roll="));
    Serial.print(rollFilt, 1);
    Serial.print(F("  dev="));
    Serial.print(deviation, 1);
    Serial.println(F(" deg"));

    if (currentState == GOOD && buzzerActive) {
      stopBuzzer();
      Serial.println(F("[OK] Posture corrigee."));
    }
  }

  if (currentState == BAD || currentState == CRITICAL)
    totalBadPostureTime += POSTURE_CHECK_MS;
}

// =============================================================
// 10. ALERTES
// =============================================================
void handleStateAlerts() {
  unsigned long now = millis();

  if (currentState == GOOD) {
    if (buzzerActive) stopBuzzer();
    return;
  }

  unsigned long delayBeforeAlert = (currentState == CRITICAL)
                                    ? CRITICAL_DELAY_MS
                                    : ALERT_DELAY_MS;

  if (!buzzerActive &&
      (now - stateEntryTime) >= delayBeforeAlert &&
      (now - lastAlertSound) >= ALERT_REPEAT_MS) {
    startBuzzerPattern(currentState);
    lastAlertSound = now;
    totalAlerts++;
    if (currentState == BAD || currentState == CRITICAL)
      badPostureCount++;
  }
}

// =============================================================
// 11. RAPPEL DE PAUSE
// =============================================================
void sendBreakReminder() {
  Serial.println(F("[RAPPEL] Pause recommandee."));
  rgb(0, 0, 255); delay(200);
  updateLED();
  startBuzzerPattern(WARNING);
}

// =============================================================
// 12. CLOUD n8n
// =============================================================
void sendDataToCloud() {
#if USE_CLOUD
  if (WiFi.status() != WL_CONNECTED) return;

  // ── Envoi des données toutes les minutes ──────────────────
  HTTPClient http;
  http.begin(N8N_WEBHOOK_DATA);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<256> doc;
  doc["device_id"]    = DEVICE_ID;
  doc["state"]        = stateToString(currentState);
  doc["pitch"]        = pitchFilt;
  doc["roll"]         = rollFilt;
  doc["deviation"]    = max(fabs(pitchFilt - refPitch),
                            fabs(rollFilt  - refRoll));
  doc["total_alerts"] = totalAlerts;
  doc["bad_time_s"]   = totalBadPostureTime / 1000;
  doc["session_s"]    = (millis() - sessionStartTime) / 1000;

  String payload;
  serializeJson(doc, payload);
  int code = http.POST(payload);
  Serial.print(F("[CLOUD] Donnees -> HTTP ")); Serial.println(code);
  http.end();

  // ── Envoi alerte si BAD ou CRITICAL ───────────────────────
  if (currentState == BAD || currentState == CRITICAL) {
    HTTPClient httpAlert;
    httpAlert.begin(N8N_WEBHOOK_ALERT);
    httpAlert.addHeader("Content-Type", "application/json");

    StaticJsonDocument<256> alertDoc;
    alertDoc["device_id"] = DEVICE_ID;
    alertDoc["state"]     = stateToString(currentState);
    alertDoc["pitch"]     = pitchFilt;
    alertDoc["roll"]      = rollFilt;
    alertDoc["deviation"] = max(fabs(pitchFilt - refPitch),
                                fabs(rollFilt  - refRoll));
    alertDoc["total_alerts"] = totalAlerts;

    String alertPayload;
    serializeJson(alertDoc, alertPayload);
    int alertCode = httpAlert.POST(alertPayload);
    Serial.print(F("[CLOUD] Alerte -> HTTP ")); Serial.println(alertCode);
    httpAlert.end();
  }
#endif
}

// =============================================================
// 13. HEADERS CORS (nouvelle section v4)
// -------------------------------------------------------------
// Indispensable pour que Flutter Android puisse acceder
// au serveur HTTP de l'ESP32 sans etre bloque par CORS.
// =============================================================
void sendCorsHeaders() {
  server.sendHeader("Access-Control-Allow-Origin",  "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  server.sendHeader("Access-Control-Max-Age",       "86400");
}

// =============================================================
// 14. HANDLERS HTTP
// =============================================================
void handleRoot() {
  sendCorsHeaders();
  server.send(200, "text/html; charset=utf-8",
    "<!DOCTYPE html><html><head><meta charset='utf-8'>"
    "<title>SpineGuard v4</title>"
    "<style>body{font-family:sans-serif;max-width:500px;margin:24px auto;"
    "background:#1a1a2e;color:#fff;padding:0 16px}"
    "h2{color:#00d4aa}code{background:#16213e;padding:3px 8px;"
    "border-radius:4px;color:#00d4aa}li{margin:6px 0}</style></head><body>"
    "<h2>SpineGuard v4</h2>"
    "<ul>"
    "<li><code>GET  /api/status</code></li>"
    "<li><code>POST /api/calibrate</code></li>"
    "<li><code>GET  /api/history</code></li>"
    "<li><code>GET  /api/recommendations</code></li>"
    "<li><code>GET  /api/settings</code></li>"
    "<li><code>POST /api/settings</code></li>"
    "<li><code>POST /api/reset</code></li>"
    "</ul></body></html>");
}

void handleStatus() {
  sendCorsHeaders();
  StaticJsonDocument<512> doc;
  float deviation = max(fabs(pitchFilt - refPitch),
                        fabs(rollFilt  - refRoll));
  doc["state"]          = stateToString(currentState);
  doc["pitch"]          = pitchFilt;
  doc["roll"]           = rollFilt;
  doc["ref_pitch"]      = refPitch;
  doc["ref_roll"]       = refRoll;
  doc["deviation"]      = deviation;
  doc["total_alerts"]   = totalAlerts;
  doc["bad_count"]      = badPostureCount;
  doc["bad_posture_s"]  = totalBadPostureTime / 1000;
  doc["session_s"]      = (millis() - sessionStartTime) / 1000;
  doc["is_calibrated"]  = isCalibrated;
  doc["language"]       = currentLanguage;
  doc["silent_mode"]    = silentMode;
  doc["wifi_connected"] = (WiFi.status() == WL_CONNECTED);
  doc["rssi"]           = WiFi.RSSI();
  String r;
  serializeJson(doc, r);
  server.send(200, "application/json", r);
}

void handleCalibrate() {
  sendCorsHeaders();
  calibratePosture();
  StaticJsonDocument<128> doc;
  doc["status"]    = "calibrated";
  doc["ref_pitch"] = refPitch;
  doc["ref_roll"]  = refRoll;
  String r;
  serializeJson(doc, r);
  server.send(200, "application/json", r);
}

void handleHistory() {
  sendCorsHeaders();
  StaticJsonDocument<512> doc;
  JsonArray pitches = doc.createNestedArray("pitch_history");
  JsonArray rolls   = doc.createNestedArray("roll_history");
  for (int i = 0; i < 10; i++) {
    pitches.add(pitchHistory[(historyIndex + i) % 10]);
    rolls.add(  rollHistory[ (historyIndex + i) % 10]);
  }
  String r;
  serializeJson(doc, r);
  server.send(200, "application/json", r);
}

void handleRecommendations() {
  sendCorsHeaders();
  StaticJsonDocument<512> doc;
  JsonArray recs = doc.createNestedArray("recommendations");
  switch (currentState) {
    case GOOD:
      recs.add("Bonne posture - continuez ainsi.");
      recs.add("Micro-pause toutes les 30 minutes.");
      break;
    case WARNING:
      recs.add("Redressez legerement le dos.");
      recs.add("Rapprochez les epaules vers l'arriere.");
      break;
    case BAD:
    case CRITICAL:
      recs.add("Corrigez immediatement votre posture.");
      recs.add("Levez-vous et marchez 1 a 2 minutes.");
      recs.add("Inclinez la tete a gauche et a droite, 10s.");
      break;
  }
  String r;
  serializeJson(doc, r);
  server.send(200, "application/json", r);
}

void handleGetSettings() {
  sendCorsHeaders();
  StaticJsonDocument<256> doc;
  doc["language"]            = currentLanguage;
  doc["silent_mode"]         = silentMode;
  doc["threshold_warning"]   = THRESHOLD_WARNING;
  doc["threshold_bad"]       = THRESHOLD_BAD;
  doc["threshold_critical"]  = THRESHOLD_CRITICAL;
  doc["check_interval_ms"]   = POSTURE_CHECK_MS;
  doc["reminder_interval_s"] = REMINDER_INTERVAL_MS / 1000;
  String r;
  serializeJson(doc, r);
  server.send(200, "application/json", r);
}

void handleSetSettings() {
  sendCorsHeaders();
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"error\":\"missing body\"}");
    return;
  }
  StaticJsonDocument<256> doc;
  if (deserializeJson(doc, server.arg("plain"))) {
    server.send(400, "application/json", "{\"error\":\"bad json\"}");
    return;
  }
  if (doc.containsKey("language")) {
    int lang = doc["language"];
    if (lang >= 0 && lang <= 2) {
      currentLanguage = lang;
      EEPROM.write(EEPROM_ADDR_LANG, currentLanguage);
      EEPROM.commit();
    }
  }
  if (doc.containsKey("silent_mode")) {
    silentMode = doc["silent_mode"];
    EEPROM.write(EEPROM_ADDR_SILENT, silentMode ? 1 : 0);
    EEPROM.commit();
  }
  server.send(200, "application/json", "{\"status\":\"ok\"}");
}

void handleReset() {
  sendCorsHeaders();
  totalAlerts         = 0;
  badPostureCount     = 0;
  totalBadPostureTime = 0;
  sessionStartTime    = millis();
  server.send(200, "application/json", "{\"status\":\"reset\"}");
}

// Handler OPTIONS pour le preflight CORS
// Flutter envoie une requete OPTIONS avant chaque POST
void handleOptions() {
  sendCorsHeaders();
  server.send(204);
}

// =============================================================
// 15. INIT
// =============================================================
void initPins() {
  pinMode(PIN_LED_R,  OUTPUT);
  pinMode(PIN_LED_G,  OUTPUT);
  pinMode(PIN_LED_B,  OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  rgb(0, 0, 0);
  digitalWrite(PIN_BUZZER, LOW);
}

void initWiFi() {
  Serial.print(F("[WIFI] Connexion a "));
  Serial.println(WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  unsigned long t0 = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - t0 < WIFI_TIMEOUT_MS) {
    delay(250);
    Serial.print(".");
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print(F("\n[WIFI] Connecte. IP : "));
    Serial.println(WiFi.localIP());
  } else {
    Serial.println(F("\n[WIFI] Echec - mode autonome."));
  }
}

void initWebServer() {
  // Routes GET
  server.on("/",                    HTTP_GET,     handleRoot);
  server.on("/api/status",          HTTP_GET,     handleStatus);
  server.on("/api/history",         HTTP_GET,     handleHistory);
  server.on("/api/recommendations", HTTP_GET,     handleRecommendations);
  server.on("/api/settings",        HTTP_GET,     handleGetSettings);

  // Routes POST
  server.on("/api/calibrate",       HTTP_POST,    handleCalibrate);
  server.on("/api/settings",        HTTP_POST,    handleSetSettings);
  server.on("/api/reset",           HTTP_POST,    handleReset);

  // Routes OPTIONS (preflight CORS — indispensable pour Flutter)
  server.on("/api/status",          HTTP_OPTIONS, handleOptions);
  server.on("/api/calibrate",       HTTP_OPTIONS, handleOptions);
  server.on("/api/history",         HTTP_OPTIONS, handleOptions);
  server.on("/api/recommendations", HTTP_OPTIONS, handleOptions);
  server.on("/api/settings",        HTTP_OPTIONS, handleOptions);
  server.on("/api/reset",           HTTP_OPTIONS, handleOptions);

  // Handler 404 avec CORS
  server.onNotFound([]() {
    sendCorsHeaders();
    if (server.method() == HTTP_OPTIONS) {
      server.send(204);
    } else {
      server.send(404, "application/json", "{\"error\":\"not found\"}");
    }
  });

  server.begin();
  Serial.println(F("[HTTP] Serveur v4 demarre sur le port 80."));
  Serial.println(F("[HTTP] CORS active pour Flutter Android."));
}

// =============================================================
// 16. SETUP
// =============================================================
void setup() {
  Serial.begin(SERIAL_BAUD);
  delay(500);

  Serial.println();
  Serial.println(F("================================================"));
  Serial.println(F("  SpineGuard - Firmware ESP32 v4"));
  Serial.println(F("  CORS + Filtre complementaire + Buzzer async"));
  Serial.println(F("  Wiem Ayari & Aya Sakroufi - 1ING03"));
  Serial.println(F("================================================"));

  initPins();
  EEPROM.begin(EEPROM_SIZE);
  loadSettingsFromEEPROM();
  Wire.begin(PIN_SDA, PIN_SCL, I2C_FREQ);

  if (!mpuInit()) {
    Serial.println(F("[ERREUR] MPU6050 introuvable."));
    while (true) { rgb(255,0,0); delay(200); rgb(0,0,0); delay(200); }
  }
  Serial.println(F("[OK] MPU6050 initialise."));

  initWiFi();
  initWebServer();

  // Initialiser le filtre avec la valeur brute de l'accelerometre
  float pa, ra, gx, gy;
  readRawAngles(pa, ra, gx, gy);
  pitchFilt   = pa;
  rollFilt    = ra;
  lastMpuRead = millis();

  if (!isCalibrated) {
    calibratePosture();
  } else {
    Serial.println(F("[INFO] Calibration restauree depuis EEPROM."));
    Serial.println(F("[INFO] POST /api/calibrate pour recalibrer."));
    // Chauffe le filtre 1 seconde
    for (int i = 0; i < 100; i++) { delay(10); updateFilter(); }
    rgb(0, 255, 0);
    digitalWrite(PIN_BUZZER, HIGH); delay(200); digitalWrite(PIN_BUZZER, LOW);
  }

  sessionStartTime = millis();
  lastReminder     = millis();
  lastMpuRead      = millis();

  Serial.println(F("\n=== SYSTEME PRET ==="));
  Serial.println(F("Surveillance posturale active."));
  Serial.print(F("IP : ")); Serial.println(WiFi.localIP());
  Serial.print(F("Seuils : WARNING="));
  Serial.print(THRESHOLD_WARNING);
  Serial.print(F("  BAD="));
  Serial.print(THRESHOLD_BAD);
  Serial.print(F("  CRITICAL="));
  Serial.println(THRESHOLD_CRITICAL);
  Serial.println();
}

// =============================================================
// 17. LOOP
// =============================================================
void loop() {
  server.handleClient();

  unsigned long now = millis();

  // Filtre MPU toutes les 10ms
  if (now - lastMpuRead >= 10) {
    updateFilter();
  }

  // Classification toutes les 500ms
  if (now - lastPostureCheck >= POSTURE_CHECK_MS) {
    lastPostureCheck = now;
    checkPosture();
  }

  // Rappel de pause toutes les 30 minutes
  if (now - lastReminder >= REMINDER_INTERVAL_MS) {
    lastReminder = now;
    sendBreakReminder();
  }

#if USE_CLOUD
  if (now - lastCloudSend >= CLOUD_SEND_INTERVAL_MS) {
    lastCloudSend = now;
    sendDataToCloud();
  }
#endif

  handleStateAlerts();
  updateBuzzer();
  updateLED();
}
