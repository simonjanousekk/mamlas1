import java.io.*;
import java.net.*;
import java.util.Arrays;

// Socket and DataOutputStream
Socket soc;
DataOutputStream dout;

// Storing array as a String
String arrayStr;

// mock up animation
float sz = 1;
color c = color(255, 0, 0);
int w = 240;
int h = 240;
int framerate = 10;

int[][][] pix = new int[w][h][3];

void settings() {
  size(w, h);
}

void setup() {
  background(0);
  frameRate(framerate);

  try {
    soc=new Socket("localhost", 8802);
    dout=new DataOutputStream(soc.getOutputStream());
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }
}

void draw () {
  rectMode(CENTER);
  noStroke();
  fill(255, 0, 0);
  rect(width/2, height/2, sz, sz);
  sz++;

  loadPixels();
  //array shape in processing: [i][j][3]

  for (int i=0; i<w; i++) {
    for (int j=0; j<h; j++) {

      color argb = pixels[i+j * width];
      int r = (argb >> 16) & 0xFF;  // Faster way of getting red(argb)
      int g = (argb >> 8) & 0xFF;   // Faster way of getting green(argb)
      int b = argb & 0xFF;          // Faster way of getting blue(argb)

      pix[i][j] =new int[]{r, g, b};
    }
  }
  // convert Array to string to enable sending over socket
  arrayStr = Arrays.deepToString(pix);

  // when the rectangle fills up the whole screen, close the connection
  if (sz < w) {
    sendArray(arrayStr);
  } else {
    try {
      soc.close();
    }
    catch(Exception e)
    {
      e.printStackTrace();
    }
  }
}

void sendArray(String a) {
  try {
    // Java method writeUTF is limited to 60000 char which is not enough for us, therefore, we send bytes 
    byte[] b = a.getBytes("utf-8");
    // We write at the beginning the length of the message, so on Python side we know how long is the array and therefore when to shift to a new frame
    // (implementation needs to be made better !!!!!)
    println(b.length);
    dout.writeInt(b.length);
    dout.write(b);
    // making sure we send the message entirely before sending a new frame (I am not sure its 100% necessary or correctly implemented)
    dout.flush();
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }
}

/* Just for testing - same method but sending array only when key is pressed
void keyPressed() {
  String a = arrayStr;
  try {
    byte[] b = a.getBytes("utf-8");
    println(b.length);
    dout.writeInt(b.length);
    dout.write(b);
    //dout.writeUTF(arrayStr);
    dout.flush();
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }
}
*/
