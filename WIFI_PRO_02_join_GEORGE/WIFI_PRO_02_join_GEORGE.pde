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

  /* Connection was ALREADY SET in STEP 1 
   * No need to setup again 
   */
  USB.println(F(WIFI_PRO.ON(socket))); 

}

void loop(){
  USB.println(F("\n---- ENTERING loop() --------"));
  
  status = WIFI_PRO.isConnected();
  USB.println(status,DEC);
  if ( status == true){ // If module is connected
    USB.print(F("2. WiFi is connected OK."));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous); 
    if (WIFI_PRO.ping("8.8.8.8") == 0){//google DNS
      USB.print(F("3. PING 8.8.8.8 OK. Round Trip Time(ms)="));
      USB.println( WIFI_PRO._rtt, DEC );
    }else{
      USB.println(F("3. Error in 'ping'")); 
    }
    
  }else{
    USB.print(F("2. WiFi is connected ERROR.")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

  frame.createFrame(ASCII); 
  frame.addSensor(SENSOR_STR, "George-Hello");
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());

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
  
  USB.print(F("Delay for 10 sec"));  
  delay(10000);
}






