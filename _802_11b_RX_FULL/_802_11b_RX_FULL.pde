#include <WaspXBee802.h>
#include <WaspFrame.h>

uint8_t error;
uint8_t TX_MAC_ADDRESS[8]; // CAN BE NOT USED in 802.15.4 ?

uint8_t api_mode = 1; /* 0-2 */ // ONLY 1,2 seem to work!
uint8_t mac_mode = 0; /* 0-3 */ // when API=1 or 2, mac is 0 no matter what

int delayTime;

char WASPMOTE_ID[] = "4242_RECV_RX";
char MY_NET_ADDRESS[] = "4242";
char TX_NET_ADDRESS[2];

int rssi;

void setup(){
  USB.ON();
  USB.println(F("***** Complete example (RX node) *****\n"));
  
  xbee802.ON();
    
  RTC.ON(); /* Mote's time */
  /* TESTED, WORKS FINE! */
  error = xbee802.setRTCfromMeshlium("0013A20041678A0E"); //Robby1 MAC
  if( error == 0 ){
    USB.println(F("SET RTC Time from Meshlium is ok! \n"));
  }else{
    USB.println(F("SET RTC Time from Meshlium error..."));
  }
  
  error=xbee802.getPAN();
  if(error!=0){ /* Only if it didn't get the ID */
    USB.println(F("ERROR getting PAN_ID..."));
  }
  USB.print(F("---> PAN_ID: "));
  for(int i=0;i<2;i++){
    USB.printHex(xbee802.PAN_ID[i]);
  }
  USB.println();

  xbee802.setNodeIdentifier(WASPMOTE_ID);
  xbee802.getNodeIdentifier();
  USB.print(F("---> node ID: "));
  USB.println(xbee802.nodeID); /* Should print the whole array */

  USB.print(F("---> API mode: "));
  USB.println(api_mode, DEC);
  xbee802.setAPI(api_mode); /* WHEN SET OTHERWISE, IT IS NOT WORKING !! */

 /*to select at any time if the modules are to use 
  * a totally compatible heading format */
  xbee802.setMacMode(mac_mode);
  USB.print(F("---> Active MAC mode: "));
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
  USB.printHex(xbee802.channel); // currently C
  USB.println();

  USB.print(F("---> setOwnNetAddress("));
  USB.print(MY_NET_ADDRESS);
  if(xbee802.setOwnNetAddress(MY_NET_ADDRESS) == 0){
    USB.print(F(") SUCCESFULL..."));
  } else{
    USB.print(F(") ERROR!..."));
  }
  USB.println();

  // Show '_serial_id' stored by the API when powering up
  USB.print(F("---> Serial ID: "));
  for (int i=0;i<8;i++){
    USB.printHex(_serial_id[i]);
  }
  USB.println();

  USB.print(F("---> RTC Time:"));
  USB.println(RTC.getTime());
  
}

void loop(){
  USB.println(F("\n************** LOOP STARTS **************\n"));
  RTC.ON(); /* Mote's time */
    
  /* Receive XBee packet (wait message for 2 seconds) */
  error = xbee802.receivePacketTimeout( 4000 );
  if( error == 0 ){    
    USB.println(F("------- 1. New packet received ---------"));

// TODO: Change the string in the sent packet and see if it changes
    USB.print(F("---> Received packet length: "));  
    USB.println(xbee802._length); // uint16_t   _length;

    /* define the variable ad hoc */
    char data_in[xbee802._length]; // assign the length correct value
    /* Show data stored in '_payload' buffer indicated by '_length' */
    USB.print(F("---> Received message: "));
    for(int i=0;i<xbee802._length;i++){
      USB.print( xbee802._payload[i]);
      data_in[i] = xbee802._payload[i]; // use the data further
    }
    USB.println();
    
    USB.print(F("---> Source (TX) MAC address: ")); 
    for (int i=0;i<8;i++){
      TX_MAC_ADDRESS[i] = xbee802._srcMAC[i]; 
      USB.print(TX_MAC_ADDRESS[i], HEX);
    }
    USB.println();

    USB.print(F("---> Source (TX) Network address: ")); 
    TX_NET_ADDRESS[0]=xbee802._srcNA[0];
    USB.print(xbee802._srcNA[0], HEX);
    TX_NET_ADDRESS[1]=xbee802._srcNA[1];
    USB.print(xbee802._srcNA[1], HEX);
    USB.println();
     
    USB.print(F("---> RSSI(dBm): "));  
    USB.println(xbee802._rssi); 

    /* RSSI again */
    xbee802.getRSSI();
    if(!xbee802.error_AT){
      USB.print(F("---> getRSSI(dBm): "));
      rssi=xbee802.valueRSSI[0];
      rssi*=-1;
      USB.println(rssi,DEC);
    }
    USB.println();

    /* Wait TX node to prepare to receive messages */
    //delay(1000);
    
    /* Send message back to TX node */
    USB.println(F("\n------- 2. Send a response to the TX node ------")); 

    frame.createFrame(ASCII, WASPMOTE_ID); /* Set the ID inside the frame */
    frame.setFrameSize(125);
    /* EXAMPLE_FRAME
     TIMEOUT_FRAME
     EVENT_FRAME
     ALARM_FRAME
     SERVICE1_FRAME
     SERVICE2_FRAME */
    frame.setFrameType(EVENT_FRAME); 
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    USB.println(F("--->Frame to be sent back below"));
    frame.showFrame();

    // TODO: THE PACKET IS NOT SEND SUCCESFULLY in both cases !!!
    
    if(TX_NET_ADDRESS){ // if empty address not used
      error=xbee802.send(TX_NET_ADDRESS, frame.buffer, frame.length );       
      USB.print(F("Sent to NET Address: "));
      USB.print(TX_NET_ADDRESS[0], HEX);
      USB.print(TX_NET_ADDRESS[1], HEX);
      if( error == 0 ){ /* check TX flag */
        USB.println(F(" SUCCESSFUL..."));
        Utils.blinkGreenLED();      
      }else{
        USB.println(F(" ERROR..."));
        Utils.blinkRedLED();
      }
    }
    if(TX_MAC_ADDRESS){ // if empty address not used
      error=xbee802.send(TX_MAC_ADDRESS, frame.buffer, frame.length );       
      USB.print(F("Sent to MAC Address: "));
      for(int i=0; i<8; i++){
        USB.print(TX_MAC_ADDRESS[i], HEX);
      }
      if( error == 0 ){ /* check TX flag */
        USB.println(F(" SUCCESSFUL..."));
        Utils.blinkGreenLED();      
      }else{
        USB.println(F(" ERROR..."));
        Utils.blinkRedLED();
      } 
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
  
  delayTime = 5; /* seconds */
  USB.print(F("\n***** LOOP END, Wait for "));
  USB.print(delayTime);
  USB.print(F(" sec *********\n"));
  delay(delayTime * 1000); /* milliseconds */
}



