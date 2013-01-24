#ifndef __SERIALDEVICE_C_API_H__
#define __SERIALDEVICE_C_API_H__

void SerialDevice_exit(void);
int SerialDevice_connect(const char deviceName[], int baud);
int SerialDevice_read(int len, int timeout, vector<uint8_t>& Buffer);
int SerialDevice_write(uint8_t *data, int len);

#endif
