function A = get_angle_orgN(x,y)

  angle  = get_angle(x,y);
  A      = angle-90;
  A(A>0) = A(A>0)-360;
  A      = -A;
