const int knockSensor = A0;
const int led = 13;
const int threshold = 10;

int sensorReading = 0;

void setup() {
  pinMode(led, OUTPUT);
  digitalWrite(led, HIGH);
  Serial.begin(9600);
  Serial.println("Nerf Target v0.0.1, github.com/mcoms/nerf-target, 2014.");
}

void loop() {
  sensorReading = analogRead(knockSensor);
  if (sensorReading > threshold) {
    String packet = String("NP,") + millis() + String(',') + sensorReading;
    Serial.println(packet);
    digitalWrite(led, LOW);
  }
  delay(100);
  digitalWrite(led, HIGH);
}
