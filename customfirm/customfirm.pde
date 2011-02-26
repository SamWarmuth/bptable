// Send numeric data to Arduino through Firmata library using a reserved pin.
// The data received on the reserved pin is handled as needed


#include <Firmata.h>
#include <Sprite.h>
#include <Matrix.h>

int reservedPin = 6; //  Incoming Firmata data on this pin is handled specially.

Matrix ledMatrix = Matrix(2, 3, 4);

void setup()
{
    //ledMatrix.setScanLimit(6);
    Firmata.setFirmwareVersion(0, 1);
    Firmata.attach(ANALOG_MESSAGE, callback); // Call this function when analog writes are received
    Firmata.begin(57600);
    //ledMatrix.clear(); 

}




void loop()
{
   while(Firmata.available()) { // Handles Firmata serial input
       Firmata.processInput();
   }
   /*
    for (int i=0; i<8; i++){
     for (int j=2; j<8; j++){
      ledMatrix.write(j,i,HIGH);
      delay(50);
     } 
    }
  ledMatrix.clear();
  */
}

// Called whenever Arduino receives an analog msg thru Firmata
void callback(byte row, int value)
{
  for (int i=0; i < 8; i++){
    if (bitRead(value, i)) {//led on
      ledMatrix.write(i+2,row,HIGH);
    }else{//led off
      ledMatrix.write(i+2,row,LOW);
    }
  }

  digitalWrite(13, value);

}

