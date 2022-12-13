import java.io.*;
import java.util.*;

PVector cameraPosition = new PVector();
Camera cameraObject = new Camera();
int gridSize = 100;
int gridUnit = 10;

/*========== Monsters ==========*/
Animation monsterAnim;
ShapeInterpolator monsterForward = new ShapeInterpolator();
ShapeInterpolator monsterReverse = new ShapeInterpolator();
ShapeInterpolator monsterSnap = new ShapeInterpolator();

/*========== Sphere ==========*/
Animation sphereAnim; // Load from file
Animation spherePos; // Create manually
ShapeInterpolator sphereForward = new ShapeInterpolator();
PositionInterpolator spherePosition = new PositionInterpolator();

/*========== Cubes ==========*/
ArrayList<PositionInterpolator> cubes = new ArrayList<PositionInterpolator>();

void setup()
{
  pixelDensity(2);
  size(1200, 800, P3D);

  /*====== Load Animations ======*/
  monsterAnim = ReadAnimationFromFile("monster.txt");
  sphereAnim = ReadAnimationFromFile("sphere.txt");

  monsterForward.SetAnimation(monsterAnim);
  monsterReverse.SetAnimation(monsterAnim);
  monsterSnap.SetAnimation(monsterAnim);
  monsterSnap.SetFrameSnapping(true);

  sphereForward.SetAnimation(sphereAnim);

  /*====== Create Animations For Cubes ======*/
  // When initializing animations, to offset them
  // you can "initialize" them by calling Update()
  // with a time value update. Each is 0.1 seconds
  // ahead of the previous one

  int cubeIndex = 0;
  float offset = 0.0f;
  int[] zVals = {0, -100, 0, 100};

  // this creates my 11 box animations
  for (int i = -gridSize; i <= gridSize; i +=20)
  {
    Animation boxAnim = new Animation();

    float keyFrameTime = 0.5f;      // it takes 0.5 seconds to get between key frames

    // initialize 4 key frames; each gets one time and one point
    for (int j = 0; j < 4; j++)
    {
      boxAnim.keyFrames.add(new KeyFrame());
      boxAnim.keyFrames.get(j).points.add(new PVector(i, 0, zVals[j]));

      boxAnim.keyFrames.get(j).time = keyFrameTime;
      keyFrameTime += 0.5f;
    }

    cubes.add(new PositionInterpolator());

    // set which cubes are supposed to snap
    if (cubeIndex % 2 != 0)
    {
      cubes.get(cubeIndex).SetFrameSnapping(true);
    } else
    {
      cubes.get(cubeIndex).SetFrameSnapping(false);
    }

    cubes.get(cubeIndex).SetAnimation(boxAnim);

    cubeIndex++;
  }

  for (int i = 0; i < 11; i++)
  {
    cubes.get(i).Update(offset);
    offset += 0.1f;
  }

  /*====== Create Animations For Spheroid ======*/
  // Create and set keyframes

  spherePos = new Animation();

  // initialize 4 key frames; each gets one time and one point
  spherePos.keyFrames.add(new KeyFrame());
  spherePos.keyFrames.get(0).points.add(new PVector(-100, 0, 100));
  spherePos.keyFrames.get(0).time = 1.0f;

  spherePos.keyFrames.add(new KeyFrame());
  spherePos.keyFrames.get(1).points.add(new PVector(-100, 0, -100));
  spherePos.keyFrames.get(1).time = 2.0f;

  spherePos.keyFrames.add(new KeyFrame());
  spherePos.keyFrames.get(2).points.add(new PVector(100, 0, -100));
  spherePos.keyFrames.get(2).time = 3.0f;

  spherePos.keyFrames.add(new KeyFrame());
  spherePos.keyFrames.get(3).points.add(new PVector(100, 0, 100));
  spherePos.keyFrames.get(3).time = 4.0f;

  spherePosition.SetAnimation(spherePos);
}

void draw()
{
  lights();
  background(0);

  // create projection matrix to convert 3D to 2D
  perspective(radians(50.0f), width/(float)height, 0.1, 1000);

  //camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
  camera(cameraPosition.x, cameraPosition.y, cameraPosition.z,
    0, 0, 0,
    0, 1, 0);

  cameraPosition = cameraObject.Update(cameraPosition);

  DrawGrid();

  float playbackSpeed = 0.005f;


  /*====== Draw Forward Monster ======*/
  pushMatrix();
  translate(-40, 0, 0);
  monsterForward.fillColor = color(128, 200, 54);
  fill(monsterForward.fillColor);
  monsterForward.Update(playbackSpeed);
  shape(monsterForward.currentShape);
  popMatrix();

  /*====== Draw Reverse Monster ======*/
  pushMatrix();
  translate(40, 0, 0);
  monsterReverse.fillColor = color(220, 80, 45);
  fill(monsterReverse.fillColor);
  monsterReverse.Update(-playbackSpeed);
  shape(monsterReverse.currentShape);
  popMatrix();

  /*====== Draw Snapped Monster ======*/
  pushMatrix();
  translate(0, 0, -60);
  monsterSnap.fillColor = color(160, 120, 85);
  fill(monsterSnap.fillColor);
  monsterSnap.Update(playbackSpeed);
  shape(monsterSnap.currentShape);
  popMatrix();

  /*====== Draw Spheroid ======*/
  spherePosition.Update(playbackSpeed);
  sphereForward.fillColor = color(39, 110, 190);
  fill(sphereForward.fillColor);
  sphereForward.Update(playbackSpeed);
  PVector pos = spherePosition.currentPosition;
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  shape(sphereForward.currentShape);
  popMatrix();

  /*====== Update and draw cubes ======*/
  // For each interpolator, update/draw
  color red = color(255, 0, 0);
  color yellow = color(255, 255, 0);

  for (int i = 0; i < 11; i++)
  {
    pushMatrix();
    translate(cubes.get(i).currentPosition.x, cubes.get(i).currentPosition.y, cubes.get(i).currentPosition.z);

    // chanage color every other cube
    if (i % 2 != 0) {
      fill(yellow);
    } else {
      fill(red);
    }

    cubes.get(i).Update(playbackSpeed);
    // size of 10
    box(10);

    popMatrix();
  }

  camera();
  perspective();
}

void mouseDragged(MouseEvent e)
{

  float deltaX = (mouseX - pmouseX) * 0.15f;
  float deltaY = (mouseY - pmouseY) * 0.15f;

  cameraObject.phi += deltaX;
  cameraObject.theta += deltaY;

  cameraPosition = cameraObject.Update(cameraPosition);

  camera();
  perspective();
}

void mouseWheel(MouseEvent e)
{
  float event = e.getCount();
  cameraObject.Zoom(event);

  cameraPosition = cameraObject.Update(cameraPosition);

  camera();
  perspective();
}


// Create and return an animation object
Animation ReadAnimationFromFile(String fileName)
{
  Animation animation = new Animation();
  String line = new String();
  ArrayList<String> fileInfo = new ArrayList<String>();
  int lineIndex = 0;

  // The BufferedReader class will let you read in the file data
  try
  {
    BufferedReader reader = createReader(fileName);
    while ((line = reader.readLine()) != null)
    {
      fileInfo.add(line);
    }
  }
  catch (FileNotFoundException ex)
  {
    println("File not found: " + fileName);
  }
  catch (IOException ex)
  {
    ex.printStackTrace();
  }

  int numKeyFrames = int(fileInfo.get(lineIndex++));          // number of key frames in the animation
  int numDataPoints = int(fileInfo.get(lineIndex++));         // number of data points (vertices) for each frame in the animation


  for (int i = 0; i < numKeyFrames; i++)
  {
    KeyFrame fileKeyFrame = new KeyFrame();
    int numPointsPerFrame = numDataPoints;

    float time = float(fileInfo.get(lineIndex++));           // a time - when does this frame occur

    // save the data points in the keyframe

    while (numPointsPerFrame > 0)
    {
      String[] pieces = split(fileInfo.get(lineIndex++), " ");
      fileKeyFrame.points.add(new PVector(float(pieces[0]), float(pieces[1]), float(pieces[2])));
      numPointsPerFrame--;
    }

    fileKeyFrame.time = time;

    animation.keyFrames.add(fileKeyFrame);
  }

  return animation;
}

void DrawGrid()
{
  for (int x = -gridSize; x <= gridSize; x += gridUnit)
  {
    for (int z = -gridSize; z <= gridSize; z += gridUnit)
    {
      // white lines
      strokeWeight(1);
      stroke(255);

      // lines on X-axis
      pushMatrix();
      translate(x, 0, 0);
      line(0, 0, -z, 0, 0, z);
      popMatrix();

      // lines on Z-axis
      pushMatrix();
      translate(0, 0, z);
      line(-x, 0, 0, x, 0, 0);
      popMatrix();

      strokeWeight(3);

      // RED line
      stroke(255, 0, 0);
      line(-x, 0, 0, x, 0, 0);

      // BLUE line
      stroke(0, 0, 255);
      line(0, 0, -z, 0, 0, z);

      strokeWeight(0);
    }
  }
}
