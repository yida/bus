#ifndef __KBOTPACKET2_C_API_H__
#define __KBOTPACKET2_C_API_H__

int kBotPacket2_create();
int kBotPacket2_processBuffer(int nPacket, vector<uint8_t>& buf, vector<uint8_t>& buffer);

#endif 
