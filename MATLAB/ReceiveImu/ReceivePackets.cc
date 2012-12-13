#include <stdint.h>
#include <vector>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "SerialDevice.hh"
#include "SerialDeviceCAPI.h"
#include "kBotPacket.h"

char deviceName[] = "/dev/ttyUSB0";
int baud = 230400;

int main(int argc, char** argv) {

  if (argc > 1)
    strcpy(deviceName, argv[1]);

  int ret = SerialDevice_connect(deviceName, baud);

//  while (true) {
//  }
  return 0;
}
