#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorEvent_v30.h>

/* Github https://github.com/georgevio/libelium.git */

/* BME280 triple sensor */
float temp;
float humd;
float pres;
float value;

// TODO: ONLY BROADCAST SEEMS TO WORK

char RX_ADDRESS[] =     "000000000000FFFF"; /* BROADCAST */
//char RX_ADDRESS[] =   "0013A20041678A0E"; /* AP MEshlium MAC */
//char RX_ADDRESS[] =   "0013A2004149DA14"; //XBEE S1 from IoT lab
//char RX_ADDRESS[] =     "0013A2004149DA23";

char MY_NET_ADDRESS[]="2112";
char RX_NET_ADDRESS[]="1221";
char MESHLIUM_NET_ADDRESS[]="1111";

/* In 802.15.4 you can use either full 8 HEX standard MAC
 *  Address, or you can use the 2 HEX NET address.
 *  The receiver will adapt automatically.
 *  0= use NET ADDRESS, 1 = USE MAC */
uint8_t ADDRESS_TYPE = 1;

char NODE_ID[] = "TX_WITH_BME280";

char node_data[20];

uint8_t error;
int counter = 0;
int delayTime;

uint8_t api_mode = 1; /* 0-2 */
uint8_t mac_mode = 0; /* 0-3 */

void setup(){
  USB.ON();
  USB.println(F("\n******* 802.15.4 WITH BME280 (TX) ******\n"));
  xbee802.ON(); 
  Events.ON(); /* expansion board for sensors */

  xbee802.setNodeIdentifier(NODE_ID);
  xbee802.getNodeIdentifier();
  USB.print(F("---> node ID: "));
  USB.println(xbee802.nodeID); /* Should print the whole array */  

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

  USB.print(F("---> setOwnNetAddress("));
  USB.print(MY_NET_ADDRESS);
  if(xbee802.setOwnNetAddress(MY_NET_ADDRESS) == 0){
    USB.print(F(") SUCCESSFUL..."));
  } else{
    USB.print(F(") ERROR!..."));
  }
  USB.println();

}


void loop(){
  USB.println(F("\n************** LOOP STARTS **************\n"));

  temp = Events.getTemperature();
  humd = Events.getHumidity();
  pres = Events.getPressure();

  USB.println("-------- BME280 ---------");
  USB.print("Temperature: ");
  USB.printFloat(temp, 2);
  USB.println(F(" Celsius"));
  USB.print("Humidity: ");
  USB.printFloat(humd, 1); 
  USB.println(F(" %")); 
  USB.print("Pressure: ");
  USB.printFloat(pres, 2); 
  USB.println(F(" Pa")); 
  USB.println("-----------------------------\n");
  
  counter++;
  sprintf(node_data,"Packet No:%d",counter);

  USB.println(F("-------- 1. Create ASCII frame ----------"));
  frame.createFrame(ASCII, NODE_ID); /* Set the node ID INSIDE the frame */  
  frame.setFrameSize(125);
  /* EXAMPLE_FRAME
     TIMEOUT_FRAME
     EVENT_FRAME
     ALARM_FRAME
     SERVICE1_FRAME
     SERVICE2_FRAME */
  frame.setFrameType(EVENT_FRAME);  
  frame.addSensor(SENSOR_STR, node_data); 
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 
  frame.addSensor(SENSOR_TCA, temp); /* look into data_frame_guide.pdf */
  frame.addSensor(SENSOR_HUMA, humd);
  frame.addSensor(SENSOR_PA, pres);
  
  USB.println(F("---> Frame 2 send: ")); frame.showFrame();
  
  if(ADDRESS_TYPE == 0){ /* 0 or 1 */
    error = xbee802.send(RX_NET_ADDRESS, frame.buffer, frame.length); 
  }else{
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
  
  delayTime = 5; /* seconds */
  USB.print(F("\n***** LOOP END, Wait for "));
  USB.print(delayTime);
  USB.print(F(" sec *********\n"));
  delay(delayTime * 1000); /* milliseconds */
}
