Emotisphere
===========

Arduino, Processing, and Pure Data code for the Emotisphere emotion-to-music generator, created for CS 320 Tangible User Interfaces
Sara Burns, Galen Chuang, Shelley Wang

This repository contains the code used to read in sensor input, determine an emotional profile, and compose music accordingly. It also contains the source code for the project website.

To use:
Arduino: Open "gsr_pulse_combined.ino" and upload to an Arduino Uno

Pure Data: In the Processing file, change the path to the Pure Data files to match the path on your computer. These files will run automatically when an emotional profile is determined.

Processing: While the Arduino is connected to the computer via USB, run "gsr_pulse_combined.pde". Place hands on the Emotisphere sensors to activate recording and generate an emotional profile.

