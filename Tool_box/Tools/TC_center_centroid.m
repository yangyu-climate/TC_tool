function [It,Jt]=TC_center_centroid(lon,lat,slp,I_Ini,J_Ini,resolution)

R     = 111.2;
R_lim = 100;
max_iter = 100;

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

It = round(mean_2D(P.*I_M)/mean_2D(P.*mask));
Jt = round(mean_2D(P.*J_M)/mean_2D(P.*mask));

visited = false(size(slp));
converged = false;
for iter = 1:max_iter
    if ~isfinite(It) || ~isfinite(Jt) || It<1 || It>size(slp,1) || Jt<1 || Jt>size(slp,2)
        warning('TC_tool:CentroidInvalid','TC pressure-deficit centroid became invalid; retaining the last valid centre.')
        It = Ig;
        Jt = Jg;
        break
    end
    if It==Ig && Jt==Jg
        converged = true;
        break
    end
    if visited(It,Jt)
        warning('TC_tool:CentroidCycle','TC pressure-deficit centroid entered a cycle; retaining the last valid centre.')
        It = Ig;
        Jt = Jg;
        break
    end
    visited(Ig,Jg) = true;
    disp(['Ig:',num2str(Ig),' Jg:',num2str(Jg),', Ic:',num2str(It),' Jc:',num2str(Jt)])

    Ig = It;
    Jg = Jt;
    
    [dist,~,~] = tc_great_circle_xy(lat,lon,lat(Ig,Jg),lon(Ig,Jg));
    mask = NaN*ones(size(dist));
    mask(dist<=R_lim)=1;

    SLP   = mask.*slp;
    P_lim = nanmax(nanmax(SLP));

    P = P_lim*ones(size(SLP));
    P = P-SLP;

    It = round(mean_2D(P.*I_M)/mean_2D(P.*mask));
    Jt = round(mean_2D(P.*J_M)/mean_2D(P.*mask));
end

if ~converged && iter==max_iter
    warning('TC_tool:CentroidMaxIter','TC pressure-deficit centroid did not converge within %d iterations; retaining the last valid centre.',max_iter)
    It = Ig;
    Jt = Jg;
end

disp(['If:',num2str(It),' Jf:',num2str(Jt)])
