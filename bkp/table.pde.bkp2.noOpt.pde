import processing.serial.*;
Serial serial;
// About the Direction
int[] sensorValue = new int[3];
int[] last = new int[3];
int[] bf_last = new int[3];
int[] stable = new int[3];
int i = 0, st_times;
int movex, speed, xx, yy;
String portName = Serial.list()[5];

// About snake
int MAXSIZE = 21;
int size = 1, lock = 1;
int xnext;
int ynext;
int oldxpos;
int oldypos;
int[] xpos = new int[MAXSIZE];
int[] ypos = new int[MAXSIZE];
PImage[] img = new PImage[MAXSIZE];

int hh = 1200, ww = 800;

void setup() {
  size(hh, ww);
  serial = new Serial(this, portName, 9600); 
  for( i= 0; i< 3; i ++ ) {
    last[i] = 0;
    bf_last[i] = 0;
    stable[i] = 0;
  }
  movex = 0;
  speed = 0; // movey
  
  xx = 0; // Initial point 
  yy = 0;
  
  st_times = 30;  // correctness time

  smooth();
  for(i = xpos.length - 1; i >= 0; i--) {
     if( i == xpos.length - 1){
       xpos[i] = 0;
       ypos[i] = 0; 
     }
     else{
       xpos[i] = xpos[i+1] + 50;
       ypos[i] = ypos[i+1];
     }
   }
   
   for (i = 0; i < img.length; i ++ ) {
     img[i] = loadImage( "p" + i + ".png" ); 
   }
   oldxpos = xpos[0];
   oldypos = ypos[0];
   frameRate(15);
   noStroke();

}


void draw() {
  // -------------- Get The Direction 
  if( serial.available() > 0) {
    sensorValue[0] = serial.read();
    sensorValue[1] = serial.read();
    sensorValue[2] = serial.read();
    for( i = 0 ; i < 3 ; i ++ ) {
       if (sensorValue[i] < 0 ){
         sensorValue[i] = last[i]; 
       }
    }
    println("---------------------");
    println("0:" + sensorValue[0]);
    println("1:" + sensorValue[1]);
    println("2:" + sensorValue[2]);
      background(255);
      
      bf_last[0] = last[0];
      bf_last[1] = last[1];
      bf_last[2] = last[2];
      last[0] = sensorValue[0];
      last[1] = sensorValue[1];
      last[2] = sensorValue[2];
      
      if( st_times != 0 ) { // Correctness
        int check = 0;
        if( stable[0] == 0 ) {
          stable[0] = sensorValue[0];
          stable[1] = sensorValue[1];
          stable[2] = sensorValue[2];
        }
        else if( ((stable[0] + 7) > sensorValue[0])  && ((stable[0] - 7) < sensorValue[0])) { 
          if( ((stable[1] + 7) > sensorValue[1])  && ((stable[1] - 7) < sensorValue[1])) {
            if( ((stable[2] + 7) > sensorValue[2])  && ((stable[2] - 7) < sensorValue[2])) {
              st_times = st_times - 1;
              check = 1;  
            }
          }
        }
        if( check == 0 ){
          stable[0] = sensorValue[0];
          stable[1] = sensorValue[1];
          stable[2] = sensorValue[2]; 
          fill(255, 0, 0);
          st_times = 30;
        }
      }
      else { // The code inside is after correctness
          speed = 0;
          movex = 0;
          // Forward and backward
          if( sensorValue[0] > sensorValue[2] 
             && (sensorValue[0] - sensorValue[2] < 3 ) 
             && sensorValue[0] < (bf_last[0] + 3) && sensorValue[0] > (bf_last[0] - 3)
             && sensorValue[1] < (bf_last[1] + 3) && sensorValue[1] > (bf_last[1] - 3)
             && sensorValue[2] < (bf_last[2] + 3) && sensorValue[2] > (bf_last[2] - 3) ){
            if( (sensorValue[0] - sensorValue[2]) <= (sensorValue[0] - sensorValue[1] + 5)){
              // backward
              movex = 0;
              speed = -50;
            }
            else if ( (sensorValue[0] - sensorValue[2]) > (sensorValue[0] - sensorValue[1] + 5)){
              // forward
              movex = 0;
              speed = 50; 
            }
          }
          else if( sensorValue[2] > sensorValue[0] 
             && (sensorValue[2] - sensorValue[0] < 3)
             && sensorValue[0] < (bf_last[0] + 3) && sensorValue[0] > (bf_last[0] - 3)
             && sensorValue[1] < (bf_last[1] + 3) && sensorValue[1] > (bf_last[1] - 3)
             && sensorValue[2] < (bf_last[2] + 3) && sensorValue[2] > (bf_last[2] - 3) ) {
            if( (sensorValue[2] - sensorValue[0]) < (sensorValue[2] - sensorValue[1] + 5) ){
              // backward
              println("backward \n");
              movex = 0;
              speed = -50;
            }
            else if ( (sensorValue[2] - sensorValue[0]) >= (sensorValue[2] - sensorValue[1] + 5)){
              // forward
              println("forward \n");
              movex = 0;
              speed = 50; 
            }
          }
          if( speed == 0 ) {  // Left or Right
            if( sensorValue[0] <  sensorValue[1] && sensorValue[0] < sensorValue[2] 
             && sensorValue[0] < (stable[0] + 7)  && sensorValue[0] > (stable[0] - 7 )
             && sensorValue[0] < (bf_last[0] + 3) && sensorValue[0] > (bf_last[0] - 3)
             && sensorValue[1] < (bf_last[1] + 3) && sensorValue[1] > (bf_last[1] - 3)
             && sensorValue[2] < (bf_last[2] + 3) && sensorValue[2] > (bf_last[2] - 3) ) {
              // move left
              println("----left\n");
              movex = -50;
              speed = 0;
            }
            else if( sensorValue[2] <  sensorValue[1] && sensorValue[2] < sensorValue[0] 
             && sensorValue[2] < (stable[2] + 7)  && sensorValue[2] > (stable[2] - 7 )
             && sensorValue[0] < (bf_last[0] + 3) && sensorValue[0] > (bf_last[0] - 3)
             && sensorValue[1] < (bf_last[1] + 3) && sensorValue[1] > (bf_last[1] - 3)
             && sensorValue[2] < (bf_last[2] + 3) && sensorValue[2] > (bf_last[2] - 3) ) {
              // move right
              println("----right\n");
              movex = 50;
              speed = 0;
            }
            else{
              movex = 0;
              speed = 0; 
            }
          }
        fill(0, 255, 0); 
      }
      xx = xx + movex;
      yy = yy + speed;
      if( xx < 0 ) {
         xx = hh; 
      }
      if( xx > hh ) {
         xx  = 0;
      }
      if( yy < 0 ) {
        yy = ww;  
      }
      if( yy > ww ) {
          yy = 0; 
      }
      
      
      // Snake move
      xpos[0] = xx;
      ypos[0] = yy;
      if( movex != 0 && speed != 0 ) {
        for ( int i = xpos.length-1; i > 0; i --) {
          xpos[i] = xpos[i-1];
          ypos[i] = ypos[i-1]; 
        }
      }
      if( xpos[0] < xnext+90 && xpos[0] > xnext
         && ypos[0] < ynext+90 && ypos[0] > ynext 
         && size < MAXSIZE && lock == 0){
        size += 1; 
        xnext = (int)random(1000);
        ynext = (int)random(600);
        lock = 1;
      }
  
      if(size < MAXSIZE-1) {
        lock = 0;
        rect(xnext, ynext, 80, 80);
        image(img[size+1], xnext, ynext, 80, 80);
      }
 
      for ( int i = 0; i < size ; i++) {
         // fill(255-i*5);
         rect( xx, yy, 80, 80);
         image(img[i], xpos[i], ypos[i], 80, 80);
         //ellipse(xpos[i], ypos[i], i+100, i+100); 
      }
      
      rect(sensorValue[0]+50, 300,20,20);
      rect(sensorValue[1]+50, 400,20,20);
      rect(sensorValue[2]+50, 500,20,20);
  } 
}
