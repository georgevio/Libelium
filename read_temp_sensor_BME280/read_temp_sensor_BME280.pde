#include <WaspSensorEvent_v30.h>

float temp;
float humd;
float pres;
float value;

void setup(){
  USB.ON();
  USB.println(F("Read from expansion board, EVENTS"));
  
  Events.ON();
}

void loop(){
  temp = Events.getTemperature();
  humd = Events.getHumidity();
  pres = Events.getPressure();

  USB.println("-----------------------------");
  USB.print("Temperature: ");
  USB.printFloat(temp, 2);
  USB.println(F(" Celsius"));
  USB.print("Humidity: ");
  USB.printFloat(humd, 1); 
  USB.println(F(" %")); 
  USB.print("Pressure: ");
  USB.printFloat(pres, 2); 
  USB.println(F(" Pa")); 
  USB.println("-----------------------------");

  /*
  USB.println(F("Going into deep sleep mode"));
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(F("wake up\n"));
  */
  delay(5000);
}
