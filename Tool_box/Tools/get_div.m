function F =get_div(x,y,z,U,V,W)

Z = z;

for k=1:size(z,1)
    X(k,:,:) = x;
    Y(k,:,:) = y;
end

[X_y,X_z,X_x] = gradient(X);
[Y_y,Y_z,Y_x] = gradient(Y);
[Z_y,Z_z,Z_x] = gradient(Z);
[U_y,U_z,U_x] = gradient(U);
[V_y,V_z,V_x] = gradient(V);
[W_y,W_z,W_x] = gradient(W);

Fx = U_x./X_x;
Fy = V_y./Y_y;
Fz = W_z./Z_z;
F  = Fx + Fy + Fz;