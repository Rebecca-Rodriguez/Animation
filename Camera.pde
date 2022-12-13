class Camera
{
  int radius;
  float phi, theta;
  PVector cameraPosition;
  Camera()
  {
    radius = 232;
    phi = 90;
    theta = 126;
  }

  PVector Update(PVector cameraPosition)
  {
    cameraPosition.x = radius * cos(radians(phi)) * sin(radians(theta));
    cameraPosition.y = radius * cos(radians(theta));
    cameraPosition.z = radius * sin(radians(theta)) * sin(radians(phi));

    return cameraPosition;
  }

  void Zoom (float pos)
  {
    radius = constrain(radius, 10, 300);
    radius += pos;
  }
}
