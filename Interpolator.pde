abstract class Interpolator
{
  Animation animation = new Animation();

  // Where we at in the animation?
  float currentTime;

  // To interpolate, or not to interpolate... that is the question
  boolean snapping = false;


  void SetAnimation(Animation anim)
  {
    animation = anim;
  }

  void SetFrameSnapping(boolean snap)
  {
    snapping = snap;
  }

  void UpdateTime(float time)
  {
    // Check to see if the time is out of bounds (0 / Animation_Duration)
    // If so, adjust by an appropriate amount to loop correctly
    this.currentTime = currentTime + time;
    if (currentTime < 0) {
      this.currentTime = currentTime + animation.GetDuration();
    } else if (currentTime > animation.GetDuration())
    {
      this.currentTime = currentTime - animation.GetDuration();
    }
  }

  // implement in the derived class
  abstract void Update(float time);
}

class ShapeInterpolator extends Interpolator
{
  // The result of the data calculations - either snapping or interpolating
  PShape currentShape = new PShape();

  // Changing mesh colors
  color fillColor;

  PShape GetShape()
  {
    return currentShape;
  }

  void Update(float time)
  {
    // Create a new PShape by interpolating between two existing key frames
    // using linear interpolation

    UpdateTime(time);

    KeyFrame previousFrame = new KeyFrame();
    KeyFrame nextFrame = new KeyFrame();

    // edge case
    if (currentTime < animation.keyFrames.get(0).time)
    {
      nextFrame.points = animation.keyFrames.get(0).points;
      nextFrame.time = animation.keyFrames.get(0).time;

      previousFrame.points = animation.keyFrames.get(animation.keyFrames.size() - 1).points;
      previousFrame.time = 0.0f;
    }
    else
    {
      for (int i = 0; i < animation.keyFrames.size() - 1; i++)
      {
        int j = i + 1;
        if (j >= animation.keyFrames.size())
        {
          j = 0;
          i = animation.keyFrames.size() - 1;
          nextFrame = animation.keyFrames.get(j);
          previousFrame = animation.keyFrames.get(i);
        }

        if ((animation.keyFrames.get(i).time <= currentTime && currentTime < animation.keyFrames.get(j).time) || (animation.keyFrames.get(i).time < currentTime && currentTime <= animation.keyFrames.get(j).time))
        {
          nextFrame = animation.keyFrames.get(j);

          previousFrame = animation.keyFrames.get(i);
        }
      }
    }

    float ratio = ((currentTime - previousFrame.time) / (nextFrame.time - previousFrame.time));
    float x, y, z;
    currentShape = createShape();
    currentShape.beginShape(TRIANGLES);

    for (int i = 0; i < nextFrame.points.size(); i++)
    {
      // if it needs to linear interpolation
      if (snapping == false)
      {
        x = lerp(previousFrame.points.get(i).x, nextFrame.points.get(i).x, ratio);
        y = lerp(previousFrame.points.get(i).y, nextFrame.points.get(i).y, ratio);
        z = lerp(previousFrame.points.get(i).z, nextFrame.points.get(i).z, ratio);
      } else {
        x = nextFrame.points.get(i).x;
        y = nextFrame.points.get(i).y;
        z = nextFrame.points.get(i).z;
      }

      currentShape.vertex(x, y, z);
    }

    currentShape.endShape(CLOSE);
  }
}

class PositionInterpolator extends Interpolator
{
  PVector currentPosition = new PVector();

  void Update(float time)
  {
    UpdateTime(time);

    KeyFrame previousFrame = new KeyFrame();
    KeyFrame nextFrame = new KeyFrame();

    // edge case
    if (currentTime < animation.keyFrames.get(0).time)
    {
      nextFrame.points = animation.keyFrames.get(0).points;
      nextFrame.time = animation.keyFrames.get(0).time;

      previousFrame.points = animation.keyFrames.get(animation.keyFrames.size() - 1).points;
      previousFrame.time = 0.0f;
    }
    
    else
    {
      for (int i = 0; i < animation.keyFrames.size() - 1; i++)
      {
        int j = i + 1;
        if (j >= animation.keyFrames.size())
        {
          j = 0;
          i = animation.keyFrames.size() - 1;
          nextFrame = animation.keyFrames.get(j);
          previousFrame = animation.keyFrames.get(i);
        }

        if ((animation.keyFrames.get(i).time <= currentTime && currentTime < animation.keyFrames.get(j).time) || (animation.keyFrames.get(i).time < currentTime && currentTime <= animation.keyFrames.get(j).time))
        {
          nextFrame = animation.keyFrames.get(j);

          previousFrame = animation.keyFrames.get(i);
        }
      }
    }

    float ratio = (currentTime - previousFrame.time) / (nextFrame.time - previousFrame.time);

    //if it needs to linear interpolation
    if (snapping == false)
    {
      currentPosition.x = lerp(previousFrame.points.get(0).x, nextFrame.points.get(0).x, ratio);
      currentPosition.y = lerp(previousFrame.points.get(0).y, nextFrame.points.get(0).y, ratio);
      currentPosition.z = lerp(previousFrame.points.get(0).z, nextFrame.points.get(0).z, ratio);
    } else
    {
      currentPosition.x = nextFrame.points.get(0).x;
      currentPosition.y = nextFrame.points.get(0).y;
      currentPosition.z = nextFrame.points.get(0).z;
    }

  }
}
