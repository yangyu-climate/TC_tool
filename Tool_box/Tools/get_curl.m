function [Fx,Fy,Fz]=get_curl(x,y,z,u,v,w)
for k=1:size(z,1)
    X(k,:,:) = x;
    Y(k,:,:) = y;
end
Z  = z;
FX = u;
FY = v;
FZ = w;

[X_y,X_z,X_x] = gradient(X);
[Y_y,Y_z,Y_x] = gradient(Y);
[Z_y,Z_z,Z_x] = gradient(Z);
[FX_y,FX_z,FX_x] = gradient(FX);
[FY_y,FY_z,FY_x] = gradient(FY);
[FZ_y,FZ_z,FZ_x] = gradient(FZ);

Fz = FY_x./X_x - FX_y./Y_y;
Fy = FX_z./Z_z - FZ_x./X_x;
Fx = FZ_y./Y_y - FY_z./Z_z;