#include <WaspWIFI_PRO.h>
#include <WaspSensorEvent_v30.h> /* BME280, Events.ON()*/

uint8_t socket = SOCKET0;

uint8_t error;
uint8_t status;
unsigned long previous;

float temp,humd,pres;

void setup() {
  USB.ON();
  USB.println(F("Start program"));  
  USB.println(F("***************************************"));  
  USB.println(F("Once the module is set with one or more"));
  USB.println(F("AP settings, it attempts to join the AP"));
  USB.println(F("automatically once it is powered on"));    
  USB.println(F("Refer to example 'WIFI_PRO_01' to configure"));  
  USB.println(F("the WiFi module with proper settings"));
  USB.println(F("***************************************"));

  error = WIFI_PRO.ON(socket);
  if (error == 0){    
    USB.println(F("1. WiFi switched ON"));
  }else{
    USB.println(F("1. WiFi did not initialize correctly"));
  }  

  error = WIFI_PRO.setTimeServer("time.google.com");
  if (error == 0){    
    USB.println(F("1.1 Time set succesfully"));
  }else{
    USB.println(F("Time setting ERROR"));
  }  
  
  previous = millis();  
}

/********** LOOP ******************/
void loop(){
  // 2. Join AP
  status =  WIFI_PRO.isConnected();
  if (status == true){ 
    USB.print(F("2. WiFi is connected OK."));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);

    error = WIFI_PRO.ping("www.google.com");
    if (error == 0){				
      USB.print(F("3. PING OK. Round Trip Time(ms)="));
      USB.println( WIFI_PRO._rtt, DEC );
    }else{
      USB.println(F("3. Error calling 'ping' function")); 
    }
  }else{
    USB.print(F("2. WiFi is connected ERROR.")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

  /********* REAM BME280 SENSOR ************/
  Events.ON();
  temp = Events.getTemperature();
  humd  = Events.getHumidity();
  pres = Events.getPressure();   
  USB.println(F("************* BME380 *********")); 
  USB.print(F("Temperature: "));
  USB.print(temp);
  USB.println(F(" Celsius"));
  USB.print(F("Humidity: "));
  USB.print(humd);
  USB.println(F(" %"));  
  USB.print(F("Pressure: "));
  USB.print(pres);
  USB.println(F(" Pa"));  
  USB.println(); 
   
  delay(10000);
}






