function [uN,vN] = VectorTrans_R2C(x,y,u,v)
% Rectangular to Cylindrical
for i=1:size(x,1) 
  for j=1:size(x,2)
    if x(i,j)~=0||y(i,j)~=0
      alpha = get_angle(x(i,j),y(i,j))/180*pi;
      uN(:,i,j) = + u(:,i,j)*cos(alpha) + v(:,i,j)*sin(alpha);
      vN(:,i,j) = - u(:,i,j)*sin(alpha) + v(:,i,j)*cos(alpha);        
    else
      uN(:,i,j) = 0;
      vN(:,i,j) = 0;       
    end    
  end
end