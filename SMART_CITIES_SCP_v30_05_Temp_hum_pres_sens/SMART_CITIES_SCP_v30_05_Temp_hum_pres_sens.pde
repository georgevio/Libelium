#include <WaspSensorCities_PRO.h>

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

void setup(){
  USB.println(F("Temperature, humidity and pressure sensor example"));
}

void loop(){
  // 1. Turn on the sensor
  bme.ON();

  // 2. Read sensors
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();

  // And print the values via USB
  USB.println(F("***************************************"));
  USB.print(F("Temperature: "));
  USB.printFloat(temperature, 2);
  USB.println(F(" Celsius degrees"));
  USB.print(F("RH: "));
  USB.printFloat(humidity, 2);
  USB.println(F(" %"));
  USB.print(F("Pressure: "));
  USB.printFloat(pressure, 2);
  USB.println(F(" Pa"));

  // 3. Turn off the sensor
  bme.OFF();

  // 4. Sleep

  // Go to deepsleep
  // After 10 seconds, Waspmote wakes up thanks to the RTC Alarm
  USB.println(F("Go to deep sleep mode..."));
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.println(F("Wake up!!\r\n"));
}


