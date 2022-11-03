#include <WaspXBeeDM.h>
#include <WaspFrame.h>

// Define BROADCAST MAC address
char RX_ADDRESS[] = "000000000000FFFF";

char WASPMOTE_ID[] = "node_01";

uint8_t error;

void setup(){
  // init USB port
  //USB.ON();
  USB.println(F("Sending BROADCAST packets example"));
  
  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee
  //xbeeDM.ON();
}


void loop(){

  // create new frame
  frame.createFrame(ASCII);  
  
  // add frame fields
  frame.addSensor(SENSOR_STR, "new_sensor_frame");
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  
  // 2. Send packet
  error = xbeeDM.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  if( error == 0 ){ // TX Flag
    USB.println(F("send ok"));
    
    // blink green LED
    Utils.blinkGreenLED();

  }
  else{
    USB.println(F("send error"));
    
    // blink red LED
    Utils.blinkRedLED();
  }

  // wait for five seconds
  delay(5000);
  USB.println(F("Delay 5 sec..."));
}
