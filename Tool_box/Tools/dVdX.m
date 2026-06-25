function var = dVdX(v,x)

SD = length(size(v));

if SD==3
    for k=1:size(v,1)
        D = squeeze(v(k,:,:));
        [Fx,Fy]    = gradient(D);
        [Dx,Dy]    = gradient(x);
        var(k,:,:) = Fx./Dx;
    end
elseif SD==2
    D = v;
    [Fx,Fy]    = gradient(D);
    [Dx,Dy]    = gradient(x);
    var = Fx./Dx;
else
    D = v;
    var = gradient(D)./gradient(x);
end

