#ifndef __SERIALDEVICE_C_API_H__
#define __SERIALDEVICE_C_API_H__

void SerialDevice_exit(void);
int SerialDevice_connect(const char deviceName[], int baud);

#endif
