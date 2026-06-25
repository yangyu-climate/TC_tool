function var = sum_2D(var)
[L,M] = size(var);
var   = reshape(var,L*M,1);
var   = nansum(var);