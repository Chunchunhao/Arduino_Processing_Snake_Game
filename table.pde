import processing.serial.*;
Serial serial;
// About the Direction
int[] sensorValue = new int[3];
int[] last = new int[3];
int[] stable = new int[3];
int i = 0, st_times;
int movex, speed, xx, yy;
String portName = Serial.list()[5];

// About snake
int MAXSIZE = 17;
int size = 1, lock = 1;
int xnext = 400;
int ynext = 400;
int oldxpos;
int oldypos;
int[] xpos = new int[MAXSIZE];
int[] ypos = new int[MAXSIZE];
PImage[] img = new PImage[MAXSIZE];
PImage[] bg = new PImage[MAXSIZE];
PImage begin;
PImage end;
PImage LLj, MMj, RRj;
int hh = 800, ww = 800;
// About Start and Over
//PFont f;
int fst_end = 0;
void setup() {
  size(hh, ww);
  serial = new Serial(this, portName, 9600); 
  for( i= 0; i< 3; i ++ ) {
    last[i] = 0;
    stable[i] = 0;
  }
  movex = 0;
  speed = 0;
  xx = 0; // Initial point 
  yy = 0;
  st_times = 30;  // correctness time
  smooth();
  begin = loadImage( "begin.png");
  end = loadImage("end.png");
  LLj = loadImage("bl1.png");
  MMj = loadImage("bl2.png");
  RRj = loadImage("bl3.png");
  for (i = 0; i < img.length; i ++ ) {
    bg[i] = loadImage( "bg" + i + ".png" );
    img[i] = loadImage( "p" + i + ".png" ); 
    xpos[i] = 0;
    ypos[i] = 0;  
  }
  frameRate(10);
  noStroke();

}


void draw() {
  // -------------- Get The Direction 
  if( size == MAXSIZE ) {
    background(end);
    frameRate(1);
    if( fst_end == 0 ){
      fst_end = 1 ;
      for( int i =0; i < MAXSIZE; i ++ ){
        ypos[i] = 650;
        if( i == 0)
          xpos[i] = 10;
        else
          xpos[i] = xpos[i-1] + 135;
      }
    }
    else {
      int store_old = xpos[0];
      for( int i = 0; i< MAXSIZE; i++ ) {
        if( i == MAXSIZE-1 )
          xpos[i] = store_old;
        else
          xpos[i] = xpos[i+1]; 
      }
    }
    for ( int i = 0 ; i < MAXSIZE ; i++) {
      if( i == 0 ) {
        fill(153);
        rect( xpos[0], ypos[0], 132, 132, 65);
        image(img[0], xpos[0], ypos[0], 130, 130); 
      }
      else {
        fill(100);
        rect( xpos[i], ypos[i], 122, 122, 60);
        image(img[i], xpos[i], ypos[i], 120, 120);
      }
    }
  }
  else if( serial.available() > 0) {
    sensorValue[0] = serial.read();
    sensorValue[1] = serial.read();
    sensorValue[2] = serial.read();
    for( i = 0 ; i < 3 ; i ++ ) {
       if (sensorValue[i] < 0 )
         sensorValue[i] = last[i];
       else
         last[i] = sensorValue[i]; 
    }
    println("---------------------");
    // println("0:" + sensorValue[0]);
    // println("1:" + sensorValue[1]);
    // println("2:" + sensorValue[2]);
    
    if( st_times != 0 ) { // Correctness
      background(begin);
      int check = 0;
      if( stable[0] == 0 ) {
          stable[0] = sensorValue[0];
          stable[1] = sensorValue[1];
          stable[2] = sensorValue[2];
      }
      else if( ((stable[0] + 10) > sensorValue[0]) && ((stable[0] - 10) < sensorValue[0])
            && ((stable[1] + 10) > sensorValue[1]) && ((stable[1] - 10) < sensorValue[1])
            && ((stable[2] + 10) > sensorValue[2]) && ((stable[2] - 10) < sensorValue[2])) {
        st_times = st_times - 1;
        check = 1;
      }
      if( check == 0 ) {
        fill(255, 0, 0);
        st_times = 30;
        stable[0] = sensorValue[0];
        stable[1] = sensorValue[1];
        stable[2] = sensorValue[2];
      }
      fill(100);
      rect( 350, 700 - sensorValue[0] , 125, 125, 70);
      image(LLj, 350 , 700 - sensorValue[0] ,120,120);
      rect( 500, 700 - sensorValue[1] , 125, 125, 70);
      image(MMj, 500, 700 - sensorValue[1] ,120,120);
      rect( 650, 700 - sensorValue[2] , 125, 125, 70);
      image(RRj, 650,700 - sensorValue[2] ,120,120);
    }
    else { // The code inside is after correctness
       background(bg[size]);
       speed = 0;
       movex = 0;
       // Down
       if( sensorValue[0] > stable[0] + 5 && sensorValue[1] > stable[1] + 5 && sensorValue[2] > stable[2] + 5 ){
         // println("----Down\n");
         speed = 60;
       }
       // up
       else if( sensorValue[1] < stable[1] ){
         // println("----up\n");
         speed = -60;
       }
       else {
         speed = 0;
       }
       // Turn Left or Turn Right
       if( sensorValue[0] <  sensorValue[1] && sensorValue[0] < (sensorValue[2] - 5)
           && sensorValue[0] < (stable[0] + 7)  && sensorValue[0] > (stable[0] - 7 ) ) {
             // println("----left\n");
              movex = -60;
       }
       else if( sensorValue[2] <  sensorValue[1] && sensorValue[2] < (sensorValue[0] - 5)
           && sensorValue[2] < (stable[2] + 7)  && sensorValue[2] > (stable[2] - 7 ) ) {
             // println("----right\n");
             movex = 60;
       }
       else{
         movex = 0;
       }
    // Make a move
    oldxpos = xpos[0];
    oldypos = ypos[0];
    if( movex != 0 ) {
      xpos[0] = xpos[0]  + movex;
    }
    else {
      ypos[0] = ypos[0] + speed;
    }
    
    // More then edge
    if( xpos[0] < 0 ) {
      xpos[0] = hh - 30;
    }
    else if( xpos[0] > hh - 30 ) {
      xpos[0] = 0;
    }
    if( ypos[0] < 0 ) {
      ypos[0] = ww - 30;
    }
    else if( ypos[0] > ww - 30 ) {
      ypos[0] = 0;
    }
    
    // generate a new point ?
    println(" xpos[0] : " + xpos[0] );
    println(" ypos[0] : " + ypos[0] );
    println(" xnext : " + xnext );
    println(" ynext : " + ynext );
    println(" size : " + size );
    println(" lock : " + lock ) ;
    
    if( xpos[0] < xnext + 90 && xpos[0] > xnext - 90
        && ypos[0] < ynext + 90 && ypos[0] > ynext - 90
        && size < MAXSIZE && lock == 0){
      size += 1; 
      xnext = (int)random(hh-90);
      ynext = (int)random(ww-90);
      lock = 1;
      // new move draw
      for( i = size - 1; i > 0; i -- ) {
        if( i == 1){
          xpos[1] = oldxpos;
          ypos[1] = oldypos; 
        }
        else {
          xpos[i] = xpos[i-1];
          ypos[i] = ypos[i-1]; 
        }
      }
    }
    else {
      // old move draw   
      if( size >=2 && (movex != 0 || speed != 0)){ 
        for( i = size - 1; i > 0; i -- ) {
           if( i == 1){
             xpos[1] = oldxpos;
             ypos[1] = oldypos;
           }
           else {
             xpos[i] = xpos[ i - 1];
             ypos[i] = ypos[ i - 1];
           }
        }
      }
    }
  
    if(size < MAXSIZE) {
      lock = 0;
      rect(xnext, ynext, 125, 125, 60);
      image(img[size], xnext, ynext, 120, 120);
    }
 
    for ( int i = size-1; i >= 0 ; i--) {
      if( i == 0 ) {
        fill(153);
        rect( xpos[0], ypos[0], 92, 92, 45);
        image(img[0], xpos[0], ypos[0], 90, 90); 
      }
      else {
        fill(100);
        rect( xpos[i], ypos[i], 72, 72, 35);
        image(img[i], xpos[i], ypos[i], 70, 70);
      }
    }
    }
  }
}
