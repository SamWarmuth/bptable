// Send numeric data to Arduino through Firmata library using a reserved pin.
// The data received on the reserved pin is handled as needed
// In this example, the brightness of an RGB LED is controlled by the value received through the pin

#include <Firmata.h>

int redPin   = 9;
int greenPin = 10;
int bluePin  = 11;

int reservedPin = 6; //  Incoming Firmata data on this pin is handled specially.

void setup()
{

    Firmata.setFirmwareVersion(0, 1);
    Firmata.attach(ANALOG_MESSAGE, analogWriteCallback); // Call this function when analog writes are received

    Firmata.begin(57600);

    pinMode(redPin,   OUTPUT);  // Setup this pin for output
    pinMode(greenPin, OUTPUT);  // Setup this pin for output
    pinMode(bluePin,  OUTPUT);  // Setup this pin for output
}

void loop()
{
    while(Firmata.available()) { // Handles Firmata serial input
        Firmata.processInput();
    }
}

// Called whenever Arduino receives an analog msg thru Firmata
void analogWriteCallback(byte pin, int value) 
{
    // If data is sent to reserved pin, execute code
    if(pin == reservedPin) {
      digitalWrite(13, value);
    }
    
    // Otherwise, just send the pin value to the appropriate pin on the Arduino
    else {
      pinMode(pin,OUTPUT);
      analogWrite(pin, value);
    }  
}

