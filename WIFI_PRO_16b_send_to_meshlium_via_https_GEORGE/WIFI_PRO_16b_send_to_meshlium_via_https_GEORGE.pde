#include <WaspWIFI_PRO.h>
#include <WaspFrame.h>


// choose socket (SELECT USER'S SOCKET)
uint8_t socket = SOCKET0;

char type[] = "https";
char host[] = "10.10.10.1";
char port[] = "443";

char TRUSTED_CA[] =
"-----BEGIN CERTIFICATE-----\r"\
"MIIDxTCCAq2gAwIBAgIJANmfNvvZHqt5MA0GCSqGSIb3DQEBCwUAMHgxCzAJBgNV\r"\
"BAYTAkVTMQ8wDQYDVQQIDAZBcmFnb24xETAPBgNVBAcMCFphcmFnb3phMTIwMAYD\r"\
"VQQKDClMaWJlbGl1bSBDb211bmljYWNpb25lcyBEaXN0cmlidWlkYXMgUy5MLjER\r"\
"MA8GA1UEAwwIbWVzaGxpdW0wIBcNMTgwODIzMDcxNDE0WhgPMjExODA3MzAwNzE0\r"\
"MTRaMHgxCzAJBgNVBAYTAkVTMQ8wDQYDVQQIDAZBcmFnb24xETAPBgNVBAcMCFph\r"\
"cmFnb3phMTIwMAYDVQQKDClMaWJlbGl1bSBDb211bmljYWNpb25lcyBEaXN0cmli\r"\
"dWlkYXMgUy5MLjERMA8GA1UEAwwIbWVzaGxpdW0wggEiMA0GCSqGSIb3DQEBAQUA\r"\
"A4IBDwAwggEKAoIBAQDpWNu/u/UelrO6KsR0tofdhplr3npzm4ZqxvpvqNmYGykP\r"\
"NaelXnr/1Sl/39EYfcuwsUX4xsQSBcHrtm6HVrq1+vtYC/v8CV02nKCc0NtwR3nk\r"\
"KuF41Yy56kXKOE0LRkhcrI0Ti67apApN/v7NDuXU7j404eTiRACMGiL+HkUkO2Wr\r"\
"/YtMjsdDwgxDRet9GeCv/Euqy2xirjv1nuU5rG6uoJzWauXCvekutMMJ/2XXtweF\r"\
"X7SzWIkRz3LcOBXRhafs/dO1aL9LVibtDOxUYyLvJyeyL6FKjpqRHKAvehfsR49N\r"\
"VkLkBCl/tjhcTTHpvm0bsG+q7aKLoOhp8lYItDfLAgMBAAGjUDBOMB0GA1UdDgQW\r"\
"BBQpsed68QeqW+nIaXun/FOvVm4WzjAfBgNVHSMEGDAWgBQpsed68QeqW+nIaXun\r"\
"/FOvVm4WzjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQB3rXMiBUx7\r"\
"yeJO29xKSAgdrGZe189WWiCfvdphMuaSH8OQooKd5d4a6CzmoiklusAFTfGiaXqK\r"\
"DPuE5/atjLAluj4NR2MZ4ti9bqhcCFdlDGKXAj3wqvEIGbjVppXkPRlFyM+/VIW6\r"\
"7hm59xKsWyymqxBfKmFsXgFA90mOqmzoPV0pu2d5Q+Kh6gEZYauiWkLIxa+y36Wq\r"\
"+HCe1q3vch5zOhPUnlpUmhzQd4K/AlyHEZUnG0hPzURnXk+qspb5xsiHuRoj9mkh\r"\
"MTNKb37FmwyZyM9u+KuNRKvZ0TJY0zs9+SDoDQJVRMwGh7I6IEHCuWNMl4N0aNaY\r"\
"2huxbcU1t/Z+\r"\
"-----END CERTIFICATE-----";

uint8_t error;
uint8_t status;
unsigned long previous;

char moteID[] = "george_https";

void setup(){
  USB.println(F("Start program"));
  USB.println(F("***************************************"));
  USB.println(F("Once the module is set with one or more"));
  USB.println(F("AP settings, it attempts to join the AP"));
  USB.println(F("automatically once it is powered on"));
  USB.println(F("Refer to example 'WIFI_PRO_01' to configure"));
  USB.println(F("the WiFi module with proper settings"));
  USB.println(F("***************************************"));


  frame.setID(moteID);

  error = WIFI_PRO.ON(socket);
  if (error == 0){
    USB.println(F("1. WiFi switched ON"));
  }else{
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  error = WIFI_PRO.setCA(TRUSTED_CA);
  if (error == 0){
    USB.println(F("2. Trusted CA set OK"));
  }else{
    USB.println(F("2. Error calling 'setCA' function"));
    WIFI_PRO.printErrorCode();
  }

  //WIFI_PRO.OFF(socket);
  //USB.println(F("3. WiFi switched OFF"));
  //USB.println(F("Setup done\n\n"));
}



void loop()
{
  // get actual time
  previous = millis();

  error = WIFI_PRO.ON(socket);

  if (error == 0){
    USB.println(F("WiFi switched ON"));
  }else{
    USB.println(F("WiFi did not initialize correctly"));
  }

  // 2. Join AP
  status =  WIFI_PRO.isConnected();
  if (status == true){
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
    
    // create new frame (only ASCII)
    frame.createFrame(ASCII);
    frame.addSensor(SENSOR_STR, "this_is_a_string");
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.showFrame();

    // 3.2. Send Frame to Meshlium
    // http frame
    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
    if (error == 0){
      USB.println(F("HTTP OK"));
      USB.print(F("HTTP Time from OFF state (ms):"));
      USB.println(millis() - previous);
    }else{
      USB.println(F("Error calling 'getURL' function"));
      WIFI_PRO.printErrorCode();
    }
  }else{
    USB.print(F("WiFi is connected ERROR"));
    USB.print(F(" Time(ms):"));
    USB.println(millis() - previous);
  }

  // 3. Switch OFF
  //WIFI_PRO.OFF(socket);
  //USB.println(F("WiFi switched OFF\n\n"));
  delay(3000);
}







