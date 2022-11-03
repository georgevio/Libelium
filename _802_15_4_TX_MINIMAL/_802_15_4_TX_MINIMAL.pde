#include <WaspXBee802.h>
#include <WaspFrame.h>

/* Nov 02, 2022, Synced with github https://github.com/georgevio/libelium.git */

char RX_ADDRESS[] =     "000000000000FFFF"; /* BROADCAST */
//char RX_ADDRESS[] =   "0013A20041678A0E"; /* AP MEshlium MAC */
//char RX_ADDRESS[] =   "0013A2004149DA14"; //XBEE S1 from IoT lab

char NODE_ID[] = "TX_node_min";

uint8_t error;

void setup(){
  USB.ON();
  USB.println(F("\n******* 802.15.4 SEND (TX) MINIMAL ******\n"));
  xbee802.ON(); 

  USB.print("---> My MAC ADDRESS: ");
  xbee802.getOwnMacHigh();
  xbee802.getOwnMacLow();
  for (int i=0;i<4;i++){
    USB.printHex(xbee802.sourceMacHigh[i]);
  }
  for (int i=0;i<4;i++){
    USB.printHex(xbee802.sourceMacLow[i]);
  }
  USB.println();  

  xbee802.getChannel();
  USB.print(F("---> xbee802.channel: "));
  USB.printHex(xbee802.channel); // CORRECT, it is set in channel C
  USB.println();

  xbee802.setNodeIdentifier(NODE_ID);
  xbee802.getNodeIdentifier();
  USB.print(F("---> node ID: "));
  USB.println(xbee802.nodeID); /* Should print the whole array */

  if(xbee802.setOwnNetAddress("1212") == 0){
    USB.println(F("---> setOwnNetAddress(\"1212\") success"));
  } else{
    USB.println(F("---> setOwnNetAddress(\"1212\") ERROR..."));
  }

}


void loop(){
  delay(3000); // it goes too fast
  USB.println(F("\n************** LOOP STARTS **************\n"));
  
  USB.println(F("-------- 1. Create ASCII frame ----------"));
  frame.createFrame(ASCII);  
  frame.setFrameSize(125);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 

  error = 
  xbee802.send(RX_ADDRESS, frame.buffer, frame.length); 
  if( error == 0 ){   // check TX flag
    USB.println(F("---> frame sent ok"));
  }
  else{
    USB.println(F("---> OOPS..., frame sent error"));
    Utils.blinkRedLED();
  }
  
  int delayTime = 3; /* seconds */
  USB.print(F("\n***** LOOP END, Wait for "));
  USB.print(delayTime);
  USB.print(F(" sec *********\n"));
  delay(delayTime * 1000); /* milliseconds */
}



