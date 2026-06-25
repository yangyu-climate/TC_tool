function PlotTC_3D_structure(fileN,Fig_dir)

var_nam = 'avo';
lel_nam = 'z';
if isempty(Fig_dir)
Fig_dir = [pwd,'/Fig'];
end
mkdir(Fig_dir)

x_lim   = [-500 500];
y_lim   = [-500 500];
dl_x    = 10;
dl_y    = 10;
if lel_nam=='z'
z_lim   = [0  15000];
dl_z    = 1000;
else
z_lim   = [0  1000];
dl_z    = 50;
end

T   = load_data(fileN,'TIME');
[year_num,month_num,day_num,...
 hour_num,minu_num,seco_num] = date2str(T);
T_name = [year_num,'-',month_num,'-',day_num,' ',...
          hour_num,':',minu_num,':',seco_num];
G_name = [year_num,'-',month_num,'-',day_num,'_',...
          hour_num,'_',minu_num,'_',seco_num];

lon = load_data(fileN,'x');
lat = load_data(fileN,'y');
p   = load_data(fileN,lel_nam);
v   = load_data(fileN,var_nam);

X = min(x_lim):dl_x:max(x_lim);
Y = min(y_lim):dl_y:max(y_lim);
if lel_nam=='z'
z = [0 10 100 200 1000:dl_z:max(z_lim)];
else
z = min(z_lim):dl_z:max(z_lim);
end
[X,Y,Z] = meshgrid(X,Y,z);

for k=1:size(p,1)
    P(:,:,k)  = interp2(lon,lat,squeeze(p(k,:,:)),squeeze(X(:,:,1)),squeeze(Y(:,:,1)));
    VV(:,:,k) = interp2(lon,lat,squeeze(v(k,:,:)),squeeze(X(:,:,1)),squeeze(Y(:,:,1)));
end
for i=1:size(X,1)
    for j=1:size(X,2)
        if ~isnan(nanmean(squeeze(VV(i,j,:))))
            V(i,j,:) = interp1(squeeze(P(i,j,:)),squeeze(VV(i,j,:)),z);
        else
            V(i,j,1:length(z)) = NaN;
        end
    end
end


xslice = [];   
yslice = [];
if lel_nam=='z'
zslice = [0 100 5000 10000 15000];
else
zslice = [100 500 850];  
end
slice(X,Y,Z,V,xslice,yslice,zslice)
shading flat
%alpha(0.5)

hold on
x = [0 0];
y = [0 0];
z = z_lim;
plot3(x,y,z,'-k')
x = x_lim;
y = [0 0];
z = [max(z) max(z)];
plot3(x,y,z,'--k')
x = [0 0];
y = y_lim;
plot3(x,y,z,'--k')
xlim(x_lim)
ylim(y_lim)
zlim(z_lim)

xlabel('X direction (km)')
ylabel('Y direction (km)')
if lel_nam=='z'
zlabel('Hight (m)') 
else
set(gca, 'ZDir','reverse')
zlabel('Pressure (mb)')
end

title(T_name)

c = mycolor('MyColormap.mat',20);
colormap(c)
colorbar
c_lim = [-5,5]*10^(-4);
caxis(c_lim)

picture=[Fig_dir,'/',var_nam,'_level_',lel_nam,'_',G_name,'.jpg'];
set(gcf,'color','white','paperpositionmode','auto');
saveas(gcf,picture);
close
