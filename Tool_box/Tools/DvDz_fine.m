function DvDz = DvDz_fine(v,z,fine_ratio)

fineN = fine_ratio;
M     = size(z,2);
L     = size(z,3);
Mm    = ceil(M/2);
Lm    = ceil(L/2);
z_lev = squeeze(z(:,Mm,Lm));
z_dl  = z_lev(2:end)-z_lev(1:end-1);

z_new = [];
for k=1:size(z,1)
    if k==1
        z_new = z_lev(k);
    else
        dl    = z_dl(k-1)/fineN;
        z_new = [z_new,z_lev(k-1)+dl:dl:z_lev(k)];
    end
end

for i = 1:size(z,2)
    for j = 1:size(z,3)
        Z    = z_new;
        V    = interp1(squeeze(z(:,i,j)),squeeze(v(:,i,j)),z_new);
        DvDz(:,i,j) = gradient(V)./gradient(Z);
    end
end


