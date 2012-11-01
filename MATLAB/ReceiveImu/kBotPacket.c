#include "kBotPacket.h"

//initialize the packet
void kBotPacketInit(kBotPacket * packet)
{
  packet->lenReceived = 0;
  packet->lenExpected = 0;
  packet->bp          = NULL;
}

//feed in a character and see if we got a complete packet
int16_t   kBotPacketProcessChar(uint8_t c, kBotPacket * packet)
{
  int16_t ret = 0;
  uint8_t checksum;
    
  switch (packet->lenReceived)
  {
    case 0:
      packet->bp = packet->buffer;    //reset the pointer for storing data
      
    //fall through, since first two bytes should be 0xFF
    case 1:
      if (c != KBOT_PACKET_HEADER)       //check the packet header (0xFF)
      {
        packet->lenReceived = 0;
        ret = -1;
        break;
      }
    
    //fall through, since we are just storing ID and length
    case 2:                           //ID
    case 3:                           //LENGTH
      packet->lenReceived++;
      *(packet->bp)++ = c;
      break;
        
    case 4:                           //by now we've got 0xFF, 0xFF, ID, LENGTH
      packet->lenExpected = packet->buffer[3] + 4;  //add 4 to get the full length
      
      //verify the expected length
      if ( (packet->lenExpected < KBOT_PACKET_MIN_SIZE)
        || (packet->lenExpected > KBOT_PACKET_MAX_SIZE) )
      {
        packet->lenReceived = 0;
        packet->lenExpected = 0;
        ret = -2;
        break;
      }
      
    //read off the rest of the packet
    default:
      packet->lenReceived++;
      *(packet->bp)++ = c;
      
      if (packet->lenReceived < packet->lenExpected)
        break;  //have not received enough yet
    
      //calculate expected checksum
      //skip first two 0xFF and the actual checksum
      checksum = kBotPacketChecksum(packet->buffer+2,
                                         packet->lenReceived-3);
      
      if (checksum == c)
        ret  = packet->lenReceived;
      else
        ret = -3;
      
      //reset the counter
      packet->lenReceived = 0;
  }
  
  return ret;
}


//wrap arbitrary data into the kBot packet format
int16_t kBotPacketWrapData(uint8_t id, uint8_t type,
                                uint8_t * data, uint16_t dataSize, 
                                uint8_t * outBuf, uint16_t outSize)
{
  uint16_t packetSize = dataSize + KBOT_PACKET_OVERHEAD;

  //make sure enough memory is externally allocated
  if (outSize < packetSize)
    return -1;

  uint8_t ii;
  uint8_t payloadSize = dataSize+2;     //length includes packet, type and checksum
  uint8_t checksum    = 0;
  uint8_t * obuf      = outBuf;
  uint8_t * ibuf      = data;
  *obuf++             = 0xFF;           //two header bytes
  *obuf++             = 0xFF;
  *obuf++             = id;
  *obuf++             = payloadSize;
  *obuf++             = type;
  checksum           += id + payloadSize + type;
  
  //copy data and calculate the checksum
  for (ii=0; ii<dataSize; ii++)
  {
    *obuf++ = *ibuf;
    checksum += *ibuf++;
  }
  
  *obuf = ~checksum;
  
  return packetSize;
}

/*
//verify the full packet
int16_t kBotPacketVerifyRaw(uint8_t * buf, uint8_t size)
{
  //TODO: implement

  return -1;
}
*/

