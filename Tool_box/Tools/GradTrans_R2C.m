function [GV_R,GV_P] = GradTrans_R2C(x,y,r,GV_X,GV_Y)
for k=1:size(GV_X,1)
    R(k,:,:) = r;
end
% Rectangular to Cylindrical
for i=1:size(x,1) 
  for j=1:size(x,2)
    if x(i,j)~=0||y(i,j)~=0
      alpha = get_angle(x(i,j),y(i,j))/180*pi;
      GV_R(:,i,j) = + GV_X(:,i,j)*cos(alpha) + GV_Y(:,i,j)*sin(alpha);
      GV_P(:,i,j) = - GV_X(:,i,j)*sin(alpha) + GV_Y(:,i,j)*cos(alpha);        
    else
      GV_R(:,i,j) = 0;
      GV_P(:,i,j) = 0;       
    end    
  end
end
GV_P = GV_P./R;