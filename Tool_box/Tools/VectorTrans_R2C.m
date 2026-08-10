function [uN,vN] = VectorTrans_R2C(x,y,u,v)
%VECTORTRANS_R2C Rotate [level,y,x] Cartesian winds into cylindrical winds.
% atan2 is equivalent to the former scalar get_angle loop, while implicit
% expansion applies the horizontal rotation to every vertical level at once.
alpha = atan2(y,x);
cos_alpha = reshape(cos(alpha),1,size(x,1),size(x,2));
sin_alpha = reshape(sin(alpha),1,size(x,1),size(x,2));
uN = u.*cos_alpha + v.*sin_alpha;
vN = -u.*sin_alpha + v.*cos_alpha;

% The cylindrical direction is undefined at r=0. Preserve the legacy
% convention of returning zero components there.
at_center = (x==0 & y==0);
uN(:,at_center) = 0;
vN(:,at_center) = 0;
