function var = dVdY(v,y)

SD = length(size(v));

if SD==3
    for k=1:size(v,1)
        D = squeeze(v(k,:,:));
        [Fx,Fy]    = gradient(D);
        [Dx,Dy]    = gradient(y);
        var(k,:,:) = Fy./Dy;
    end
elseif SD==2
    D = v;
    [Fx,Fy]    = gradient(D);
    [Dx,Dy]    = gradient(y);
    var = Fy./Dy;
else
    D = v;
    var = gradient(D)./gradient(y);
end

