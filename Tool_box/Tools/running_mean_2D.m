function var = running_mean_2D(data_in,smooth_num)    

var        = data_in;
var_2d     = squeeze(var);
var_new    = nan*ones(size(var));
[L,M]      = size(var_2d);
if mod(smooth_num,2)==0
  smooth_num = smooth_num+1;
end
N  = floor(smooth_num/2);
for i= 1+N:L-N
  for j = 1+N:M-N
    var_new(i,j) = mean_2D(var_2d(i-N:i+N,j-N:j+N));
  end
end
var = var_new;
