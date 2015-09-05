#include <SoftwareSerial.h>
SoftwareSerial esp8266(2, 3); // RX, TX
#define waterSensorPin = 13;
bool waterFull;

void setup()
{
  // Set up both ports at 9600 baud. This value is most important
  // for the XBee. Make sure the baud rate matches the config
  // setting of your XBee.
  esp8266.begin(9600);
  Serial.begin(9600);
  pinMode(waterSensorPin, INPUT);
}

void loop()
{
  waterFull = digitalRead(waterSensorPin);
  Serial.println(waterFull);
  esp8266.println("dataToSend[1] = {'Water Full', " + waterFull + "}");
  esp8266.println("logdata.lua");
  delay(1000);
}
