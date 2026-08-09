function [distance_km,x_km,y_km] = tc_great_circle_xy(lat,lon,lat0,lon0)
% Great-circle distance and local east/north components from (lat0,lon0).
R_earth_km = 6371.0;
lat1 = deg2rad(lat0); lat2 = deg2rad(lat);
dlon = deg2rad(mod(lon-lon0+180,360)-180);
dlat = lat2-lat1;
a = sin(dlat/2).^2 + cos(lat1).*cos(lat2).*sin(dlon/2).^2;
angle = 2*atan2(sqrt(a),sqrt(max(0,1-a)));
distance_km = R_earth_km*angle;
bearing = atan2(sin(dlon).*cos(lat2),...
    cos(lat1).*sin(lat2)-sin(lat1).*cos(lat2).*cos(dlon));
x_km = distance_km.*sin(bearing);
y_km = distance_km.*cos(bearing);
x_km(distance_km==0)=0; y_km(distance_km==0)=0;
end
