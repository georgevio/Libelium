#include <WaspWIFI_PRO.h>
#include <WaspFrame.h>

char ESSID[] = "Robby_1";
char PASSW[] = " ";

uint8_t socket = SOCKET1;
unsigned long previous;
uint8_t error;
uint8_t status;

void setup(){
  USB.ON();
  USB.println(F("WIFI_PRO_ALL_GEORGE"));  

  // 1. Switch ON the WiFi module
  //if( WIFI_PRO.ON(socket)){
  USB.println(F(WIFI_PRO.ON(socket))); 
  
  //else{
   // USB.println(F("ERROR setting WIFI_PRO.ON(socket)")); 
  
  /*
  error=WIFI_PRO.ON(socket);
  USB.print(F("Turning wifi on: "));
  USB.println(error,DEC);
   
  if (WIFI_PRO.ON(socket) == 0){    
    USB.println(F("1. WiFi switched ON"));
  }else{
    USB.println(F("1. WiFi did not initialize correctly"));
  }  

  // 2. Reset to default values
  if (WIFI_PRO.resetValues() == 0){    
    USB.println(F("2. WiFi reset to default"));
  }else{
    USB.println(F("2. WiFi reset to default ERROR"));
  }

  // 3. Set ESSID
  if (WIFI_PRO.setESSID(ESSID) == 0){    
    USB.println(F("3. WiFi set ESSID OK"));
  }else{
    USB.println(F("3. WiFi set ESSID ERROR"));
  }

  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  if (WIFI_PRO.setPassword(OPEN, PASSW) == 0){    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }else{
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }

  // 5. Software Reset 
  // Parameters take effect following either a 
  // hardware or software reset
  error = WIFI_PRO.softReset();
  if (error == 0){    
    USB.println(F("5. WiFi softReset OK"));
  }else{
    USB.println(F("5. WiFi softReset ERROR"));
  }

  previous = millis(); // get current time
  //frame.setID("george_01");

    */
}

void loop(){
  USB.println(F("\n---- ENTERING loop() --------"));
  
  status = WIFI_PRO.isConnected();
  USB.println(status,DEC);
  
  if ( status == true){ // If module is connected
    USB.print(F("2. WiFi is connected OK."));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous); 
/*
      if (WIFI_PRO.ping("8.8.8.8") == 0){//google DNS
        USB.print(F("3. PING 8.8.8.8 OK. Round Trip Time(ms)="));
        USB.println( WIFI_PRO._rtt, DEC );
      }else{
        USB.println(F("3. Error in 'ping'")); 
      }
*/      
    }else{
      USB.print(F("2. WiFi is connected ERROR.")); 
      USB.print(F(" Time(ms):"));    
      USB.println(millis()-previous);  
    }
/*
  // create new frame (only ASCII)
  frame.createFrame(ASCII); 
  
  // add sensor fields
  frame.addSensor(SENSOR_STR, "George-Hello");
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  
  // print frame
  frame.showFrame();

  // 3.2. Send Frame to Meshlium
  // http frame check response
  error = WIFI_PRO.sendFrameToMeshlium( "http","10.10.10.1","80", frame.buffer, frame.length);
  if ( error == 0){
    USB.println(F("HTTP OK"));          
    USB.print(F("HTTP Time from OFF state (ms):"));    
    USB.println(millis()-previous);
  }else{
    USB.println(F("Error calling 'getURL' function"));
    WIFI_PRO.printErrorCode();
  }

*/    
  USB.print(F("Delay for 10 sec"));  
  delay(10000);
}






