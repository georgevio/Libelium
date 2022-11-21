#include <WaspXBee802.h>
#include <WaspSensorCities_PRO.h>

char CHANNEL[]="C";
uint8_t error;
uint8_t panID=3332;

void setup(){
  xbee802.ON(); 
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
  USB.print(F("---> INITIAL xbee802.channel: "));
  USB.printHex(xbee802.channel); 
  USB.println();

  xbee802.setChannel(0xC);
  USB.print(F("---> xbee802.channel: "));
  USB.printHex(xbee802.channel); // CORRECT, it is set in channel C
  USB.println();

  //error = 
  //xbee802.setPAN(panID);
  /*
  if(error!=0){
    println("SetPAN error...");
  }
  */
  xbee802.getPAN();
  USB.print(F("---> xbee802.getPAN: "));
  for (int i=0;i<8;i++){
    USB.print(xbee802.PAN_ID[i], HEX);
  }  
  //USB.printHex(xbee802.PAN_ID); 
  USB.println();
  
  xbee802.getNodeIdentifier();
  USB.print(F("---> node ID: "));
  USB.println(xbee802.nodeID);
}

void loop(){

}

