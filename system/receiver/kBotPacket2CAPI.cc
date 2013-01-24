#include "kBotPacket2.h"
#include <map>
#include <string.h>
#include <stdint.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <iostream>


using namespace std;

#define PACKET_TYPE kBotPacket2
#define PACKET_INIT kBotPacket2Init
#define PACKET_GET_ID kBotPacket2GetId
#define PACKET_GET_TYPE kBotPacket2GetType
#define PACKET_GET_DATA kBotPacket2GetData
#define PACKET_PROCESS_CHAR kBotPacket2ProcessChar

std::map<int,PACKET_TYPE> packets;
static int packetCntr = 0;

int kBotPacket2_create() {
  packets[packetCntr] = PACKET_TYPE();
  PACKET_INIT(&(packets[packetCntr]));

  return packetCntr++;
}

int kBotPacket2_processBuffer(int nPacket, vector<uint8_t>& buf, 
                                                    vector<uint8_t>& buffer) {
  if (nPacket >= packetCntr)
    cerr << "invalid packet counter" << endl;

  int size = buf.size();

  PACKET_TYPE * packet = &(packets[nPacket]);
//int ndims    = 2;
//int dims[2]  = {1,0};

  int bufcount = 0;
  while (size > 0)
  {
    int ret = PACKET_PROCESS_CHAR(buf[bufcount++],packet);

    size--;
    if (ret > 0)
    {
      buffer.resize(packet->lenExpected);
      memcpy(&(buffer[0]),packet->buffer,packet->lenExpected);
      
      while (buf.size() > size)
        buf.pop_back();
      return 1;
    }
  }
  
  buf.resize(0);
  buffer.resize(0);

  return 0;

}

