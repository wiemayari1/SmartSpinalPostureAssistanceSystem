#include <Wire.h>
#include <MPU6050.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

MPU6050 mpu;
BLEServer *pServer = NULL;
BLECharacteristic *pCharacteristic = NULL;
bool deviceConnected = false;

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

class MyCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) { deviceConnected = true; }
    void onDisconnect(BLEServer* pServer) { deviceConnected = false; }
};

void setup() {
  Serial.begin(115200);
  Wire.begin();
  mpu.initialize();
  
  BLEDevice::init("PostureESP32");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->start();
}

void loop() {
  if (deviceConnected) {
    int16_t ax, ay, az, gx, gy, gz;
    mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
    
    // Calcul angle simplifié (pitch)
    float pitch = atan2(ax, sqrt(ay*ay + az*az)) * 180/PI;
    
    char buffer[20];
    sprintf(buffer, "%.1f", pitch);
    pCharacteristic->setValue(buffer);
    pCharacteristic->notify();
    
    delay(500); // Envoi toutes les 500ms
  }
  delay(100);
}
