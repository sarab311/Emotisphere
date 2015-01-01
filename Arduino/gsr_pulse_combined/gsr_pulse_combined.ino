//Arduino code to print reed sensor, skin sensor, and PulseSensor input to serial port. Still buggy.
//Last edited: Galen, 1.2.15

//key for characters in serial port: A = gsr value, S = pulse signal, B = pulse BPM
//Q = pulse IBI, R = red led, G = green led, B = blue led, W = white led, w-z = reed sensors

//reed sensor Arduino pins
int pushButtonA = 12;
int pushButtonB = 11;
int pushButtonC = 9;
int pushButtonD = 10;

//LED Arduino pins
int r_led = 5;
int g_led = 6;
int b_led = 7;

//Skin sensor pin
gsr_pin = 0;

int pulsePin = 1;                   // PulseSensor Arduino pin
volatile int BPM;                   // used to hold the pulse rate
volatile int Signal;                // holds the incoming raw data
volatile int IBI = 600;             // holds the time between beats, must be seeded! 
volatile boolean Pulse = false;     // true when pulse wave is high, false when it's low
volatile boolean QS = false;        // becomes true when Arduoino finds a beat.

void setup() { 
  Serial.begin(115200);
  interruptSetup();
  analogReference(EXTERNAL);        // Using 3.3v
  pinMode(r_led, OUTPUT);
  pinMode(g_led, OUTPUT);
  pinMode(b_led, OUTPUT);
  pinMode(pushButtonA, INPUT);
  pinMode(pushButtonB, INPUT);
  pinMode(pushButtonC, INPUT);
  pinMode(pushButtonD, INPUT);
}

void loop(){
  //gsr
  int a=analogRead(gsr_pin);
  Serial.print('A');
  Serial.println(a);
  
  //pulse
  sendDataToProcessing('S', Signal);     // send Processing the raw Pulse Sensor data
  if (QS == true){                       // Quantified Self flag is true when arduino finds a heartbeat
    sendDataToProcessing('B',BPM);   // send heart rate with a 'B' prefix
    sendDataToProcessing('Q',IBI);   // send time between beats with a 'Q' prefix
    QS = false;                      // reset the Quantified Self flag for next time    
 }
 
 //reed stuff to print to serial port
  int buttonStateA = digitalRead(pushButtonA);
  int buttonStateB = digitalRead(pushButtonB);
  int buttonStateC = digitalRead(pushButtonC);
  int buttonStateD = digitalRead(pushButtonD);
  Serial.print('w');
  if (buttonStateA == 1) Serial.println('0');
  else Serial.println('1');
  delay(5);
  Serial.print('x');
  if (buttonStateB == 1) Serial.println('0');
  else Serial.println('1');
  delay(5);
  Serial.print('y');
  if (buttonStateC == 1) Serial.println('0');
  else Serial.println('1');
  delay(5);
  Serial.print('z');
  if (buttonStateD == 1) Serial.println('0');
  else Serial.println('1');
  delay(5);        // delay in between reads for stability
 
 //make led color of mood
  int input = Serial.read();
  if (input == 'r') setColor(255,0,0);
  if (input == 'g') setColor(0,255,0);
  if (input == 'b') setColor(0,0,255);  
  if (input == 'w') setColor(255,255,255);
  if (input == 'o') setColor(0,0,0);
  if (input == 'l') setColor(255,255,255);
  
  delay(20);                             //  take a break
}

//helper methods------------------------------------------------------------------

void sendDataToProcessing(char symbol, int data )
{
  Serial.print(symbol);                // symbol prefix tells Processing what type of data is coming
  Serial.println(data);                // the data to send culminating in a carriage return
}

void setColor(int red, int green, int blue)     //To set LED color
{
  analogWrite(r_led, red);
  analogWrite(g_led, green);
  analogWrite(b_led, blue);
}
