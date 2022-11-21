#include <WaspSensorCities_PRO.h>
#include <WaspXBee802.h>
#include <WaspFrame.h>

/* Github https://github.com/georgevio/libelium.git */

// TODO: Only broadcast seems to work
char RX_ADDRESS[] =     "000000000000FFFF"; /* BROADCAST */
//char RX_ADDRESS[] =   "0013A20041678A0E"; /* Robby1 MEshlium MAC */
//char RX_ADDRESS[] =   "0013A2004149DA14"; //XBEE S1 from IoT lab
//char RX_ADDRESS[] =     "0013A2004149DA23";

/* 
 *  NOTE Nov 08, 2022:
 *  Only NET address seems to work.
 *  MAC Address works only for broadcast,
 *  not for specific address
 */
 
char MY_NET_ADDRESS[]="5220";
//char RX_NET_ADDRESS[]="1221";
char RX_NET_ADDRESS[]="1111"; // MESHLIUM NET ADDRESS

/* In 802.15.4 you can use either full 8 HEX standard MAC
 *  Address, or you can use the 2 HEX NET address.
 *  The receiver will adapt automatically.
 *  0= use NET ADDRESS, 1 = USE MAC */
uint8_t ADDRESS_TYPE = 1;

char NODE_ID[] = "TX_SMART_CITIES";
uint8_t PANID[2] ; /* Set the PAN_ID global variable */
char node_data[20];

/* MAKE SURE YOU FIND THE CORRECT SOCKET! */
bmeCitiesSensor  bme(SOCKET_E);
float temp;  // temperature in ºC
float hum;   // realitve humidity in %RH
float pres;   // pressure in Pa

uint8_t error;
int counter = 0;
int delayTime;

uint8_t api_mode = 1; /* 0-2 */
uint8_t mac_mode = 0; /* 0-3 */

void setup(){
  USB.ON();
  USB.println(F("\n******* 802.15.4 SEND (TX) FULL ******\n"));
  
  xbee802.ON();   

  PANID[0]=0x33;
  PANID[1]=0x32;  
  /* Only if you need to set the ID */
  if(xbee802.setPAN(PANID)!=0){USB.println(F("ERROR setting PAN_ID..."));}

  error=xbee802.getPAN();
  if(error!=0){ /* Only if it didn't get the ID */
    USB.println(F("ERROR getting PAN_ID..."));
  }
  USB.print(F("---> PAN_ID: "));
  for(int i=0;i<2;i++){
    USB.printHex(xbee802.PAN_ID[i]);
  }
  USB.println();
  
  xbee802.setChannel(0xC);
  xbee802.getChannel();
  USB.print(F("---> xbee802.channel: "));
  USB.printHex(xbee802.channel); /* IT SHOULD BE CHANNEL C */
  USB.println();
  
  xbee802.setNodeIdentifier(NODE_ID);
  xbee802.getNodeIdentifier();
  USB.print(F("---> node ID: "));
  USB.println(xbee802.nodeID); /* Should print the whole array */  

  RTC.ON(); /* Mote's time */
  /* TESTED, WORKS FINE! */
  error = xbee802.setRTCfromMeshlium("0013A20041678A0E"); //Robby1
  if( error != 0 ){ /* Only in case of error...*/
    USB.println(F("SET RTC Time from Meshlium error..."));
  }

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

  USB.print(F("---> setOwnNetAddress("));
  USB.print(MY_NET_ADDRESS);
  if(xbee802.setOwnNetAddress(MY_NET_ADDRESS) == 0){
    USB.print(F(") SUCCESSFUL..."));
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

  bme.ON();
  temp = bme.getTemperature();
  hum = bme.getHumidity();
  pres = bme.getPressure();
  USB.println(F("*********** TEMP-HUM-PRESS ***************"));
  USB.print(F("Temperature: "));
  USB.printFloat(temp, 2);
  USB.println(F(" C"));
  USB.print(F("Relative Humidity: "));
  USB.printFloat(hum, 2);
  USB.println(F(" %"));
  USB.print(F("Pressure: "));
  USB.printFloat(pres, 2);
  USB.println(F(" Pa"));
  USB.println(F("*****************************************\n"));
  
  counter++;
  sprintf(node_data,"Packet No:%d",counter);

  USB.println(F("-------- 1. Create ASCII frame ----------"));
  frame.createFrame(ASCII, NODE_ID); /* Set the Node ID for the frame */  
  frame.setFrameSize(125);
    /* EXAMPLE_FRAME
       TIMEOUT_FRAME
       EVENT_FRAME
       ALARM_FRAME
       SERVICE1_FRAME
       SERVICE2_FRAME */
  frame.setFrameType(EVENT_FRAME); 
  frame.addSensor(SENSOR_STR, node_data); 
  frame.addSensor(SENSOR_IN_TEMP, temp);
  frame.addSensor(SENSOR_CITIES_PRO_HUM, hum);
  frame.addSensor(SENSOR_CITIES_PRO_PRES, pres);
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  USB.println(F("---> Frame 2 send: ")); frame.showFrame();
  
  if(ADDRESS_TYPE == 0){ /* 0 or 1 */
    USB.print(F("Sending to NET address: "));
    USB.println(RX_NET_ADDRESS);
    error = xbee802.send(RX_NET_ADDRESS, frame.buffer, frame.length); 
  }else{
    USB.print(F("Sending to MAC address: "));
    USB.println(RX_ADDRESS);
    error = xbee802.send(RX_ADDRESS, frame.buffer, frame.length);
  }
  if( error == 0 ){   // check TX flag
    USB.println(F("---> frame sent ok"));
    Utils.blinkGreenLED();  

    /* it should deteriorate with distance */
    USB.print(F("---> RSSI(dBm): "));  
    USB.println(xbee802._rssi); 

    /* Receive XBee packet (wait message for 2 seconds) */
    error = xbee802.receivePacketTimeout( 4000 );
    if( error == 0 ){    
      USB.println(F("------- 1.1 Responce packet received ---------"));
      /* define the variable ad hoc */
      char data_in[xbee802._length]; // assign the length correct value
      /* Show data stored in '_payload' buffer indicated by '_length' */
      USB.print(F("---> Received message: "));
      for(int i=0;i<xbee802._length;i++){
        USB.print(xbee802._payload[i]);
      }
      USB.println();
    }
       
  } else {
    USB.println(F("---> OOPS..., frame sent error"));
    Utils.blinkRedLED();
  }

  bme.OFF(); /* Obviously saves battery? */
  
  delayTime = 5; /* seconds */
  USB.print(F("\n***** LOOP END, Wait for "));
  USB.print(delayTime);
  USB.print(F(" sec *********\n"));
  delay(delayTime * 1000); /* milliseconds */
}
