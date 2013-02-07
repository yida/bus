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
#include <unistd.h>

using namespace std;

ifstream gpio146, gpio147, gpio175, gpio114;
std::string lefton, leftoff, righton, rightoff;

int main(void) {
  // Enable GPIO
  ofstream gpio_export;
  gpio_export.open("/sys/class/gpio/export");
  gpio_export << 146;
  gpio_export.close();
  gpio_export.open("/sys/class/gpio/export");
  gpio_export << 147;
  gpio_export.close();
  gpio_export.open("/sys/class/gpio/export");
  gpio_export << 114;
  gpio_export.close();
  gpio_export.open("/sys/class/gpio/export");
  gpio_export << 175;
  gpio_export.close();
 
  int dircount = 1;



  while (true) {
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
    cout << lefton[0] << leftoff[0] << righton[0] << rightoff[0] << endl;


  }
  return 0;
}
