function var = dVdR(data,dR)

SD = length(size(data));

if SD==3
    for k=1:size(data,1)
        D = squeeze(data(k,:,:));
        var(k,:,:) = gradient(D)/dR;
    end
elseif SD==2
    D = data;
    var = gradient(D)/dR;
else
    D = data;
    var = gradient(D)/dR;
end

