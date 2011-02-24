// Send numeric data to Arduino through Firmata library using a reserved pin.
// The data received on the reserved pin is handled as needed


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
void callback(byte row, int value)
{
  
  for (int i=0; i < 8; i++){
    if (bitRead(row, i) == 1) {//led on
      1+1;
      //ledMatrix.write(row,i,HIGH);
    }else{//led off
      1+1;
      //ledMatrix.write(row,i,LOW);
    }
  }
  int val = value / 100;
  int x = (value / 10)%10;
  int y = value % 10;

  digitalWrite(13, value);

}

