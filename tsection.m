#include "mbed.h"
#include "physcom.h"

using namespace physcom;

M3pi robot;    // create an object of type M3pi

int main() {
   robot.sensor_auto_calibrate();  // robot executes calibration of active opto-sensors

   int sensors[5];
   robot.calibrated_sensors(sensors);       // 5 calibrated values are read in a vector
   
   // as long as sensors 1 and 3 (next to the middle sensor) return a value below 900 (very 
   // close to black) execute the following
   while (sensors[1] < 900 || sensors[3] < 900) {
      // ??DO WE NEED THIS??
      robot.calibrated_sensors(sensors);   // 5 values are read in a vector
      // ??DO WE NEED THIS??
      if(sensors[1] > 500 ) {
         robot.activate_motor (1,0.2);    // drive right motor 2/10 max speed forward
      } else if(sensors[3] > 500) {
         robot.activate_motor (0,0.2) ;   // drive left motor 2/10 max speed forward
      } else {
         robot.activate_motor (0,0.1);    // drive left motor 1/10 max speed forward
         robot.activate_motor (1,0.1) ;   // drive right motor 1/10 max speed forward
      }
   }
   robot.activate_motor (1,0);  // stop left motor
   robot.activate_motor (0,0);  // stop right motor
}