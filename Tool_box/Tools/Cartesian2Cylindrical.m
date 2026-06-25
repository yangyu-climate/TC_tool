function V = Cartesian2Cylindrical(x,y,var,R,PHI)

for i=1:size(x,1)    
  for j=1:size(x,2)
    if x(i,j)~=0||y(i,j)~=0
      phi(i,j) = get_angle(x(i,j),y(i,j))/180*pi;
      r(i,j)   = sqrt(x(i,j)^2+y(i,j)^2);
      alpha = get_angle_orgN(x(i,j),y(i,j))/180*pi;
    else
      phi(i,j)     = 0;
      r(i,j)       = 0;
    end
  end
end

V = Car2Cly(r,phi,var,R,PHI);

