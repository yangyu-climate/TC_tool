function V = Car2Cly(r,phi,var,X,Y)

[L,M] = size(r);

r   = reshape(r  ,L*M,1);
phi = reshape(phi,L*M,1);
var = reshape(var,L*M,1);

loc= find(phi==0);
r  = [r;r(loc)];
phi= [phi;phi(loc)+2*pi];
var= [var;var(loc)];
V= griddata(r,phi,var,X,Y);
