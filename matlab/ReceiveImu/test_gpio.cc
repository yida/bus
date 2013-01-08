#include <fstream>
#include <string>
#include <iostream>
#include <cstdlib>
#include <cstdio>

using namespace std;

ifstream gpio146, gpio147;

int main() {
  string line1;
  string line2;

  ofstream gpio_export;
  gpio_export.open("/sys/class/gpio/export");
  gpio_export << 146;
  gpio_export.close();
  gpio_export.open("/sys/class/gpio/export");
  gpio_export << 147;
  gpio_export.close();
  
  while (1) {
    gpio146.open("/sys/class/gpio/gpio146/value");
    gpio147.open("/sys/class/gpio/gpio147/value");
    getline(gpio146, line1);
    getline(gpio147, line2);
    cout << line1 << " " << line2 << endl;
    gpio146.close();
    gpio147.close();

    usleep(100);
  }

  return 0;
}
