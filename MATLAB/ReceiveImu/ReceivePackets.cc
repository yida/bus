#include <stdint.h>
#include <vector>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "SerialDevice.hh"
#include "SerialDeviceCAPI.h"
#include "kBotPacket2CAPI.h"
//#include "kBotPacket.h"

char deviceName[] = "/dev/ttyUSB0";
int baud = 230400;

std::vector<uint8_t> ReceivePacket() {
  static int packetID = 0;
  std::vector<uint8_t> packet;
  
  
  if (!packetID)
    packetID = kBotPacket2_create();

  static std::vector<uint8_t> buf2;
  if (buf2.size()) {
    kBotPacket2_processBuffer(packetID, buf2, packet); 
    return packet;
  }

  SerialDevice_read(1000, 2000, buf2);
  kBotPacket2_processBuffer(packetID, buf2, packet); 
  return packet;
}

int main(int argc, char** argv) {

  if (argc > 1)
    strcpy(deviceName, argv[1]);

  SerialDevice_connect(deviceName, baud);

  std::vector<uint8_t> pkt;
  while (true) {
    pkt = ReceivePacket();
    if (pkt.size()) {
      uint8_t id = pkt[2];
      uint8_t type = pkt[4];
      int len = pkt.size();

      if (pkt[2]) continue;
      switch (type) {
        case 31:
//          cout << "GPS" << endl;
//          for (int cnt = 5; cnt < pkt.size() - 8; cnt ++)
//            cout << pkt[cnt];
//          cout << endl;
          break;
        case 34:
//          cout << "IMU" << endl;
//          for (int cnt = 5; cnt < 29; cnt ++)
//            cout << pkt[cnt];
//          cout << endl;
          break;
        case 35:
       //   cout << "MAG" << endl;
//          for (int cnt = 5; cnt < 24; cnt ++)
//            cout << pkt[cnt];
//          cout << endl;

          break;
        default:
          break;
      }
    }
  }
  return 0;
}
