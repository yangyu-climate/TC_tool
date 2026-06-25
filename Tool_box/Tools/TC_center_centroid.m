function [It,Jt]=TC_center_centroid(lon,lat,slp,I_Ini,J_Ini,resolution)

R     = 111.2;
R_lim = 100;

Ig   = I_Ini;
Jg   = J_Ini;

for i =1:size(slp,1)
    for j=1:size(slp,2)
        I_M(i,j) = i;
        J_M(i,j) = j;
    end
end

%dist = R.*sqrt((lon-lon(Ig,Jg)).^2+(lat-lat(Ig,Jg)).^2);
dist = resolution.*sqrt((I_M-Ig).^2+(J_M-Jg).^2);
mask = NaN*ones(size(dist));
mask(dist<=R_lim)=1;

SLP   = mask.*slp;
P_lim = nanmax(nanmax(SLP));

P = P_lim*ones(size(SLP));
P = P-SLP;

It = round(mean_2D(P.*I_M)/mean_2D(P.*mask));
Jt = round(mean_2D(P.*J_M)/mean_2D(P.*mask));

while (It~=Ig)||(Jt~=Jg)
    disp(['Ig:',num2str(Ig),' Jg:',num2str(Jg),', Ic:',num2str(It),' Jc:',num2str(Jt)])

    Ig = It;
    Jg = Jt;
    
%    dist = R.*sqrt((lon-lon(Ig,Jg)).^2+(lat-lat(Ig,Jg)).^2);
    dist = resolution.*sqrt((I_M-Ig).^2+(J_M-Jg).^2);
    mask = NaN*ones(size(dist));
    mask(dist<=R_lim)=1;

    SLP   = mask.*slp;
    P_lim = nanmax(nanmax(SLP));

    P = P_lim*ones(size(SLP));
    P = P-SLP;

    It = round(mean_2D(P.*I_M)/mean_2D(P.*mask));
    Jt = round(mean_2D(P.*J_M)/mean_2D(P.*mask));
end

disp(['If:',num2str(It),' Jf:',num2str(Jt)])
