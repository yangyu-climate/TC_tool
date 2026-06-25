function [data_out] = running_mean_1D(data_in,point_num)
    
loc_shf = floor(point_num/2);
for i = 1:length(data_in)
    loc_min = i-loc_shf;
    loc_max = i+loc_shf;
    if loc_min<1
        loc_min=1;
    end
    if loc_max>length(data_in)
        loc_max=length(data_in);
    end
    data_out(i) = nanmean(data_in(loc_min:loc_max));    
end
