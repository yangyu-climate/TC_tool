function [LON,LAT]=TC_centroid_lonlat(lon,lat,slp,I_Ini,J_Ini,resolution)

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

LON = (mean_2D(P.*lon)/mean_2D(P.*mask));
LAT = (mean_2D(P.*lat)/mean_2D(P.*mask));

disp(['lon:',num2str(LON),' lat:',num2str(LAT)])
