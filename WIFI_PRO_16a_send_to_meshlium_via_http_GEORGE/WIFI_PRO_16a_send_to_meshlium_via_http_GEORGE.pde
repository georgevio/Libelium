#include <WaspWIFI_PRO.h> 
#include <WaspFrame.h>

uint8_t socket = SOCKET0;

// choose URL settings
char type[] = "http";
char host[] = "10.10.10.1";
char port[] = "80";

uint8_t error;
uint8_t status;
unsigned long previous;

char moteID[] = "node_BME280";

void setup() {
  USB.println(F("Start program"));  
  USB.println(F("***************************************"));  
  USB.println(F("Once the module is set with one or more"));
  USB.println(F("AP settings, it attempts to join the AP"));
  USB.println(F("automatically once it is powered on"));    
  USB.println(F("Refer to example 'WIFI_PRO_01' to configure"));  
  USB.println(F("the WiFi module with proper settings"));
  USB.println(F("***************************************"));
  
  frame.setID(moteID);  
}

void loop(){ 
  previous = millis();
  
  // 1. Switch ON
  error = WIFI_PRO.ON(socket);
  if (error == 0){    
    USB.println(F("WiFi switched ON"));
  }else{
    USB.println(F("WiFi did not initialize correctly"));
  }

  // 2. Join AP
  status =  WIFI_PRO.isConnected();
  if (status == true){    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);

    // 3.1. Create a new Frame (only ASCII)
    frame.createFrame(ASCII); 
    frame.addSensor(SENSOR_STR, "GEORGE");
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.showFrame();  /* Print the frame here */

    // 3.2. Send Frame to Meshlium
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
    if (error == 0){
      USB.println(F("HTTP OK"));          
      USB.print(F("HTTP Time from OFF state (ms):"));    
      USB.println(millis()-previous);
    }else{
      USB.println(F("Error calling 'getURL' function"));
      WIFI_PRO.printErrorCode();
    }
    
  }else{
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

  // 3. Switch OFF 
  //WIFI_PRO.OFF(socket);
  //USB.println(F("WiFi switched OFF\n\n")); 
  
  delay(3000);
}
