#include <WaspSensorGas_Pro.h>

/*
 * Waspmote OEM. Possibilities for this sensor:
 *   - CENTRAL SOCKET
 * P&S! Possibilities for this sensor:
 *  - SOCKET_E
 */
bmeGasesSensor  bme;

uint8_t socket = SOCKET0;


float temperature;  // Stores the temperature in ºC
float humidity;   // Stores the realitve humidity in %RH
float pressure;   // Stores the pressure in Pa

void setup()
{
  USB.ON();
  USB.println(F("Temperature, humidity and pressure sensor example"));
}

void loop()
{
  /* 1. Turn on the sensor */
  bme.ON();

  /* 2. Read sensors */
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();

  USB.println(F("***************************************"));
  USB.print(F("Temperature: "));
  USB.print(temperature);
  USB.println(F(" Celsius degrees"));
  USB.print(F("RH: "));
  USB.print(humidity);
  USB.println(F(" %"));
  USB.print(F("Pressure: "));
  USB.print(pressure);
  USB.println(F(" Pa"));

  /* 3. Turn off the sensor */
  bme.OFF();

  /* 3. Sleep
   * After 3 minutes, Waspmote wakes up thanks to the RTC Alarm */
  USB.println(F("Go to deep sleep mode..."));
  PWR.deepSleep("00:00:00:05", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  USB.ON();
  USB.println(F("Wake up!!\r\n"));
}
