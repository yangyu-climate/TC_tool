function varS = azimuth_slice(var,r,Radius,dR)

R      = [0:dR:ceil(Radius/dR)*dR];
dr     = dR/2;
L      = length(size(var));

for i=1:length(R)
    mask_r = NaN*ones(size(r));
    loc = find(r>=(R(i)-dr) & r<(R(i)+dr));
    mask_r(loc) = 1;
    if L==2
        varS(i) = mean_2D(var.*mask_r);
    elseif L==3
      for k=1:size(var,1)
        varS(k,i)= mean_2D(squeeze(var(k,:,:)).*mask_r);
      end 
    end
end