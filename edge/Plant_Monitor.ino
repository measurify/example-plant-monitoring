#include <stdlib.h>
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_TSL2561_U.h>
#include <Adafruit_Sensor.h>
#include <TFT.h>
#include <SPI.h>
#include <WiFiNINA.h>
#include <ArduinoJson.h>

#include "PlantMonitorSecrets.h"

#define soilMoisturePin A0 
#define dhtPin 13
#define dhtType DHT22
#define tftCs 10
#define tftDc   9
#define tftReset  8  

float soilMoistureValue, airHumidityValue, airTemperatureValue = 0; 
int lightValue = 0;
// ScanInterval is -1 by default
int scanInterval = -1;
char soilMoistureChar[8], airHumidityChar[8], airTemperatureChar[8], lightChar[8], soilMoistureRHChar[8];
char wifiSsid[] = wifiName;
char wifiPass[] = wifiPassword;
char endOfHeaders[] = "\r\n\r\n";
int wifiStatus = WL_IDLE_STATUS; 
String atmosphereUser = atmosphereUsername;
String atmospherePass = atmospherePassword;
String jsonLogin;
String token;
unsigned long startMillis = 0;
unsigned long millisScanInterval = 0;

// Initialize temperature and humidity sensor
DHT dht(dhtPin, dhtType);
// Initialize light sensor with 1234 like id
Adafruit_TSL2561_Unified light_sensor = Adafruit_TSL2561_Unified(TSL2561_ADDR_FLOAT, 12345);
// Inizialize tft screen
TFT tftScreen = TFT(tftCs, tftDc, tftReset);
// Initialize wifi client
WiFiClient client;

void setup() { 

 light_sensor.begin();
 // With autorange, sensor can decide its sensivity automatically
 light_sensor.enableAutoRange(true); 
 // This is the best resolution but the slowlest
 light_sensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_402MS);
 
 Serial.begin(9600); 
 dht.begin();
 
 tftScreen.begin();  
 // Clear screen with blue
 tftScreen.background(0,0,255);
 // Set the font color to green
  tftScreen.stroke(0, 255, 0);
 // Increase font size 
 tftScreen.setTextSize(2);
 // Create static text
 tftScreen.text("Moisture:",0,0);
 tftScreen.text("%RH",100,18);  
 tftScreen.text("Air Humidity:",0,35); 
 tftScreen.text("%RH",100,55);  
 tftScreen.text("Temperature:",0,70); 
 tftScreen.text("C",100,90); 
 tftScreen.text("Light:",00,110); 
 tftScreen.setTextSize(1);
 tftScreen.text("Lux",142,115); 

 // Create json for atmosphere login
 StaticJsonDocument<300> jsonDocumentLogin;
 jsonDocumentLogin["username"] = atmosphereUser;
 jsonDocumentLogin["password"] = atmospherePass;
 serializeJson(jsonDocumentLogin, jsonLogin); 
} 

void loop() { 

  // Control if interval time is passed 
  if ((millis() - startMillis) < millisScanInterval){
    // if are passed 49.71 days, millis() resets itself so millis()-startMillis is negative, here we fix this issue
    if((millis() - startMillis) < 0){
      // 4294967295 is the max value of unsigned long so is the max value of millis()
      unsigned long timePassed = 4294967295 - startMillis;
      startMillis = 0;
      millisScanInterval = millisScanInterval - timePassed;
    } 
  }
  else { 
  // Try to connect to Wifi
  connectToWifi();

  // Get data from sensors
  getSensorsData();
  
  //Create char arrays with results
  dtostrf(soilMoistureValue, 6, 2, soilMoistureChar);
  dtostrf(airHumidityValue, 6, 2, airHumidityChar);
  dtostrf(airTemperatureValue, 6, 2, airTemperatureChar);
  itoa(lightValue, lightChar, 10);

  // Change moisture in %RH
  if(soilMoistureValue > 520)
    soilMoistureValue = 520;
  else if(soilMoistureValue < 260)
    soilMoistureValue = 260;
    
  soilMoistureValue = (soilMoistureValue - 520) / (260 - 520)*100;

  // Create char arrays with new %RH moisture data
  dtostrf(soilMoistureValue, 6, 2, soilMoistureRHChar);

  //Print new values on tft screen
  printValuesTftScreen(); 

  //Print new values on serial
  Serial.print("Moisture: ");
  Serial.println(soilMoistureValue);
  Serial.print("Humidity: ");
  Serial.println(airHumidityValue);
  Serial.print("Temperature: ");
  Serial.println(airTemperatureValue);
  Serial.print("Light: ");
  Serial.println(lightValue);

  // Create jsons for atmosphere
  // Moisture
  String jsonSoilMoisture = createAtmosphereJson ("moisture", atof(soilMoistureChar));

  //Air humidity
  String jsonAirHumidity = createAtmosphereJson ("humidity", atof(airHumidityChar));

  //Air Temperature
  String jsonAirTemperature = createAtmosphereJson ("temperature", atof(airTemperatureChar));

  //Light
  String jsonLight = createAtmosphereJson ("light", (float) lightValue);

  // Get token from atmosphere
  getToken();
  
  // Calculate the lenght of moisture's json, if moisture's value is an integer content Lenght is less
  String lenghtJsonMoisture;
  if(soilMoistureValue >= 100) {
   if((ceilf(soilMoistureValue) == soilMoistureValue)) lenghtJsonMoisture = "91";
   else lenghtJsonMoisture = "93";
  }
  else if(soilMoistureValue < 100 && soilMoistureValue >= 10) {
   if((ceilf(soilMoistureValue) == soilMoistureValue)) lenghtJsonMoisture = "90";
   else lenghtJsonMoisture = "92";
  }
  else if(soilMoistureValue < 10) {
   if((ceilf(soilMoistureValue) == soilMoistureValue)) lenghtJsonMoisture = "89";
   else lenghtJsonMoisture = "91";
  }

  // Make a HTTP request for moisture
  writeDataAtmosphere(jsonSoilMoisture, lenghtJsonMoisture, token, "moisture", client);
  
  // Calculate the lenght of humidity's json, if humidity's value is an integer content Lenght is less
  String lenghtJsonHumidity;
  if(airHumidityValue < 100 && airHumidityValue >= 10) {
   if(ceilf(airHumidityValue) == airHumidityValue) lenghtJsonHumidity = "89";
   else lenghtJsonHumidity = "91";
  }
  else if(airHumidityValue < 10) {
   if(ceilf(airHumidityValue) == airHumidityValue) lenghtJsonHumidity = "88";
   else lenghtJsonHumidity = "90";
  }

  // Make a HTTP request for humidity
  writeDataAtmosphere(jsonAirHumidity, lenghtJsonHumidity, token, "humidity", client);
  
  // Calculate the lenght of temperature's json, if temperature's value is an integer content Lenght is less
  String lenghtJsonTemperature;
  if(airTemperatureValue >= 10) {
   if(ceilf(airTemperatureValue) == airTemperatureValue) lenghtJsonTemperature = "93";
   else lenghtJsonTemperature = "95";
  }
  else if(airTemperatureValue < 10 && airTemperatureValue >= 0) {
   if(ceilf(airTemperatureValue) == airTemperatureValue) lenghtJsonTemperature = "92";
   else lenghtJsonTemperature = "94";
  }  

  // Make a HTTP request for temperature
  writeDataAtmosphere(jsonAirTemperature, lenghtJsonTemperature, token, "temperature", client);
  
  // Calculate the lenght of light's json
  String lenghtJsonLight;
  if (lightValue < 10) lenghtJsonLight = "87";
  else if (lightValue < 100) lenghtJsonLight = "88";
  else if (lightValue >= 100 && lightValue < 1000) lenghtJsonLight = "89";
  else if (lightValue >= 1000 && lightValue < 10000) lenghtJsonLight = "90";
  else if (lightValue >= 10000 && lightValue < 100000) lenghtJsonLight = "91";
  else if (lightValue >= 100000) lenghtJsonLight = "92";

  // Make a HTTP request for light
  writeDataAtmosphere(jsonLight, lenghtJsonLight, token, "light", client);        

  // Get scan interval from atmosphere
  getScanInterval(); 
  startMillis = millis();
  }
}


void writeDataAtmosphere(String jsonData, String contentLenght, String atmosphereToken, String feature, WiFiClient wifiClient){

  Serial.println(jsonData);
  bool ok = false;
  
  while(ok != true){
    checkWifiConnection();
    checkAtmosphereConnection();
    Serial.println("Sending " + feature + " data");
    // Make a HTTP request for write data to atmosphere
    wifiClient.println("POST /v1/measurements HTTP/1.1");
    wifiClient.println("Host: test.atmosphere.tools");
    wifiClient.println("Content-Type: application/json");
    wifiClient.println("Authorization:" + atmosphereToken);
    wifiClient.println("Content-Length: " + contentLenght);
    wifiClient.println("User-Agent: ArduinoTest");
    wifiClient.println();
    wifiClient.println(jsonData);

    int countFeature = 0;
    //Wait until client receive response for max 20 seconds
    while(wifiClient.available() == 0 && countFeature <= 20) {
      countFeature++;
      delay(100);
      Serial.print("Waiting client response ");
      Serial.println(countFeature);
    }
    // Check HTTP status
    char statusRequest[32] = {0};
    wifiClient.readBytesUntil('\r', statusRequest, sizeof(statusRequest));

    // It should be "HTTP/1.0 200 OK" or "HTTP/1.1 200 OK"
    if (strcmp(statusRequest + 9, "200 OK") != 0) {
    Serial.print(F("Unexpected response for " + feature + " :"));
    Serial.println(statusRequest); 
    //delay(delayFeature);
    wifiClient.flush();
    }
    else {
      Serial.println(feature + " 200 OK");
      ok = true;
      
      //Skip responses from the client that aren't read yet
      // }]} is the end of the body of last response, so with this the client goes to the end of response
      wifiClient.find("}]}");
      return;
    }
  }
}

// Create jsons for atmosphere
String createAtmosphereJson (String feature, float value){  
  
StaticJsonDocument<100> jsonDocument;
jsonDocument["thing"] = "plant";
jsonDocument["feature"] = feature;
jsonDocument["device"] = "plant-monitor";
JsonArray jsonArraySamples = jsonDocument.createNestedArray("samples");
JsonObject jsonObjectValues = jsonArraySamples.createNestedObject();
jsonObjectValues["values"] = value;
String json;
serializeJson(jsonDocument, json);
return json;
}

void connectToWifi(){
  while (wifiStatus != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(wifiSsid);
    // Connect to WPA/WPA2 network:
    wifiStatus = WiFi.begin(wifiSsid, wifiPass);

    // Wait 10 seconds for connection:
    delay(10000);
  }

  // You're connected now, so print out the data:
  Serial.println("You're connected to the network");
  return;
}

void checkWifiConnection() {
  if(wifiStatus != WL_CONNECTED) {
    Serial.println("No connection with network");
    connectToWifi();
    return;
  }
  else return; 
}

void getScanInterval() {
  // Make a HTTP request for get the scan interval
  bool okScanInterval = false;

  while(okScanInterval != true){
    checkWifiConnection();
    checkAtmosphereConnection();
    client.println("GET /v1/scripts/plant-monitor-script HTTP/1.1");
    client.println("Host: test.atmosphere.tools");
    client.println("Authorization:" + token);
    client.println("User-Agent: ArduinoTest");
    client.println();

    int countScanInterval = 0;
    //Wait until client receive response for max 20 seconds
    while(client.available() == 0 && countScanInterval <= 20) {
      countScanInterval++;
      delay(100);
      Serial.print("Waiting client response ");
      Serial.println(countScanInterval);
    }
    // Check HTTP status
    char statusScanInterval[32] = {0};
    client.readBytesUntil('\r', statusScanInterval, sizeof(statusScanInterval));
          
    // It should be "HTTP/1.0 200 OK" or "HTTP/1.1 200 OK"
    if (strcmp(statusScanInterval + 9, "200 OK") != 0) {
      Serial.print(F("Unexpected response for scan interval: "));
      Serial.println(statusScanInterval); 
      //delay(delayScanInterval);
      client.flush();
    }
    else {
      Serial.println("ScanInterval 200 OK");
      // Skip HTTP headers
      if (!client.find(endOfHeaders)) {
        Serial.println(F("Invalid response for scan interval"));
        //delay(1000);
        client.flush();
      }
      else{
        okScanInterval = true;
        // Parse JSON object
        StaticJsonDocument<100> jsonDocumentScanInterval;
        deserializeJson(jsonDocumentScanInterval, client);
        String jsonScanInterval;
        serializeJson(jsonDocumentScanInterval, jsonScanInterval);
        int newScanInterval = jsonDocumentScanInterval["code"].as<int>();
        Serial.print("New Scan Interval: ");
        Serial.println(newScanInterval);
        if(newScanInterval > 0 && newScanInterval != scanInterval){
          scanInterval = newScanInterval;
          // Hour * 60 (minutes) * 60 (seconds) * 1000 (milliseconds that forms one second)
          millisScanInterval = (scanInterval * 3600000);
        }
        return;
      }
    }
  }
}  

void getSensorsData(){
 soilMoistureValue, airHumidityValue, airTemperatureValue = 0;

 // For better accuracy we take 100 values of moisture, humidity and temperature
 for(int i = 99; i >= 0; i--){
  soilMoistureValue = soilMoistureValue + analogRead(soilMoisturePin); 
  airHumidityValue = airHumidityValue + dht.readHumidity();
  airTemperatureValue = airTemperatureValue + dht.readTemperature();
  delay(100);
 }

 //Divide by the times that we take values
 soilMoistureValue = soilMoistureValue / 100.0;
 airHumidityValue = airHumidityValue / 100.0;
 airTemperatureValue = airTemperatureValue / 100.0;


 //Round found values to one decimal digit
 soilMoistureValue = soilMoistureValue * 10;
 airHumidityValue = airHumidityValue * 10;
 airTemperatureValue = airTemperatureValue * 10;
 soilMoistureValue = round(soilMoistureValue);
 airHumidityValue = round(airHumidityValue);
 airTemperatureValue = round(airTemperatureValue);
 soilMoistureValue = soilMoistureValue / 10;
 airHumidityValue = airHumidityValue / 10;
 airTemperatureValue = airTemperatureValue / 10;

 //Get a new Adafruit sensor event
 sensors_event_t event;
 light_sensor.getEvent(&event);
 lightValue = event.light;
}

void printValuesTftScreen() {
 //Clean tft screen from previous results
 tftScreen.stroke(0, 0, 255);
 tftScreen.fill(0, 0, 255);
 tftScreen.rect(0, 18, 98, 16);
 tftScreen.rect(0, 55, 98, 14);
 tftScreen.rect(0, 90, 98, 19);
 tftScreen.rect(66, 110, 74, 20);

 //Print results on tft screen
 tftScreen.stroke(0, 255, 0);
 tftScreen.setTextSize(2);
 tftScreen.text(soilMoistureRHChar,22,18);
 tftScreen.text(airHumidityChar,10,55);
 tftScreen.text(airTemperatureChar,10,90);
 tftScreen.text(lightChar,70,110);  
}  

void getToken() {
  // Make a HTTP request for get the token
  bool okToken = false;
  checkWifiConnection();
  connectToAtmosphere();

  while(okToken != true){
    checkWifiConnection();
    checkAtmosphereConnection();
    client.println("POST /v1/login HTTP/1.1");
    client.println("Host: test.atmosphere.tools");
    client.println("Content-Type: application/json");
    client.println("Content-Length: 84");
    client.println("User-Agent: ArduinoTest");
    client.println();
    client.println(jsonLogin);

    int countLogin = 0;
    //Wait until client receive response for max 20 seconds
    while(client.available() == 0 && countLogin <= 20) {
      countLogin++;
      delay(100);
      Serial.print("Waiting client response ");
      Serial.println(countLogin);
    }
    // Check HTTP status
    char statusToken[32] = {0};
    client.readBytesUntil('\r', statusToken, sizeof(statusToken));
  
    // It should be "HTTP/1.0 200 OK" or "HTTP/1.1 200 OK"
    if (strcmp(statusToken + 9, "200 OK") != 0) {
      Serial.print(F("Unexpected response for login: "));
      Serial.println(statusToken); 
      //delay(delayLogin);
      client.flush();
    }
    else {
      Serial.println("Login 200 OK");
      // Skip HTTP headers
      if (!client.find(endOfHeaders)) {
        Serial.println(F("Invalid response for token"));
        client.flush();
      }
      else{
        // Parse JSON object
        okToken = true;
        StaticJsonDocument<450> jsonDocumentToken;
        deserializeJson(jsonDocumentToken, client);
        token = jsonDocumentToken["token"].as<String>();
        Serial.print("Token: ");
        Serial.println(token);
        return;
      }  
    }
  }
}

void connectToAtmosphere() {
 bool isConnected = false;
 Serial.println("Starting connection to atmosphere...");
 while(isConnected == false) {// if you get a connection, report back via serial:
  if (client.connect("test.atmosphere.tools", 80)) {
    Serial.println("Connected to atmosphere");
    isConnected = true;
    return;
  }
 }  
}

void checkAtmosphereConnection() {
  // Delete responses if are still there
  client.flush();
  if(client.connected() == false) {
    connectToAtmosphere();
    return;
  }
  else return;
}
