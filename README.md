Emotisphere
===========

Arduino, Processing, and Pure Data code for the Emotisphere emotion-to-music generator, created for CS 320 Tangible User Interfaces
Sara Burns, Galen Chuang, Shelley Wang

This repository contains the code used to read in sensor input, determine an emotional profile, and compose music accordingly. It also contains the source code for the project website.

To use:
Arduino: Open "gsr_pulse_combined.ino" and upload to an Arduino Uno.

Pure Data: In the Processing file, change the path to the Pure Data files to match the path on your computer. These files will run automatically when an emotional profile is determined. 

Processing: While the Arduino is connected to the computer via USB, run "gsr_pulse_combined.pde". Place hands on the Emotisphere sensors to activate recording and generate an emotional profile. Note any changes that need to be made (see code).

Implementation specifics:
Arduino: Uses 3.3v power and 115200 baud rate. Reads values from 4 reed sensors (digital), 1 PulseSensor, and two skin sensors (analog), and writes to two RGB LEDS (analog). Prints all values to the serial port, prepended by a character, which Processing then reads. Also reads from the serial port to change LED color.

Processing: Reads values from the serial port and uses values to calculate different aspects of EmotiSphere. Reed sensors = volume, PulseSensor = PureData patch tempo (mapped) and volume, and skin sensor = profile. Also changed LED lights based on profile or recording status.
