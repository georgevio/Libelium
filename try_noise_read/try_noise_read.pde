#include <WaspSensorCities_PRO.h>
//char SPEED="SLOW_MODE";
uint8_t status;
  
void setup(){
  USB.ON(); 
  USB.println(F("*********Reading Noise Level Sensor*******"));
  noise.configure(); 
}

void loop(){
  status = noise.getSPLA(SLOW_MODE);
  if (status == 0) {
    USB.print(F("Sound Level - A-Weight (SLOW): "));
    USB.print(noise.SPLA);
    USB.println(F(" dBA"));
  }else{
    USB.println(F("[CITIES PRO] Communication error with the audio sensor (SLOW)"));
  }

  delay(20);
  
}
