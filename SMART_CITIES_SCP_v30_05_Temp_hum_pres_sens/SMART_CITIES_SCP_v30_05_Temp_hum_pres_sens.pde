#include <WaspSensorCities_PRO.h>
#include <WaspXBee802.h>

/*
   Waspmote OEM. Possibilities for this sensor:
    - SOCKET_1
    - SOCKET_2
    - SOCKET_3
    - SOCKET_4
    - SOCKET_5
   P&S! Possibilities for this sensor:
    - SOCKET_A
    - SOCKET_B
    - SOCKET_C
    - SOCKET_E
    - SOCKET_F
*/

/* MAKE SURE YOU FIND THE CORRECT SOCKET! */
bmeCitiesSensor  bme(SOCKET_E);

float temperature;	// Stores the temperature in ºC
float humidity;		// Stores the realitve humidity in %RH
float pressure;		// Stores the pressure in Pa

uint8_t error;

void setup(){
  USB.println(F("**** Temperature, humidity and pressure sensor example ****"));
  RTC.ON();
  xbee802.ON();

  USB.print(F("RTC INITIAL Time:"));
  USB.println(RTC.getTime());
  
  // Show '_serial_id' stored by the API when powering up
  USB.print(F("Global variable '_serial_id':"));
  for (int i=0;i<8;i++){
    USB.printHex(_serial_id[i]);
  }
  USB.println();
}


void loop(){

  bme.ON();
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();
  
  USB.println(F("*********** TEMP-HUM-PRESS ***************"));
  USB.print(F("Temperature: "));
  USB.printFloat(temperature, 2);
  USB.println(F(" Celsius degrees"));
  USB.print(F("RH: "));
  USB.printFloat(humidity, 2);
  USB.println(F(" %"));
  USB.print(F("Pressure: "));
  USB.printFloat(pressure, 2);
  USB.println(F(" Pa"));

  bme.OFF();
  delay(4000);

  /*
  // 4. deepSleep for 10 sec
  USB.println(F("Go to deep sleep mode..."));
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.println(F("Wake up!!\r\n"));
  */
}


