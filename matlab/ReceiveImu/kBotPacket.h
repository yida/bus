// Packet buffer for Dynamixel-type packets.
// packet format (from Dynamixel manual:
// http://www.crustcrawler.com/motors/RX28/docs/RX28_Manual.pdf )
// [OxFF][0xFF][ID][LENGTH][INSTRUCTION][PARAMETER1]..[PARAMETERN][CHECKSUM]
// CHECKSUM = ~ ( ID + Length + Type + data1 + data2 + ... dataN )
//
// Alex Kushleyev, Upenn, akushley@seas.upenn.edu

#ifndef KBOT_PACKET_H
#define KBOT_PACKET_H

#include <stdio.h>
#include <stdint.h>

#define KBOT_PACKET_HEADER 0xFF
#define KBOT_PACKET_OVERHEAD 6
#define KBOT_PACKET_MIN_SIZE KBOT_PACKET_OVERHEAD
#define KBOT_PACKET_MAX_SIZE 250
#define KBOT_PACKET_MAX_PAYLOAD_SIZE (KBOT_PACKET_MAX_SIZE-KBOT_PACKET_MIN_SIZE)

enum { KBOT_PACKET_POS_HEADER1 = 0,
       KBOT_PACKET_POS_HEADER2,
       KBOT_PACKET_POS_ID,
       KBOT_PACKET_POS_SIZE,
       KBOT_PACKET_POS_TYPE,
       KBOT_PACKET_POS_DATA };
       
       
//buffer packet definition
typedef struct
{
  uint8_t buffer[KBOT_PACKET_MAX_SIZE];  //buffer for data
  uint8_t lenReceived; //number of chars received so far
  uint8_t lenExpected; //expected number of chars based on header
  uint8_t * bp;        //pointer to the next write position in the buffer
} kBotPacket;


//calculate the checksum
static inline uint8_t   kBotPacketChecksum(uint8_t * buf, uint8_t len)
{
  uint8_t ii;
  uint8_t checksum = 0;
  for (ii=0; ii<len; ii++)
    checksum += *buf++;
    
  return ~checksum;
}

//initialze the fields in the dynamixel packet buffer
void      kBotPacketInit(kBotPacket * packet);

//feed one char and see if we have accumulated a complete packet
int16_t   kBotPacketProcessChar(uint8_t c, kBotPacket * packet);

//get id of the sender
static inline uint8_t   kBotPacketGetId(kBotPacket * packet)
{
  return packet->buffer[KBOT_PACKET_POS_ID];
}

static inline uint8_t   kBotPacketRawGetId(uint8_t * packet)
{
  return packet[KBOT_PACKET_POS_ID];
}

//get size of the packet (as it appears in dynamixel packet)
static inline uint8_t   kBotPacketGetSize(kBotPacket * packet)
{
  return packet->buffer[KBOT_PACKET_POS_SIZE];
}

static inline uint8_t   kBotPacketRawGetSize(uint8_t * packet)
{
  return packet[KBOT_PACKET_POS_SIZE];
}

//get the size of payload (without message type or checksum)
static inline uint8_t   kBotPacketGetPayloadSize(kBotPacket * packet)
{
  return packet->buffer[KBOT_PACKET_POS_SIZE] - 2;  //subtract the instruction and checksum
}

static inline uint8_t   kBotPacketRawGetPayloadSize(uint8_t * packet)
{
  return packet[KBOT_PACKET_POS_SIZE] -2;
}

//get a pointer to the packet type
static inline uint8_t   kBotPacketGetType(kBotPacket * packet)
{
  return packet->buffer[KBOT_PACKET_POS_TYPE];
}

static inline uint8_t   kBotPacketRawGetType(uint8_t * packet)
{
  return packet[KBOT_PACKET_POS_TYPE];
}

//get a pointer to the packet payload
static inline uint8_t * kBotPacketGetData(kBotPacket * packet)
{
  return &(packet->buffer[KBOT_PACKET_POS_DATA]);
}

static inline uint8_t * kBotPacketRawGetData(uint8_t * packet)
{
  return &(packet[KBOT_PACKET_POS_DATA]);
}

//wrap arbitrary data into the kBot packet format
int16_t kBotPacketWrapData(uint8_t id, uint8_t type,
                                uint8_t * data, uint16_t dataSize, 
                                uint8_t * outBuf, uint16_t outSize);

                                
//int16_t kBotPacketVerifyRaw(uint8_t * buf, uint8_t size);

#endif //KBOT_PACKET_H

