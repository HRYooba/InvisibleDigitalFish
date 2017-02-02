import processing.video.*;
import jp.nyatla.nyar4psg.*;

final int CAM_WIDTH = 640;
final int CAM_HEIGHT = 480;

Capture cam;
MultiMarker nya;

PVector[] p;
PImage backImg;
PImage blendImg;
PGraphics pg;
PShader sd;

void setup() {
  size(640, 480, P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);
  cam = new Capture(this, 640, 480);
  nya = new MultiMarker(this, width, height, "data/camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);
  nya.addARMarker("data/patt.hiro", 80);
  cam.start();
  backImg = createImage(CAM_WIDTH, CAM_HEIGHT, RGB);
  blendImg = loadImage("blend.png");
  pg = createGraphics(CAM_WIDTH, CAM_HEIGHT);

  float angle = TWO_PI / NUMBER;
  for (int i = 1; i <= NUMBER; i++) {
    float addx = cos(angle * i);
    float addy = sin(angle * i);
    balls[i-1] = new Ball(
      random(width), random(height), 
      random(- SPEED, SPEED) * addx, random(- SPEED, SPEED) * addy, i - 1, balls);
  }

  //sd = loadShader("swell.glsl");
  //sd.set("timer", 0.1);
  //sd.set("image", backImg);
}

void draw()
{
  translate(width, 0);
  scale(-1, 1);
  if (cam.available() !=true) {
    return;
  }
  cam.read();
  nya.detect(cam);
  //nya.drawBackground(cam);
  image(cam, 0, 0);

  if ((!nya.isExist(0))) {
    return;
  }

  pg.beginDraw();
  pg.tint(150 + 50 * sin(frameCount / 180.0 * PI));
  pg.image(backImg, 0, 0);
  pg.noFill();
  pg.stroke(210, 255, 255, 200);
  for (int i = 0; i < NUMBER; i++) {
    balls[i].clearVector();
  }
  for (int i = 0; i < NUMBER; i++) {
    Ball ball = (Ball) balls[i];
    ball.check();
    ball.move();
    float angle = atan2(ball.vy, ball.vx);
    ball.setAngle(angle);

    pg.pushMatrix();
    pg.translate(ball.x, ball.y);
    pg.strokeWeight(1);
    pg.ellipse(0, 0, 3, 3);
    pg.ellipse(- 20 * cos(angle + QUARTER_PI * 0.6), - 20 * sin(angle + QUARTER_PI * 0.6), 1, 1);
    pg.ellipse(- 20 * cos(angle - QUARTER_PI * 0.6), - 20 * sin(angle - QUARTER_PI * 0.6), 1, 1);
    pg.line(0, 0, - 20 * cos(angle + QUARTER_PI * 0.6), - 20 * sin(angle + QUARTER_PI * 0.6));
    pg.line(0, 0, - 20 * cos(angle - QUARTER_PI * 0.6), - 20 * sin(angle - QUARTER_PI * 0.6));
    pg.line(0, 0, - 6.5 * cos(angle), - 6.5 * sin(angle));
    for (int j = 1; j < ball.buffAngle.size(); j ++) {
      pg.strokeWeight(0.7);
      pg.ellipse(- 6.5 * j * cos(ball.buffAngle.get(j - 1)), - 6.5 * j * sin(ball.buffAngle.get(j - 1)), 8 - j, 8 - j);
      pg.strokeWeight(0.5);
      pg.line(- 6.5 * j * cos(ball.buffAngle.get(j - 1)), - 6.5 * j * sin(ball.buffAngle.get(j - 1)), 
        - 6.5 * (j + 1) * cos(ball.buffAngle.get(j)), - 6.5 * (j + 1) * sin(ball.buffAngle.get(j)));
    }
    pg.popMatrix();
  }
  pg.endDraw();

  //image(pg, 0, 0);

  p = nya.getMarkerVertex2D(0);
  beginShape();
  texture(pg);
  vertex(p[0].x, p[0].y, p[0].x, p[0].y);
  vertex(p[1].x, p[1].y, p[1].x, p[1].y);
  vertex(p[2].x, p[2].y, p[2].x, p[2].y);
  vertex(p[3].x, p[3].y, p[3].x, p[3].y);
  endShape();

  //nya.beginTransform(0);
  //fill(0, 0, 255, 50);
  //translate(0, 0, 20);
  //box(70);
  //nya.endTransform();
}

void mousePressed() {
  backImg = cam.copy();
  backImg.blend(blendImg, 0, 0, CAM_WIDTH, CAM_HEIGHT, 0, 0, CAM_WIDTH, CAM_HEIGHT, ADD);
}