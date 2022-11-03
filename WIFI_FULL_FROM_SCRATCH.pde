#include <WaspWIFI_PRO.h>
#include <WaspFrame.h>

char ACC_POINT_IP[]="10.10.10.1";
char GOOGLE_DNS_IP[]="8.8.8.8";
char ESSID[] = "Robby_1";
//char ESSID[] = "Students";
//char PASSWORD[] = "#Std2019";
char PASSWORD[] = "george123";

uint8_t wi_fi_socket = SOCKET1;
int counter = 0;

uint8_t error;
uint8_t status;
unsigned long previous;

void setup() {
  USB.ON();
  USB.println(F("---- WIFI_PRO_ALL_GEORGE ----------"));

/*
  WIFI_PRO.printErrorCode(); //void function
  status = WIFI_PRO.getResponseValue();
  USB.print(F("----- WIFI getResponseValue: "));
  USB.print(status, DEC);
  USB.println(F(" -----"));
*/  

  /* 1. Switch ON the WiFi module */
  error = WIFI_PRO.ON(wi_fi_socket);
  if (error == 0) {
        USB.println(F("1. WiFi switched ON"));
  } else {
    USB.print("1. Switch on WI-FI ERROR, No: ");
    USB.println(error, DEC);
    USB.print("----- PROGRAM HALTS ----------");
  }
  
  /* 2. Reset to default values */
  error = WIFI_PRO.resetValues();
  if (error == 0) {
    USB.println(F("2. WiFi reset to default success"));
  } else {
      USB.println(F("2. WiFi reset to default ERROR"));
      USB.print("----- PROGRAM HALTS ----------");
  }

  /* 3. Set ESSID */
  error = WIFI_PRO.setESSID(ESSID); 
  if (error == 0) {
    USB.println(F("3. WiFi set ESSID OK"));
  } else {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }
        
  /* 4. Set password key (It takes a while to generate the key)
   * Authentication modes:
   * OPEN: no security
   * WEP64: WEP 64
   * WEP128: WEP 128
   * WPA: WPA-PSK with TKIP encryption
   * WPA2: WPA2-PSK with TKIP or AES encryption
   */
  error = WIFI_PRO.setPassword(WPA2, PASSWORD);
  //WIFI_PRO.printErrorCode(); 
  if (error == 0) {
    USB.println(F("4. WiFi set AUTHKEY OK"));
  } else {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }

  // 5. Software Reset =  APPLY PARAMETERS
  if (WIFI_PRO.softReset()) {
    USB.println(F("5. WiFi softReset OK"));
  } else {
    USB.println(F("5. WiFi softReset ERROR"));
  }
}

/**************** LOOP ************************/
void loop() {
  USB.print(F("------- Start loop program:"));
  USB.print(counter, DEC);
  USB.println(F("--------"));
  counter += 1;
  
  status = WIFI_PRO.reportStatusComplete();
  USB.print(F("WIFI_PRO.reportStatusComplete: "));
  USB.println(status, DEC);

  USB.print(F("WIFI_PRO.printErrorCode: "));
  WIFI_PRO.printErrorCode();
  
  if(WIFI_PRO.isConnected() == true){
    USB.println(F("WIFI connected ok..."));

    error = WIFI_PRO.ping(ACC_POINT_IP); //Access Point
    if (error == 0){
      USB.print(F("6.1 PING Access Point OK. RTT(ms)="));
      USB.println( WIFI_PRO._rtt, DEC );
    }else{
      USB.println(F("Error in 'ping' Access Point"));
    }

    error = WIFI_PRO.ping("10.22.29.75"); //Access Point
    if (error == 0){
      USB.print(F("6.1 PING 10.22.29.75  OK. RTT(ms)="));
      USB.println( WIFI_PRO._rtt, DEC );
    }else{
      USB.println(F("Error in 'ping' 10.22.29.75"));
    }

    USB.println(F("------ Errors ---------"));
    WIFI_PRO.reportStatus();
    WIFI_PRO.reportStatus4();
    WIFI_PRO.reportStatusComplete();

  } else{
    USB.print(F("WIFI_PRO.printErrorCode: "));
    WIFI_PRO.printErrorCode();
  }
     

/******** KEEP THIS AT THE END ***********/
  delay(5000); /* HAS TO BE THE LAST ONE */
}
