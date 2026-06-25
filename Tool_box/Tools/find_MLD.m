function depth = find_MLD(T,D,threshold)
    D_C =     (D(1:end-1)+D(2:end))/2;
    D_L = abs((D(1:end-1)-D(2:end)));
    D_V = abs((T(1:end-1)-T(2:end)));
    DIF = D_V./D_L;
    
    loc = find(DIF>=threshold);
    
    if isempty(loc)
        depth = NaN;
    else
        Depth = D_C(loc);
        if nanmean(Depth)<0
            depth = nanmax(Depth);
        else
            depth = nanmin(Depth);
        end
    end
