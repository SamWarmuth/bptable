// Send numeric data to Arduino through Firmata library using a reserved pin.
// The data received on the reserved pin is handled as needed
// In this example, the brightness of an RGB LED is controlled by the value received through the pin

#include <Firmata.h>
#include <Sprite.h>
#include <Matrix.h>

int reservedPin = 6; //  Incoming Firmata data on this pin is handled specially.

Matrix ledMatrix = Matrix(2, 3, 4);

void setup()
{

    Firmata.setFirmwareVersion(0, 1);
    Firmata.attach(ANALOG_MESSAGE, callback); // Call this function when analog writes are received

    Firmata.begin(57600);

}

void loop()
{
    while(Firmata.available()) { // Handles Firmata serial input
        Firmata.processInput();
    }
}

// Called whenever Arduino receives an analog msg thru Firmata
void callback(byte pin, int value)
{

  int val = value / 100;
  int x = (value / 10)%10;
  int y = value % 10;
  //ledMatrix.write(x,y,value);
  digitalWrite(13, value);

}

