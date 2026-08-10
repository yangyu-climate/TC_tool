function V = Car2Cly(r,phi,var,X,Y)

[L,M] = size(r);

r   = reshape(r  ,L*M,1);
phi = mod(reshape(phi,L*M,1),2*pi);
var = reshape(var,L*M,1);

% Replicate every valid source point across the periodic seam.  Duplicating
% only exact phi=0 samples leaves a seam for off-grid storm centres.
valid = isfinite(r) & isfinite(phi) & isfinite(var);
r = r(valid); phi = phi(valid); var = var(valid);
V = griddata([r;r;r],[phi-2*pi;phi;phi+2*pi],[var;var;var],X,Y);
