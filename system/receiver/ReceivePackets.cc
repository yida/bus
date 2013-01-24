#include <stdint.h>
#include <vector>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <fstream>
#include <sstream>
#include <ctime>
#include <dirent.h>

#include "SerialDevice.hh"
#include "SerialDeviceCAPI.h"
#include "kBotPacket2CAPI.h"
#include "Timer.hh"
//#include "kBotPacket.h"

char deviceName[] = "/dev/ttyUSB0";
int baud = 230400;

ifstream gpio146, gpio147, gpio175, gpio114;
std::string lefton, leftoff, righton, rightoff;

template <class T>
inline std::string to_string(const T& t) {
  std::stringstream ss;
  ss << t;
  return ss.str();
}

bool DirExists(const char* pzPath) {
  if (pzPath == NULL) return false;
  DIR *pDir;
  bool bExists = false;
  pDir = opendir(pzPath);
  if (pDir != NULL) {
    bExists = true;
    (void) closedir(pDir);
  }
  return bExists;
}

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

std::string fileDate(struct tm* timeinfo) {
  std::stringstream ss;
  ss.precision(2);
  ss.setf(ios::fixed);
  if (timeinfo->tm_mon < 9) 
    ss << 0;
  ss << (timeinfo->tm_mon+1);
  if (timeinfo->tm_mday < 10)
    ss << 0;
  ss << timeinfo->tm_mday;
  if (timeinfo->tm_hour < 10)
    ss << 0;
  ss << timeinfo->tm_hour;
  if (timeinfo->tm_min < 10)
    ss << 0;
  ss << timeinfo->tm_min;
  std::string date = ss.str();
  return date;
}

int main(int argc, char** argv) {

  if (argc > 1)
    strcpy(deviceName, argv[1]);

  // Enable GPIO
//  ofstream gpio_export;
//  gpio_export.open("/sys/class/gpio/export");
//  gpio_export << 146;
//  gpio_export.close();
//  gpio_export.open("/sys/class/gpio/export");
//  gpio_export << 147;
//  gpio_export.close();
  int dircount = 1;
  string homepath("/home/root/");
  string dir = homepath + to_string(dircount);
  while (DirExists(dir.c_str())) {
    dircount++;
    dir = homepath + to_string(dircount);
  }

  if (mkdir(dir.c_str(), 0777) == -1) {
    cerr << "Error: " << strerror(errno) << endl;
    exit(1);
  }

  int imufilecounter = 0;
  int gpsfilecounter = 0;
  int magfilecounter = 0;
  int imucounter = 0;
  int gpscounter = 0;
  int magcounter = 0;

  time_t rawtime;
  struct tm * timeinfo;
  time(&rawtime);
  timeinfo = localtime(&rawtime);
  std::string filedate = fileDate(timeinfo);

  std::string imufilebase("imu");
  imufilebase = dir + "/" + imufilebase;
  std::string imufilename = imufilebase + filedate + to_string(imufilecounter++);
  std::string gpsfilebase("gps");
  gpsfilebase = dir + "/" + gpsfilebase;
  std::string gpsfilename = gpsfilebase + filedate + to_string(gpsfilecounter++);
  std::string magfilebase("mag");
  magfilebase = dir + "/" + magfilebase;
  std::string magfilename = magfilebase + filedate + to_string(magfilecounter++);

  ofstream imufile(imufilename.c_str());
  cout << "new imufile " << imufilename << endl;
  ofstream gpsfile(gpsfilename.c_str());
  cout << "new gpsfile " << gpsfilename << endl;
  ofstream magfile(magfilename.c_str());
  cout << "new magfile " << magfilename << endl;

  SerialDevice_connect(deviceName, baud);

  std::vector<uint8_t> pkt;
  while (true) {
    pkt = ReceivePacket();
    // Get GPIO
    gpio146.open("/sys/class/gpio/gpio146/value");
    gpio147.open("/sys/class/gpio/gpio147/value");
    gpio175.open("/sys/class/gpio/gpio175/value");
    gpio114.open("/sys/class/gpio/gpio114/value");
    getline(gpio146, leftoff);
    getline(gpio147, lefton);
    getline(gpio175, righton);
    getline(gpio114, rightoff);
    gpio146.close();
    gpio147.close();
    gpio175.close();
    gpio114.close();
//    cout << lefton[0] << leftoff[0] << righton[0] << rightoff[0] << endl;

    // Generate Time Stamp
    std::ostringstream time;
    time.width(16);
    time.setf(ios::fixed, ios::floatfield);
    time << Timer::GetUnixTime();
    std::string TimeStamp = time.str();
//    cout << TimeStamp << endl;
    if (pkt.size()) {
//      uint8_t id = pkt[2];
      uint8_t type = pkt[4];
//      int len = pkt.size();

      if (pkt[2]) continue;
      switch (type) {
        case 31:
          if (gpsfile.is_open()) {
            gpscounter ++;
            gpsfile << TimeStamp << lefton[0] << leftoff[0] << righton[0] << rightoff[0];
            for (unsigned int cnt = 5; cnt < pkt.size() - 8; cnt ++)
              gpsfile << pkt[cnt];
            gpsfile << endl;
          }
          break;
        case 34:
          if (imufile.is_open()) {
            imucounter ++;
            imufile << TimeStamp << lefton[0] << leftoff[0] << righton[0] << rightoff[0];
            for (int cnt = 5; cnt < 29; cnt ++)
              imufile << pkt[cnt];
            imufile << endl;
          }
          break;
        case 35:
          if (magfile.is_open()) {
            magcounter ++;
            magfile << TimeStamp << lefton[0] << leftoff[0] << righton[0] << rightoff[0];
            for (int cnt = 5; cnt < 24; cnt ++)
              magfile << pkt[cnt];
            magfile << endl;
          }
          break;
        default:
          break;
      }
//      cout << imucounter << ' ' << gpscounter << ' ' << magcounter << endl;
      int maxlines = 2000;
      if (imucounter > maxlines) {
        imucounter = 0;
        imufile.close();
        imufilename = imufilebase + filedate + to_string(imufilecounter++);
        cout << "new imufile " << imufilename << endl;
        imufile.open(imufilename.c_str());
      }
      if (gpscounter > maxlines) {
        gpscounter = 0;
        gpsfile.close();
        gpsfilename = gpsfilebase + filedate + to_string(gpsfilecounter++);
        cout << "new gpsfile " << gpsfilename << endl;
        gpsfile.open(gpsfilename.c_str());
      }
      if (magcounter > maxlines) {
        magcounter = 0;
        magfile.close();
        magfilename = magfilebase + filedate + to_string(magfilecounter++);
        cout << "new magfile " << magfilename << endl;
        magfile.open(magfilename.c_str());
      }
    }
  }
  return 0;
}
