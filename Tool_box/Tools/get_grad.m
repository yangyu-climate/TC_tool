function [Fx,Fy,Fz]=get_grad(x,y,z,var)

Z = z;

for k=1:size(z,1)
    X(k,:,:) = x;
    Y(k,:,:) = y;
end

[X_y,X_z,X_x] = gradient(X);
[Y_y,Y_z,Y_x] = gradient(Y);
[Z_y,Z_z,Z_x] = gradient(Z);
[F_y,F_z,F_x] = gradient(var);

Fx = F_x./X_x;
Fy = F_y./Y_y;
Fz = F_z./Z_z;