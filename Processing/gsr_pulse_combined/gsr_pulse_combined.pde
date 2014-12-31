//Processing code to run after uploading Arduino code. Last updated by Galen, 12.16.14. Still buggy.
//May have to change your serial port (line 82) to a different number in the array. Also, file paths need to be changed.

//key for characters in serial port: A = gsr value, S = pulse signal, B = pulse BPM
//Q = pulse IBI, r = red led, g = green led, b = blue led, w = white led, w-z = reed

import processing.serial.*;
PFont font;
Scrollbar scaleBar;  

boolean fileWritten = false; //write file
boolean isStable = false; //when to write file
int timeBeforeRecording;
int recordingTime;
boolean timeStored = false;
boolean blink = true;

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 512; 
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced
boolean pulseRecorded = false;

//skin sensor variables
String TIME_COLUMN = "time";
String DATA_COLUMN = "nervous";
Table table;
Serial myPort;
String[] profile = new String[1]; //holds one number of profile
int gsr;
boolean profRecorded = false;

//reed sensor vars
int reedInt1 = 0;
int reedInt2 = 0;
int reedInt3 = 0;
int reedInt4 = 0;
int preReed = 0;
int currReed = 0;
int currVolume = 60;
String[] currVolumeArray= new String[1];
boolean[] reedBools = new boolean[4];

void setup() {
  size(700, 600);  // Stage size
  frameRate(100);  
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);  
// Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  scaleBar = new Scrollbar (400, 575, 180, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75;                               // initialize scale of heartbeat window
    
// set the visualizer lines to 0
 for (int i=0; i<rate.length; i++){
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window 
   }
 for (int i=0; i<RawY.length; i++){
    RawY[i] = height/2; // initialize the pulse window data line to V/2
 }
   
// GO FIND THE ARDUINO
    println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  myPort = new Serial(this, Serial.list()[0], 115200);  // make sure Arduino is talking serial at this baud rate
  myPort.clear();            // flush buffer
  myPort.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
}
  
void draw() {
  controlVolume();
  background(0);
  noStroke();
// DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES  
  fill(eggshell);  // color for the window background
  rect(255,height/2,PulseWindowWidth,PulseWindowHeight);
  rect(600,385,BPMWindowWidth,BPMWindowHeight);
  
// DRAW THE PULSE WAVEFORM
  // prepare pulse data points    
  RawY[RawY.length-1] = (1023 - Sensor) - 212;   // place the new raw datapoint at the end of the array
  zoom = scaleBar.getPos();                      // get current waveform scale value
  offset = map(zoom,0.5,1,150,0);                // calculate the offset needed at this scale
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
  }
  stroke(250,0,0);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < ScaledY.length-1; x++) {    
    vertex(x+10, ScaledY[x]);                    //draw a line connecting the data points
  }
  endShape();
  
// DRAW THE BPM WAVE FORM
// first, shift the BPM waveform over to fit then next data point only when a beat is found
 if (beat == true){   // move the heart rate line over one pixel every time the heart beats 
   beat = false;      // clear beat flag (beat flag waset in serialEvent tab)
   for (int i=0; i<rate.length-1; i++){
     rate[i] = rate[i+1];                  // shift the bpm Y coordinates over one pixel to the left
   }
// then limit and scale the BPM value
   BPM = min(BPM,200);                     // limit the highest BPM value to 200
   float dummy = map(BPM,0,200,555,215);   // map it to the heart rate window Y
   rate[rate.length-1] = int(dummy);       // set the rightmost pixel to the new data point value
 } 
 // GRAPH THE HEART RATE WAVEFORM
 stroke(250,0,0);                          // color of heart rate graph
 strokeWeight(2);                          // thicker line is easier to read
 noFill();
 beginShape();
 for (int i=0; i < rate.length-1; i++){    // variable 'i' will take the place of pixel x position   
   vertex(i+510, rate[i]);                 // display history of heart rate datapoints
 }
 endShape();
 
// DRAW THE HEART AND MAYBE MAKE IT BEAT
  fill(250,0,0);
  stroke(250,0,0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
  heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  heart = max(heart,0);       // don't let the heart variable go into negative numbers
  if (heart > 0){             // if a beat happened recently, 
    strokeWeight(8);          // make the heart big
  }
  smooth();   // draw the heart with two bezier curves
  bezier(width-100,50, width-20,-20, width,140, width-100,150);
  bezier(width-100,50, width-190,-20, width-200,140, width-100,150);
  strokeWeight(1);          // reset the strokeWeight for next time


// PRINT THE DATA AND VARIABLE VALUES
  fill(eggshell);                                       // get ready to print text
  text("Pulse Sensor Amped Visualizer 1.1",245,30);     // tell them what you are
  text("IBI " + IBI + "mS",600,585);                    // print the time between heartbeats in mS
  text(BPM + " BPM",600,200);                           // print the Beats Per Minute
  text("Pulse Window Scale " + nf(zoom,1,2), 150, 585); // show the current scale of Pulse Window
  
//  DO THE SCROLLBAR THINGS
  scaleBar.update (mouseX, mouseY);
  scaleBar.display();
   
   //to configure start of recording and corresponding LED behavior
   if (!pulseRecorded && !profRecorded && gsr > 0) {
     if (!timeStored) {
     timeBeforeRecording = millis();
     timeStored = true;
      }
      
      recordingTime = millis()-timeBeforeRecording;
      // print("time since start of recording: " + recordingTime + "\n");
        
      if (blink) {
         myPort.write(108);
         blink = false;
      }
        
      if (recordingTime >= 5000) {
         blink = false;
         determineProfile(gsr);
      }
   }
} //end of draw 

void serialEvent(Serial myPort){ 
   for (int i = 0; i <= reedBools.length - 1; i++) {
   reedBools[i] = false;
  }
  
   String inData = myPort.readStringUntil('\n');
   
   if ( inData != null ) {
      print(inData);
   inData = trim(inData);                 // cut off white space (carriage return)
   
   if (inData.charAt(0) == 'S'){          // leading 'S' for sensor data
     inData = inData.substring(1);        // cut off the leading 'S'
     Sensor = int(inData);                // convert the string to usable int
   }
   if (inData.charAt(0) == 'B'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = int(inData);                   // convert the string to usable int
     beat = true;                         // set beat flag to advance heart rate graph
     heart = 20;                          // begin heart image 'swell' timer
   }
 if (inData.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inData = inData.substring(1);        // cut off the leading 'Q'
     IBI = int(inData);                   // convert the string to usable int
   }
   //pulse
   if (inData.charAt(0) == 'A'){          // skin sensor data
     inData = inData.substring(1);        // cut off the leading 'A'
     gsr = int(inData);                   // convert the string to usable int
   }
   
   //magnet stuff
    if (inData.charAt(0) == 'w'){          // reed sensor 1
     inData = inData.substring(1);        // cut off the leading char
     reedInt1 = int(inData);                // convert the string to usable int
     if (reedInt1 == 1) reedBools[0] = true;
   }
      if (inData.charAt(0) == 'x'){          // reed sensor 2
     inData = inData.substring(1);        // cut off the leading char
     reedInt2 = int(inData);                // convert the string to usable int
     if (reedInt2 == 1) reedBools[1] = true;
   }
   if (inData.charAt(0) == 'y'){          // reed sensor 3
     inData = inData.substring(1);        // cut off the leading char
     reedInt3 = int(inData);                // convert the string to usable int
     if (reedInt3 == 1) reedBools[2] = true;
   }
   if (inData.charAt(0) == 'z'){          // reed sensor 4
     inData = inData.substring(1);        // cut off the leading char
     reedInt4 = int(inData);                // convert the string to usable int
     if (reedInt4 == 1) reedBools[3] = true;
   }
   }
}

void blinkRecord() 
{
   myPort.write(108); //to get led to flash while recording
}

//method for gsr to determine profile after stabilization and save file
void determineProfile(int gsr) {
  String recNumFile = "C:/Users/Sara/Documents/recnumber.txt";
 
  String pulseFilename = "C:/Users/Sara/Documents/pulse.txt";
  String[] pulseArr = new String[1];
  String pulse = str(BPM);
  pulseArr[0] = pulse;

  print("BPM: " + BPM + "\n");
  //pulse
   saveStrings(pulseFilename,pulseArr);
   pulseRecorded = true;

//skin sensor
    print("stabilized\n");
    if (gsr >= 30 && BPM >= 100) { //sets the threshold
      profile[0] = "1";
      myPort.write(114); //red
      print("you are agitated\n");
      open("data/agitated.pd"); //open agitated pd file
      profRecorded = true;
    } else {
      profile[0] = "0";
       myPort.write(98); //blue
       print("you are calm\n");
      open("data/relaxed.pd"); //open calm pd file
      profRecorded = true;
    }
    
    int recnumber_temp = int(loadStrings(recNumFile)[0]);
    recnumber_temp += 1;
  String[] recnumber = new String[]{str(recnumber_temp)};
    saveStrings(recNumFile, recnumber);
    }
    
    void controlVolume() {
  
  //first initialized, no volume changes
 if (currReed == 0 && preReed == 0) { 
     for (int i = 0; i <= reedBools.length-1; i++) {
       //println("i: " + i + " status: " + reedBools[i]);
    if (reedBools[i]) {
      preReed = i+1; //last reed sensor to be activated
      //println("preReed initial: " + preReed );
    }
    }
  }
  //-------------------------------
  
  //logic for reed sensors to control volume
    if (currReed == 0 && preReed != 0) {
        for (int j = 0; j <= reedBools.length-1; j++) {
         // println("preReed next: " + preReed );
    if (reedBools[j] && preReed != j+1) {
      currReed = j+1; //currently activated reed sensor
        println("currReed: " + currReed);
       println("preReed: " + preReed); //if current is different from previous
       //update value of currReed
        }
        }
        
         if ((currReed == 1 && preReed == 4) || (currReed == 2 && preReed == 1) || (currReed == 3 && preReed == 2) 
         || (currReed == 4 && preReed == 3)) {
        print("increase volume\n");
        currVolume += 20;
        if (currVolume > 127) currVolume = 127;
        currVolumeArray[0] = str(currVolume);
        saveStrings("C:/Users/Sara/Documents/volume.txt",currVolumeArray);
        
       println("currReed after increase: " + currReed);
       println("preReed after increase: " + preReed); 
      }
   
        if ((currReed == 4 && preReed == 1) || (currReed == 1 && preReed == 2) || (currReed == 2 && preReed == 3) 
         || (currReed == 3 && preReed == 4)) {
        print("decrease volume\n");
        currVolume -= 20;
        if (currVolume < 0) currVolume = 0;
        currVolumeArray[0] = str(currVolume);
         saveStrings("C:/Users/Sara/Documents/volume.txt",currVolumeArray);
      }
      
      if (currReed != 0) preReed = currReed; //last reed sensor to be activated
      currReed = 0;    
        }
    }
