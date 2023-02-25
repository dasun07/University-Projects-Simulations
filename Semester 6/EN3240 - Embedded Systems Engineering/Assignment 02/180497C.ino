// Index: 180497C

// Function used to determine the on/off interval of led:
// on/off interval = 500 + 4500*(max parameter value - current parameter value)/(max parameter value - parameter threshold)

// when the current parameter value is slightly above threshold, on/off interval will be close to 5000
// when the current parameter value is close to the max parameter value, on/off interval will be close to 500 

// Basic ESP8266 MQTT example provided in Arduino, was used as reference/ template
// The code was run and tested on ESP32
// If an ESP8266 is used during the evaluation of this assignment, replace WiFi.h with ESP8266WiFi.h

#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "HDMP";
const char* password = "Krewella1998";
const char* mqtt_server = "test.mosquitto.org";
const char* inTopic ="180497c_en3240";
char* variable;
int blinkDelay;


WiFiClient espClient;
PubSubClient mqttClient(espClient);
unsigned long lastMsg = 0;

#define MSG_BUFFER_SIZE	(50)

char msg[MSG_BUFFER_SIZE];
int value = 0;

// Setting up and connecting to a wifi network
void setup_wifi() {

  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("Connected to WiFi successfully");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

// blinkDelay is set using the payload 
void callback(char* topic, byte* payload, unsigned int length) {
  String num = "";
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");

  for (int i = 0; i < length; i++) {
    num += (char)payload[i];
  }

  blinkDelay = num.toInt();
  Serial.println();

  if ((char)payload[0] == '1') {
    digitalWrite(BUILTIN_LED, LOW);
  } else {
    digitalWrite(BUILTIN_LED,HIGH);
  }

}

// Function to re-establish the MQTT connection
void reconnect() {
  while (!mqttClient.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);
    
    if (mqttClient.connect(clientId.c_str())) {
      Serial.println("connected successfully");
      mqttClient.subscribe(inTopic);
    } 
    else {      
      Serial.print("failed to connect, rc=");
      Serial.print(mqttClient.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  // Initializing the BUILTIN_LED pin as an output
  pinMode(BUILTIN_LED, OUTPUT);     
  Serial.begin(115200);
  setup_wifi();
  mqttClient.setServer(mqtt_server, 1883);
  mqttClient.setCallback(callback);
}

void loop() {
  
  if (!mqttClient.connected()) {
    reconnect();
  }
  mqttClient.loop();
  if (blinkDelay!=0) {
      Serial.println("......................................");
      Serial.println("The parameter has exceeded the limit!");
      Serial.print("The corresponding led on/off interval (in ms): ");
      digitalWrite(BUILTIN_LED, LOW); 
      Serial.println(blinkDelay);
      Serial.println("......................................");
      delay(blinkDelay);
      digitalWrite(BUILTIN_LED, HIGH); 
      delay(blinkDelay);
  
  }
 
  else {
    digitalWrite(BUILTIN_LED, LOW); 
    
     
  }

}
