function var = mean_2D(var)
[L,M] = size(var);
var   = reshape(var,L*M,1);
var   = nanmean(var);