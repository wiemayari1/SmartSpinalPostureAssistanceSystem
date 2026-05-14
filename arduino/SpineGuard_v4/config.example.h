/*
  SpineGuard - Example configuration
  Copy this file to config.h, then fill in local/private values.
*/
#ifndef CONFIG_H
#define CONFIG_H

// ==================== WIFI ====================
#define WIFI_SSID      "YOUR_WIFI_SSID"
#define WIFI_PASSWORD  "YOUR_WIFI_PASSWORD"

// ==================== CLOUD n8n (optional) ====================
#define USE_CLOUD              true
#define N8N_WEBHOOK_DATA       "https://your-n8n-domain/webhook/posture-data"
#define N8N_WEBHOOK_ALERT      "https://your-n8n-domain/webhook/posture-alert"

// ==================== GPIO ====================
#define PIN_SDA           21
#define PIN_SCL           22
#define PIN_LED_R         12
#define PIN_LED_G         13
#define PIN_LED_B         14
#define PIN_BUZZER        25

// ==================== MPU6050 ====================
#define MPU_ADDR          0x68
#define MPU_PWR_MGMT_1    0x6B
#define MPU_ACCEL_XOUT_H  0x3B
#define MPU_GYRO_XOUT_H   0x43

// ==================== POSTURE THRESHOLDS (degrees) ====================
#define THRESHOLD_WARNING   15.0
#define THRESHOLD_BAD       25.0
#define THRESHOLD_CRITICAL  35.0

// ==================== TIMING ====================
#define POSTURE_CHECK_MS         500UL
#define ALERT_DELAY_MS           5000UL
#define ALERT_REPEAT_MS          3000UL
#define CRITICAL_DELAY_MS        3000UL
#define REMINDER_INTERVAL_MS     1800000UL
#define CLOUD_SEND_INTERVAL_MS   60000UL
#define WIFI_TIMEOUT_MS          10000UL

// ==================== EEPROM ====================
#define EEPROM_SIZE        64
#define EEPROM_ADDR_PITCH  0
#define EEPROM_ADDR_ROLL   4
#define EEPROM_ADDR_FLAG   8
#define EEPROM_ADDR_LANG   9
#define EEPROM_ADDR_SILENT 10

// ==================== OTHER ====================
#define SERIAL_BAUD        115200
#define I2C_FREQ           400000
#define DEVICE_ID          "spineguard-001"

#endif
