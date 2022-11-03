#include <WaspXBeeDM.h>

uint8_t error;

uint8_t  channel = 0x0F;

void setup(){  
  // init USB port
  //USB.ON();
  USB.println(F("Receiving BROADCAST packets example"));

  // init XBee 
  //xbeeDM.ON(); 

  xbeeDM.setChannel( channel );

  // check at commmand execution flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.print(F("1. Channel set OK to: 0x"));
    USB.printHex( xbeeDM.channel );
    USB.println();
  }
  else 
  {
    USB.println(F("1. Error calling 'setChannel()'"));
  }
}

void loop(){   
  
  // receive XBee packet (wait for 5 seconds)
  error = xbeeDM.receivePacketTimeout( 5000 );

  // check answer  
  if( error == 0 ) {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Data: "));  
    USB.println( xbeeDM._payload, xbeeDM._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Length: "));  
    USB.println( xbeeDM._length,DEC);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Source MAC Address: "));  
    USB.printHex( xbeeDM._srcMAC[0] );
    USB.printHex( xbeeDM._srcMAC[1] );
    USB.printHex( xbeeDM._srcMAC[2] );
    USB.printHex( xbeeDM._srcMAC[3] );
    USB.printHex( xbeeDM._srcMAC[4] );
    USB.printHex( xbeeDM._srcMAC[5] );
    USB.printHex( xbeeDM._srcMAC[6] );
    USB.printHex( xbeeDM._srcMAC[7] );
    USB.println();    
    USB.println(F("--------------------------------"));
  }
  else{
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct    
     * '3' : Checksum byte is not available 
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);     
    USB.println(F("--------------------------------"));
  }

  USB.println(F("Delay 5 sec..."));
} 
