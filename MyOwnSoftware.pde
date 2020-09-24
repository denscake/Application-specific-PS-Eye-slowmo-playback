import cl.eye.*;


final int profile = 0; // 0 320*240@125 or 1 640*480@75

final int viewport_w = 320; // window will be twice as wide
final int viewport_h = 240;

final int camera_resolution[] = {
  CLCamera.CLEYE_QVGA, CLCamera.CLEYE_VGA
}; // 320*240@125 or 640*480@75
final int camera_framerate[] = {
  100, 75
}; // 320*240@125 or 640*480@75
final int camera_color = 1; // 0 - monochrome, 1 - color
final int camera_frame_w[] = {
  320, 640
};
final int camera_frame_h[] = {
  240, 480
};

final int framebuffer_lenght = 3; // in seconds
int framebuffer_frames = camera_framerate[profile] * framebuffer_lenght;

PImage framebuffer[] = new PImage[framebuffer_frames];

CLCamera pseye[] = new CLCamera[1]; //it is multicam API, there is no way to create only one camera

int frame_counter = 0; //counting what frame is current;
int frame_index = 0;
int frame_index2 = 0;
int frame_index3 = 0;

PImage frame = new PImage();

boolean triggered = false;
int recent_frame = 0;
int trig_counter = 0;

PImage interframe = new PImage();

int replay_bar = 0;
int record_bar = 0;


void setup() {
  if (!setupCamera()) exit();

  for (int i = 0; i < framebuffer_frames; i++) {
    framebuffer[i] = createImage(320, 240, RGB);
  }
  frame = createImage(320, 240, RGB);
  interframe = createImage(320, 240, RGB);

  frameRate(camera_framerate[profile]);

  size(viewport_w * 2, viewport_h);
}

void draw() {




  if (triggered == false) {
    frame_index = frame_counter % framebuffer_frames;
    pseye[0].getCameraFrame(framebuffer[frame_index].pixels, 2000);
    framebuffer[frame_index].updatePixels();

    if (frame_counter % (camera_framerate[profile] / 25) == 0) {

      frame = framebuffer[frame_index];
      frame.updatePixels();

      image(frame, 0, 0);
      image(frame, 320, 0);


      print(frame_index);
      print(" ");
      println(frame_counter);
    }

    frame_counter ++;

    trig_counter ++;

    if (trig_counter < framebuffer_frames - 2) {
      record_bar = int(map(trig_counter, 0, framebuffer_frames - 1, 0, 320 ));
      fill(50, 230, 50);
      rect(0, 0, record_bar, 5);
    }
  }
  else {
    pseye[0].getCameraFrame(interframe.pixels, 2000);
    interframe.updatePixels();

    if (frame_index2 % (camera_framerate[profile] / 25)  == 0) {
      frame_index3 %= framebuffer_frames;
      if (profile == 0) {
        //frame.resize(320, 240);
        frame = framebuffer[frame_index3];
        frame.updatePixels();
        //frame.resize(640, 480);
      }
      else {
        frame = framebuffer[frame_index3];
      }
      image(frame, 320, 0);
      image(interframe, 0, 0);
      frame_index3 ++;
      trig_counter ++;
      println(frame_index3);


      replay_bar = int(map(trig_counter, 0, framebuffer_frames - 1, 0, 320 ));
      fill(230, 50, 230);
      rect(320, 0, replay_bar, 5);

      if (trig_counter > framebuffer_frames - 2) {
        triggered = false;
        trig_counter = 0;
      }
    }
    frame_index2 ++;
  }
}

boolean setupCamera() {
  println("Setting up camera");

  if (CLCamera.cameraCount() == 0)  return false; //if there is no camera then programm exits

  pseye[0] = new CLCamera(this); // create and init new camera
  pseye[0].createCamera(0, camera_color, camera_resolution[profile], camera_framerate[profile]);
  //camera ID, monochrome/color, QVGA/VGA, 125/75;


  pseye[0].setCameraParam(CLCamera.CLEYE_AUTO_EXPOSURE, 1);
  //pseye[0].setCameraParam(CLCamera.CLEYE_EXPOSURE, 100
  pseye[0].setCameraParam(CLCamera.CLEYE_AUTO_GAIN, 1);
  //pseye[0].setCameraParam(CLCamera.CLEYE_GAIN, 100);
  pseye[0].setCameraParam(CLCamera.CLEYE_AUTO_WHITEBALANCE, 1);

  // Starts camera captures
  pseye[0].startCamera();

  println("Complete Initializing Cameras");
  return true;
}

void keyPressed() {

  if (key == 't' || key == 'T') {
    triggered = true;
    frame_index3 = frame_counter;
    recent_frame = frame_counter % framebuffer_frames;
    trig_counter = 0;
  }
  else if (key == 'r' || key == 'R') {
    triggered = false;
    trig_counter = 0;
  }
  else if (key == 'y' || key == 'U' && triggered == false) {
    trig_counter = 0;
  }
  else if (key == '1') {
    triggered = true;
    frame_index3 = frame_counter + int (framebuffer_frames *0.6);
    recent_frame = frame_index3 % framebuffer_frames;
    trig_counter = int (framebuffer_frames *0.6);
  }
}


long map(long x, long in_min, long in_max, long out_min, long out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

