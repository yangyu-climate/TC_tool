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

[dist,~,~] = tc_great_circle_xy(lat,lon,lat(Ig,Jg),lon(Ig,Jg));
mask = NaN*ones(size(dist));
mask(dist<=R_lim)=1;

SLP   = mask.*slp;
P_lim = nanmax(nanmax(SLP));

P = P_lim*ones(size(SLP));
P = P-SLP;

weight = P.*mask;
% Average longitude on the unit circle so a pressure deficit straddling the
% date line is centred near 180 degrees rather than near 0 degrees.
lon_rad = deg2rad(lon);
LON = rad2deg(atan2(mean_2D(weight.*sin(lon_rad)),...
                    mean_2D(weight.*cos(lon_rad))));
% Preserve the longitude convention of the source grid (for example 0--360).
LON = lon(Ig,Jg) + mod(LON-lon(Ig,Jg)+180,360)-180;
LAT = mean_2D(weight.*lat)/mean_2D(weight);

disp(['lon:',num2str(LON),' lat:',num2str(LAT)])
