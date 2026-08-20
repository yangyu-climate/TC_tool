function V = Car2Cly(r,phi,var,X,Y)

[L,M] = size(r);

r   = reshape(r  ,L*M,1);
phi = mod(reshape(phi,L*M,1),2*pi);
var = reshape(var,L*M,1);

% Replicate every valid source point across the periodic seam.  Duplicating
% only exact phi=0 samples leaves a seam for off-grid storm centres.
valid = isfinite(r) & isfinite(phi) & isfinite(var);
if nnz(valid)<3
    % A requested height can lie outside every source column (for example,
    % z=0 below the lowest WRF mass level), or have too few valid points to
    % construct a 2-D interpolation. Preserve the requested output grid with
    % missing values instead of letting griddata return 0-by-0.
    V = NaN(size(X));
    return
end
r = r(valid); phi = phi(valid); var = var(valid);
V = griddata([r;r;r],[phi-2*pi;phi;phi+2*pi],[var;var;var],X,Y);
if isempty(V)
    % griddata also returns empty for degenerate (e.g., collinear) geometry.
    V = NaN(size(X));
end
