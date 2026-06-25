function [tc_lon,tc_lat,tc_p,tc_w,tw_lon,tw_lat] = TC_center_WCL(lon,lat,slp,swd,TLM,TLN)

[L,M] = size(slp);
TLM_H = ceil(TLM/2);
TLM_L = TLM_H-1;
TLN_H = ceil(TLN/2);
TLN_L = TLN_H-1;

num = 0;
for i = TLM_H:L-TLM_L
    for j=TLM_H:M-TLM_L
        var = slp(i-TLM_L:i+TLM_L,j-TLM_L:j+TLM_L);
        if slp(i,j) == nanmin(nanmin(var))
            num = num+1;
            t_i(num) = i;
            t_j(num) = j;
        end
    end
end

count = 0;
for NUM = 1:num
    I = t_i(NUM);
    J = t_j(NUM);    
    count = count+1;
    tc_lon(count) = lon(I,J);
    tc_lat(count) = lat(I,J);
    tc_p(count)   = slp(I,J);
    tc_w(count)   = nanmax(nanmax(swd(I-TLN_L:I+TLN_L,J-TLN_L:J+TLN_L)));

    ts_swd        = swd(I-TLN_L:I+TLN_L,J-TLN_L:J+TLN_L);
    ts_lon        = lon(I-TLN_L:I+TLN_L,J-TLN_L:J+TLN_L);
    ts_lat        = lat(I-TLN_L:I+TLN_L,J-TLN_L:J+TLN_L);
    ts_loc        = find(ts_swd==nanmin(nanmin(ts_swd)));
    tw_lon(count) = mean(ts_lon(ts_loc));
    tw_lat(count) = mean(ts_lat(ts_loc));
end

if count==0
    tc_lon = NaN;
    tc_lat = NaN;
    tc_p   = NaN;
    tc_w   = NaN;
    tw_lon = NaN;
    tw_lat = NaN;
end



