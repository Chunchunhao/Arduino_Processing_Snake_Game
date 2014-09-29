import processing.serial.*;
Serial serial;
int[] sensorValue = new int[3];
int[] last = new int[3];
int[] bf_last = new int[3];
int[] stable = new int[3];
int[] last_action = new int[3];
int i = 0, st_times;
int movex, speed, xx, yy;
String portName = Serial.list()[5];

int hh = 800, ww = 600;
void setup() {
  size(hh, ww);
  serial = new Serial(this, portName, 9600); 
  last[0] = 0;
  last[1] = 0;
  last[2] = 0;
  bf_last[0] = 0;
  bf_last[1] = 0;
  bf_last[2] = 0;
  stable[0] = 0;
  last_action[0] = 0;
  last_action[1] = 0;
  last_action[2] = 0;
  movex = 0;
  speed = 0;
  xx = 400;
  yy = 400;
  st_times = 30;  // correctness time
}


void draw() {
  if( serial.available() > 0) {
    sensorValue[0] = serial.read();
    sensorValue[1] = serial.read();
    sensorValue[2] = serial.read();
    for( i = 0 ; i < 3 ; i ++ ) {
       if (sensorValue[i] < 0 ){
         sensorValue[i] = last[i]; 
       }
    }
    
    println("0:" + sensorValue[0] + '\n');
    println("1:" + sensorValue[1] + '\n');
    println("2:" + sensorValue[2] + '\n');
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
              speed = -10;
            }
            else if ( (sensorValue[0] - sensorValue[2]) > (sensorValue[0] - sensorValue[1] + 5)){
              // forward
              movex = 0;
              speed = 10; 
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
              speed = -10;
            }
            else if ( (sensorValue[2] - sensorValue[0]) >= (sensorValue[2] - sensorValue[1] + 5)){
              // forward
              println("forward \n");
              movex = 0;
              speed = 10; 
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
              movex = -5;
              speed = 0;
            }
            else if( sensorValue[2] <  sensorValue[1] && sensorValue[2] < sensorValue[0] 
             && sensorValue[2] < (stable[2] + 7)  && sensorValue[2] > (stable[2] - 7 )
             && sensorValue[0] < (bf_last[0] + 3) && sensorValue[0] > (bf_last[0] - 3)
             && sensorValue[1] < (bf_last[1] + 3) && sensorValue[1] > (bf_last[1] - 3)
             && sensorValue[2] < (bf_last[2] + 3) && sensorValue[2] > (bf_last[2] - 3) ) {
              // move right
              println("----right\n");
              movex = 5;
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
      
      rect(sensorValue[0]+50, 300,50,50);
      rect(sensorValue[1]+50, 200,50,50);
      rect(sensorValue[2]+50, 100,50,50);
      rect( xx, yy, 30, 30);
  } 
}
