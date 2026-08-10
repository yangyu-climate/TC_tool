function dvar = cylindrical_phi_derivative(var,dPhi)
%CYLINDRICAL_PHI_DERIVATIVE Periodic derivative along dimension 2 (azimuth).
% Arrays in TC_tool use [vertical, azimuth, radius] ordering.

assert(ndims(var)<=3,'TC_tool:PhiDerivativeShape',...
    'Input must have [vertical, azimuth, radius] dimensions.')
assert(isfinite(dPhi) && dPhi>0,'TC_tool:PhiDerivativeSpacing',...
    'dPhi must be a positive finite scalar.')

nphi = size(var,2);
dvar = NaN(size(var));
for k = 1:size(var,1)
    for j = 1:size(var,3)
        % Force a column vector.  squeeze(var(k,:,j)) is nphi-by-1, so
        % shifting dimension 2 would otherwise be a no-op.
        x = reshape(var(k,:,j),[],1);
        if nphi >= 3
            dx = (circshift(x,-1,1)-circshift(x,1,1))/(2*dPhi);
        elseif nphi == 2
            dx = gradient(x)/dPhi;
        else
            dx = NaN(size(x));
        end
        dvar(k,:,j) = dx.';
    end
end
end
