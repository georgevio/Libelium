#include <WaspXBee802.h>
#include <WaspFrame.h>

//char RX_ADDRESS[] =   "000000000000FFFF"; /* BROADCAST */
//char RX_ADDRESS[] =   "0013A20041678A0E"; // MEshlium MAC
char RX_ADDRESS[] =   "0013A2004149DA14"; //XBEE S1 from IoT lab

char WASPMOTE_ID[] = "node_George_TX";

char sensor_string[] = "";

uint8_t error;
int counter = 0;
uint8_t api_mode = 0; /* 0-2 */
uint8_t mac_mode = 1; /* 0-3 */
  
void setup(){
  USB.ON();
  USB.println(F("\n***** 2022-11-02  802.15.4 SEND (TX) ****\n"));
  xbee802.ON(); 

  USB.print(F("---> API mode: "));
  USB.println(api_mode, DEC);
  /* Set API mode accordingly */
  xbee802.setAPI(api_mode); /* WHEN SET OTHERWISE, IT IS NOT WORKING !! */

  /* to select at any time if the modules are to use 
   * a totally compatible heading format */
  xbee802.setMacMode(mac_mode); /* 0-3 */
  USB.print(F("---> MAC mode: "));
  USB.println(xbee802.getMacMode(), DEC);

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
  
  /* store Waspmote identifier in EEPROM memory */
  //frame.setID(WASPMOTE_ID); // TODO: Where is that ???

  xbee802.setNodeIdentifier(WASPMOTE_ID);
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
    
  counter++;    

  sprintf(sensor_string, "Frame No:%d", counter);
  USB.print(F("sensor_string: "));
  USB.println(sensor_string);
  
  USB.println(F("-------- 1. Create ASCII frame ----------"));
  frame.createFrame(ASCII);  
  frame.setFrameSize(125);
  frame.addSensor(SENSOR_STR, sensor_string);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  USB.println(F("---> frame to be sent: "));
  frame.showFrame();

  USB.print(F("\n------- 2. Sending packet to: "));
  USB.println(RX_ADDRESS);

  error = xbee802.send( "1221", frame.buffer, frame.length); 
  if( error == 0 ){   // check TX flag
    USB.println(F("---> frame sent ok"));
    Utils.blinkGreenLED();   
    
    USB.print(F("--->RSSI(dBm): "));  
    USB.println(xbee802._rssi); 

    /* Receive XBee packet (wait message for 2 seconds) */
    error = xbee802.receivePacketTimeout( 2000 );
    if( error == 0 ){    
      USB.println(F("------- 1.1 Responce packet received ---------"));
      /* define the variable ad hoc */
      char data_in[xbee802._length]; // assign the length correct value
      /* Show data stored in '_payload' buffer indicated by '_length' */
      USB.print(F("---> Received message: "));
      for(int i=0;i<xbee802._length;i++){
        USB.print( xbee802._payload[i]);
      }
      USB.println();
    }    
  }
  else{
    USB.println(F("--- OOPS..., frame sent error"));
    Utils.blinkRedLED();
  }
        
  USB.println(F("********** Wait for 5 sec *************"));
  delay(5000);
}



