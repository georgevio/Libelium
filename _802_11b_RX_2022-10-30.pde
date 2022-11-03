#include <WaspXBee802.h>
#include <WaspFrame.h>

uint8_t error;
uint8_t destination[8]; // NOT TO BE USED in 802.15.4

uint16_t data_length;

uint8_t api_mode = 2; /* 0-2 */
uint8_t mac_mode = 3; /* 0-3 */



// TODO: DOES NOT WORK AS A NETWORK ADDRESS
uint8_t src_net_addr[2];

int rssi;



void setup(){
  
  USB.ON();
  USB.println(F("*****2022-10-30 Complete example (RX node) *****\n"));
  xbee802.ON();

  USB.print(F("---> API mode: "));
  USB.println(api_mode, DEC);
  /* Set API mode accordingly */
  xbee802.setAPI(api_mode); /* WHEN SET OTHERWISE, IT IS NOT WORKING !! */

 /*to select at any time if the modules are to use 
  * a totally compatible heading format */
  //xbee802.setMacMode(mac_mode);
  USB.print(F("---> Active MAC mode: "));
  USB.println(xbee802.getMacMode(), DEC);

  xbee802.getNodeIdentifier();
  USB.print(F("---> node ID: "));
  USB.println(xbee802.nodeID); /* Should print the whole array */
  USB.println();  

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
  USB.printHex(xbee802.channel); // currently C
  USB.println();

  if(xbee802.setOwnNetAddress("1221") == 0){
    USB.println(F("---> setOwnNetAddress(\"1221\") success"));
  } else{
    USB.println(F("---> setOwnNetAddress(\"1221\") ERROR..."));
  }
}

void loop(){
  USB.println(F("\n************** LOOP STARTS **************\n"));

  USB.print(F("\tAPI mode: "));
  USB.print(api_mode, DEC);
  USB.print(F(", MAC mode: "));
  USB.println(xbee802.getMacMode(), DEC);
  
  /* Receive XBee packet (wait message for 2 seconds) */
  error = xbee802.receivePacketTimeout( 8000 );
  if( error == 0 ){    
    USB.println(F("------- 1. New packet received ---------"));

// TODO: Change the string in the sent packet and see if it changes
    USB.print(F("---> Received packet length: "));  
    USB.println(xbee802._length); /* uint16_t   _length */

    /* Show data stored in '_payload' buffer indicated by '_length' */
    USB.print(F("---> Received message: "));
    for(int i=0;i<xbee802._length;i++){
      USB.print( xbee802._payload[i]);
    }
    USB.println();
    
    /*** Available info in library structure ***/
    /* get Source's MAC address */
    USB.print(F("---> Source MAC address: ")); 
    for (int i=0;i<8;i++){
      USB.print(xbee802._srcMAC[i], HEX);
      destination[i] = xbee802._srcMAC[i]; 
    }
    USB.println();

    USB.print(F("---> Source Network address: ")); 
    src_net_addr[0]=xbee802._srcNA[0];
    USB.print(xbee802._srcNA[0], HEX);
    src_net_addr[1]=xbee802._srcNA[1];
    USB.print(xbee802._srcNA[1], HEX);
    USB.println();
     
    USB.print(F("---> RSSI(dBm): "));  
    USB.println(xbee802._rssi); 

    xbee802.getRSSI();
    if(!xbee802.error_AT){
      USB.print(F("---> getRSSI(dBm): "));
      rssi=xbee802.valueRSSI[0];
      rssi*=-1;
      USB.println(rssi,DEC);
    }
    USB.println();

    /* Wait TX node to prepare to receive messages */
    delay(1000);
    
    /* Send message to TX node */
    USB.println(F("\n------- 2. Send a response to the TX node ------")); 

    frame.createFrame(ASCII);//, "responce");
    frame.setFrameSize(125);
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    USB.println(F("--->Frame to be sent back below"));
    frame.showFrame();
    
    error=xbee802.send("1212", frame.buffer, frame.length );       
    if( error == 0 ){ /* check TX flag */
      USB.print(F("sent to: "));
      USB.print(src_net_addr[0], HEX);
      USB.print(src_net_addr[1], HEX);
      USB.println(F(" successful..."));
      Utils.blinkGreenLED();      
    }else{
      USB.print(F("sent to: "));
      USB.print(src_net_addr[0], HEX);
      USB.print(src_net_addr[1], HEX);
      USB.println(F(" ERROR..."));
      Utils.blinkRedLED();
    }
  }else{
    /* Print error message:
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct	  
     * '3' : Checksum byte is not available	
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
     */
    USB.print(F("\tError receiving a packet:"));
    USB.println(error,DEC);     
  }
  
  USB.println(F("\n******** END OF LOOP, delay 60 sec ********\n"));
  delay(60000);
}



