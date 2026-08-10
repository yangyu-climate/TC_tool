function [eta_r,eta_phi,eta_z] = tc_absolute_vorticity_cyl(u,v,w,avo,r,z,dr,dPhi,lat,PHI,Omega)
%TC_ABSOLUTE_VORTICITY_CYL Full absolute-vorticity vector in local cylindrical ENU coordinates.
% x/east and y/north define phi=0 as east and positive phi counter-clockwise.
% WRF avo supplies eta_z; the horizontal planetary components are derived
% from the local latitude and Earth's rotation rate.

assert(isequal(size(u),size(v),size(w),size(avo),size(r),size(z)),...
    'TC_tool:VorticityShape','Velocity, vertical absolute vorticity, r, and z must have identical dimensions.')
assert(isequal(size(lat),[size(u,2),size(u,3)]),...
    'TC_tool:LatitudeShape','lat must have [azimuth,radius] dimensions.')
assert(numel(PHI)==size(u,2),'TC_tool:PhiShape','PHI must match the azimuth dimension.')
assert(isfinite(Omega) && Omega>0,'TC_tool:RotationRate','Omega must be a positive finite rotation rate.')

zeta_r_rel = 1./r.*cylindrical_phi_derivative(w,dPhi) - dVdZ(v,z);
zeta_phi_rel = dVdZ(u,z) - dVdR(w,dr);

horizontal_planetary = 2*Omega*cosd(lat);
sin_phi = reshape(sin(PHI(:)),1,[],1);
cos_phi = reshape(cos(PHI(:)),1,[],1);
horizontal_planetary = reshape(horizontal_planetary,1,size(lat,1),size(lat,2));

eta_r = zeta_r_rel + horizontal_planetary.*sin_phi;
eta_phi = zeta_phi_rel + horizontal_planetary.*cos_phi;
% avo is WRF's vertical absolute vorticity: zeta_z + 2*Omega*sin(latitude).
eta_z = avo;
end
