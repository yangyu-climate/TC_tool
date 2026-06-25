function [varM,varP] = azimuth_mean(var,r,Radius,dR)

R      = [0:dR:ceil(Radius/dR)*dR];
dr     = dR/2;
mask   = NaN*ones(size(r));
mask(r<=(Radius+dR)) = 1;
mask(r==0)           = 0;
varM   = zeros(size(var));
L      = length(size(var));

for i=1:length(R)
    mask_r = NaN*ones(size(r));
    mask_c = zeros(size(r));
    loc = find(r>=(R(i)-dr) & r<(R(i)+dr));
    mask_r(loc) = 1;
    mask_c(loc) = 1;
    if L==2
        varM = varM + mask.*mask_c*mean_2D(var.*mask_r);
    elseif L==3
      for k=1:size(var,1)
        varM(k,:,:)= squeeze(varM(k,:,:)) ...
                   + mask.*mask_c*mean_2D(squeeze(var(k,:,:)).*mask_r);
      end 
    end
end

varP = var - varM;