import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioInput source;
  
  BeatListener(BeatDetect beat, AudioInput source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}


Minim minim;
AudioInput in;
BeatDetect beat;
BeatListener bl;
FFT fft;


Arduino arduino;
int[] leds = {11, 10, 9, 6};

int ledPin = 13;
 
void setup()
{
  arduino = new Arduino(this, Arduino.list()[0], 57600);

  //for (int i = 0; i < 4; i++) arduino.pinMode(leds[i], Arduino.OUTPUT);
  
  arduino.pinMode(ledPin, Arduino.OUTPUT);
  size(800, 620);
 
  minim = new Minim(this);
 
  // get a stereo line-in: sample buffer length of 512
  // default sample rate is 44100, default bit depth is 16
  in = minim.getLineIn(Minim.STEREO, 512);
  // create a recorder that  will record from the input 
  // to the filename specified, using buffered recording
  // buffered recording means that all captured audio 
  // will be written into a sample buffer
  // then when save() is called, the contents of the buffer 
  // will actually be written to a file
  // the file will be located in the sketch's root folder.
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  bl = new BeatListener(beat, in);
  
  fft = new FFT(in.bufferSize(), in.sampleRate());

  fft.linAverages(390);


  textFont(createFont("Arial", 12));
}
float currentvalue = 0;
float generalvolume = 3.0;
float correctedvalue = 0;
float smoothedvalue = 0;
float[] multiaverage = new float[100];
float beatStrength = 0;
float snareStrength = 0;
int output;
int cycleType = 1;
int counter = 0;
boolean[] bOutput = new boolean[48];
boolean[] row = new boolean[8];
int rowInt = 0;

void draw()
{
  background(0);
  stroke(255, 255, 255);
  fft.forward(in.mix);
  float average = 0;
  int specs = fft.specSize();
  float theMiddle = 0;
  float curFreq;

  for(int i = 0; i < 100; i++)
  {
    curFreq = fft.getFreq(i*150);
    multiaverage[i] += curFreq*0.5;
    multiaverage[i] *= 0.75;
    
    theMiddle += 1.5*i*multiaverage[i];
    
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
    line(i*4+25, 375, i*4+25, 375 - curFreq*15);
    line(i*4+525, 375, i*4+525, 375 - multiaverage[i]*15);
  }

  
  
    text("Middle Freq (mean): " + theMiddle, 550, 10);
  
  
  

  stroke(255, 255, 255);

  for(int i = 0; i < in.left.size()-1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
    currentvalue += Math.abs(in.right.get(i));
  }
  currentvalue *= 0.3;
  generalvolume = generalvolume * 0.9995 + currentvalue*0.0005;

  correctedvalue = (40*currentvalue)/generalvolume;
  if (correctedvalue > 100) correctedvalue = 100;
  
  
  line(20, 290 - currentvalue , 480, 290 - currentvalue);
  
  
  text("Instant: " + currentvalue, 10, 200);
  ellipse(50,250, currentvalue, currentvalue);
  
  
  text("music loudness: " + generalvolume, 80, 225);
  ellipse(150,250, generalvolume, generalvolume);
  text("Corrected Level: " + correctedvalue, 150, 200);
  fill(127,0,0);
  ellipse(350,200, 100, 100);
  fill(255,255,255);

  ellipse(350,200, correctedvalue, correctedvalue);
  
  if (correctedvalue > 40){
    arduino.analogWrite(6, Arduino.HIGH);
    //arduino.digitalWrite(ledPin, Arduino.HIGH);
  }else{
    arduino.analogWrite(6, Arduino.LOW);
    //arduino.digitalWrite(ledPin, Arduino.LOW);
  }
  
  int centerFreq = int(theMiddle/2);
  if (centerFreq > 255) centerFreq = 255;
  
  smoothedvalue = smoothedvalue*0.3 + correctedvalue*0.7;
  output = int((smoothedvalue/6)*(smoothedvalue/6));
  text("output: " + output, 550, 200);
  
  int complement = output;
  if (complement > 255) complement = 255;
  
  
  
  beat.detect(in.mix);
  int snare = 0;
  snareStrength *= 0.75;
  if ( beat.isHat()||beat.isSnare()||beat.isKick() ) snareStrength = 255;
  snareStrength *= 0.99;

  
  int currentSeconds = (millis())%2;
  snare = 0;

  line(0, 400, 800, 400);
  
  //Draw BP Table
  
  fill(0,0,0);
  stroke(75, 75, 75);
  rect(10, 410, 780, 195);
  rect(275, 430, 250, 160);
  
  
  int[] xVals = {
    50, 90, 130, 170, 210, // top left straight
    580, 620, 660, 700, 740, // top right straight
    130, 140, 150, 160, 150, 140, 130, // far left chevron
    170, 180, 190, 200, 190, 180, 170, // second left chevron
    

    620, 610, 600, 590, 600, 610, 620, // second right chevron
    660, 650, 640, 630, 640, 650, 660, // far right chevron
    
    50, 90, 130, 170, 210, // bottom left straight
    580, 620, 660, 700, 740 // bottom right straight
    };
  int[] yVals = {
    425, 425, 425, 425, 425, //top left straight
    425, 425, 425, 425, 425, //top right straight
    470, 480, 490, 500, 510, 520, 530, // far left chevron
    470, 480, 490, 500, 510, 520, 530, // second left chevron
    

    470, 480, 490, 500, 510, 520, 530, // second right chevron
    470, 480, 490, 500, 510, 520, 530, // far right chevron
    
    585, 585, 585, 585, 585, //bottom left straight
    585, 585, 585, 585, 585 //bottom right straight

    };
    
    
    
  //the real positions don't match these. Here are the conversions.
  int[] converter = {
    43, 42, 36, 30, 24, 19, 18, 12, 6, 0, //top lines
    37, 38, 44, 45, 46, 39, 40, 
    25, 26, 31, 32, 33, 27, 28,
    13, 14, 20, 21, 22, 15, 16,
    1, 2, 7, 8, 9, 3, 4,
    47, 41, 35, 34, 29, 23, 17, 11, 10, 5
  };
    

  noStroke();
  float value;
  for(int i = 0; i < xVals.length; i++)
  {
    if (cycleType == 1){
      value = travelingChevsVolLines(i);
    }else if(cycleType == 2){
      value = cycleChevsVolLines(i);
    }else if(cycleType == 3){
      value = dualEQ(i);
    }else if(cycleType == 4){
      value = cycleAll(i);
    }else if(cycleType == 5){
      value = volumeAllBiasOn(i);
    }else{
      value = volumeAll(i) ;
    }
    
    //on, cycleAll, cycleChevsVolLines, dualEQ
    
    boolean boolVal = value > 0.4 ? true : false;
    bOutput[converter[i]] = boolVal;
    //if (bOutput[i]) print("1");
    //else print("0");

    //int octalAddress =  (10*(i/8) + i%8);

    

    if (i%2 == 0){
      fill(200*value, 200*value, 0);
    } else {
      fill(0, 0, 250*value);
    }
    ellipse(xVals[i],yVals[i], 9, 9);
  }
  
  for (int i = 0; i < 6; i++){
    rowInt = 0;
    for (int j=0; j < 8; j++){
      rowInt += pow(2, j) * (bOutput[i*8 + j] ? 1 : 0);
      //row[j] = bOutput[i*8 + j];
      //if (row[j]) print("1");
      //else print("0");
    }
   //print(rowInt);
   arduino.analogWrite(i, rowInt);
  }
  
  fill(255, 255, 255);
  
  
  
  //End BP Table Drawing
}

float on(int index){
  return 1.0;
}

float volumeAll(int index){
  return output/255.0;
}

float volumeAllBiasOn(int index){
  return output/383.0 + 0.33;
}

float cycleAll(int index){//cycle through all LEDs
  int timePeriod = int(millis()/75)%48; // twentieth of a second
  if (Math.abs((index+5) - timePeriod) < 5) return 1.0;
  else return 0.0;
}

float cycleChevsVolLines(int index){//Cycle the chevrons, brightness of lines is volume
  if (index < 10 || index > 37){ // lines
    return output/255.0; //percent volume strength
  }else{ // chevrons
    return cycleChevOnly(index);
  }
}

float travelingChevsVolLines(int index){
  if (index < 10 || index > 37){ // lines
    return output/255.0; //percent volume strength
  }else{ // chevrons
    return travelingChevLights(index);
  } 
}

float dualEQ(int index){
  if (index < 10 || index > 37){
    if (index > 20) index = (index-8)%10;
    if (index > 4) index = 9 - index;
    if (output > index * 15) return 1.0;
    else return 0.0;
  }else{
    index -= 10; //start first chev at 0
    index = index%28;
    if (index > 13) index = 27-index; //reverse second set
    int[] order = {1,2,3,4,3,2,1,5,6,7,8,7,6,5};
    
    if (output > order[index] * 20) return 1.0;
    else return 0.0;
  }
}

float cycleChevOnly(int index){
  int timePeriod = int(millis()/75)%28 + 10; // fifteenth of a second
  if (index == timePeriod) return 1.0;
  else return 0.0; 
}

float arrowChevs(int index){
    int timePeriod = int(millis()/250)%10; // fifteenth of a second
    index -= 10; //start first chev at 0
    index = index%28;
    if (index > 13) index = 27-index; //reverse second set
    int[] order = {1,2,3,4,3,2,1,5,6,7,8,7,6,5};
    
    if (timePeriod > order[index]) return 1.0;
    else return 0.0; 
}

float travelingChevHoles(int index){
    int timePeriod = int(millis()/50)%10; // fifteenth of a second
    index -= 10; //start first chev at 0
    index = index%28;
    if (index > 13) index = 27-index; //reverse second set
    int[] order = {1,2,3,4,3,2,1,5,6,7,8,7,6,5};
    
    if (timePeriod == order[index]) return 0.0;
    else return 1.0; 
}

float travelingChevLights(int index){
    int timePeriod = int(millis()/75)%10; // fifteenth of a second
    index -= 10; //start first chev at 0
    index = index%28;
    if (index > 13) index = 27-index; //reverse second set
    int[] order = {1,2,3,4,3,2,1,5,6,7,8,7,6,5};
    if (timePeriod == order[index]) return 1.0;
    else if (Math.abs(timePeriod - order[index]) == 1) return 0.6;
    else if (Math.abs(timePeriod - order[index]) == 2) return 0.3;
    else return 0.0; 
}







 
void keyReleased()
{
  if ( key == 'c' )
  {
    //set general volume level to current value -- recalibrate
    generalvolume = currentvalue;
  }
  
  //set animation types
  if ( key == '1' ) cycleType = 1;
  if ( key == '2' ) cycleType = 2;
  if ( key == '3' ) cycleType = 3;
  if ( key == '4' ) cycleType = 4;
  if ( key == '5' ) cycleType = 5;
  if ( key == '6' ) cycleType = 6;
  if ( key == '7' ) cycleType = 7;
  if ( key == '8' ) cycleType = 8;
  if ( key == '9' ) cycleType = 9;
}
 
void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  // always stop Minim before exiting
  minim.stop();
 
  super.stop();
}
