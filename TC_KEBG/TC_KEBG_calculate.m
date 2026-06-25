clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_KEBG_config;

Data_dir   = [pwd,'/Result/azimuthally'];
Head_nam   = cfg.Save_nam;
Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/KEBG'];
mkdir(Save_dir)

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Tendency_frq = cfg.calc.Tendency_frq;
Max_WN     = cfg.calc.Max_WN;
Use_thetaE = cfg.calc.Use_thetaE;
Budget_Radius = cfg.calc.Budget_Radius;

T_beg      = datenum(Time_beg);
T_end      = datenum(Time_end);
T_frq      = Time_frq/60/24;
del_T      = Tendency_frq/60/24;
D_to_S     = 24*60*60;
g          = 9.81;
min_N2     = cfg.calc.min_N2;

for T = T_beg:T_frq:T_end
    TIME                            = T;
    [year,month,day,hour,minu,seco] = date2num(TIME);
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num]    = date2str(TIME);
    T_name    = [year_num,'-',month_num,'-',day_num,'_',...
                 hour_num,':',minu_num,':',seco_num];
    file_name = [Head_nam,'*',T_name,'.mat'];
    filename  = dir([Data_dir,'/',file_name]);
    if ~isempty(filename)
        disp([' '])
        disp(['Date: ',T_name])
        file_name = filename.name(1:end-4);
        file_name = [Data_dir,'/',file_name];
        file_TN   = file_name;

        R          = load_data([file_TN,'.mat'],'R');
        PHI        = load_data([file_TN,'.mat'],'PHI');
        dR         = load_data([file_TN,'.mat'],'dR');
        dPhi       = load_data([file_TN,'.mat'],'dPhi');
        dr         = load_data([file_TN,'.mat'],'dr');
        r          = load_data([file_TN,'.mat'],'r');
        z          = load_data([file_TN,'.mat'],'z');
        P          = load_data([file_TN,'.mat'],'P');
        u          = load_data([file_TN,'.mat'],'u');
        v          = load_data([file_TN,'.mat'],'v');
        w          = load_data([file_TN,'.mat'],'w');
        rho        = load_data([file_TN,'.mat'],'rho');
        theta      = load_data([file_TN,'.mat'],'theta');
        thetaE     = load_data([file_TN,'.mat'],'thetaE');
        H_DIABATIC = load_data([file_TN,'.mat'],'H_DIABATIC');
        um         = load_data([file_TN,'.mat'],'um');
        vm         = load_data([file_TN,'.mat'],'vm');
        wm         = load_data([file_TN,'.mat'],'wm');
        lon_TC     = load_data([file_TN,'.mat'],'lon_TC');
        lat_TC     = load_data([file_TN,'.mat'],'lat_TC');
        slp_TC     = load_data([file_TN,'.mat'],'slp_TC');
        swd_TC     = load_data([file_TN,'.mat'],'swd_TC');

        if Use_thetaE
            therm = thetaE;
            therm_name = 'thetaE';
        else
            therm = theta;
            therm_name = 'theta';
        end

        max_wn_allowed = floor(length(PHI)/2);
        WN = 0:min(Max_WN,max_wn_allowed);

        disp(['Calculating... : spectral KE and APE terms'])
        r(r==0) = NaN;
        z2      = squeeze(nanmean(z,2));
        r2      = squeeze(nanmean(r,2));
        P2      = squeeze(nanmean(P,2));
        rho2    = squeeze(nanmean(rho,2));
        um2     = squeeze(nanmean(um,2));
        vm2     = squeeze(nanmean(vm,2));
        wm2     = squeeze(nanmean(wm,2));
        th2     = squeeze(nanmean(therm,2));

        theta_ref = level_weighted_mean_2d(th2,r2,rho2);
        H_ref     = level_weighted_mean_3d(H_DIABATIC,r,rho);
        z_ref     = level_weighted_mean_2d(z2,r2,rho2);
        dthdz_ref = gradient(theta_ref)./gradient(z_ref);
        N2_ref    = g./theta_ref.*dthdz_ref;
        N2_ref(find(N2_ref<min_N2|isnan(N2_ref))) = min_N2;
        ape_coef_lev = g.^2./(N2_ref.*theta_ref.^2);
        ape_coef = repmat(ape_coef_lev(:),1,length(R));

        therm_anom = therm;
        heat_anom  = H_DIABATIC;
        for k=1:size(therm,1)
            therm_anom(k,:,:) = squeeze(therm(k,:,:)) - theta_ref(k);
            heat_anom(k,:,:)  = squeeze(H_DIABATIC(k,:,:)) - H_ref(k);
        end

        [KE,APE,APE_gen,APE_to_KE,BT_0_to_n] = ...
            local_energy_terms(u,v,w,therm_anom,heat_anom,...
                               um2,vm2,z2,r2,ape_coef,WN,dr,g,theta_ref);

        disp(['Calculating... : KE and APE tendency'])
        h = del_T*D_to_S;
        [KE_0 ,APE_0 ,has_0 ] = load_ebg_energy_state(file_name,T_name,TIME, 0,del_T,R,PHI,WN,Use_thetaE,min_N2);
        [KE_B ,APE_B ,has_B ] = load_ebg_energy_state(file_name,T_name,TIME,-1,del_T,R,PHI,WN,Use_thetaE,min_N2);
        [KE_F ,APE_F ,has_F ] = load_ebg_energy_state(file_name,T_name,TIME, 1,del_T,R,PHI,WN,Use_thetaE,min_N2);
        [KE_B2,APE_B2,has_B2] = load_ebg_energy_state(file_name,T_name,TIME,-2,del_T,R,PHI,WN,Use_thetaE,min_N2);
        [KE_F2,APE_F2,has_F2] = load_ebg_energy_state(file_name,T_name,TIME, 2,del_T,R,PHI,WN,Use_thetaE,min_N2);

        if has_B2 && has_B && has_F && has_F2
            KE_tendency  = (-KE_F2  + 8*KE_F  - 8*KE_B  + KE_B2)/(12*h);
            APE_tendency = (-APE_F2 + 8*APE_F - 8*APE_B + APE_B2)/(12*h);
            Tendency_scheme = 'fourth_order_centered';
        elseif has_B && has_F
            KE_tendency  = (KE_F-KE_B)/(2*h);
            APE_tendency = (APE_F-APE_B)/(2*h);
            Tendency_scheme = 'second_order_centered';
        elseif has_0 && has_F && has_F2
            KE_tendency  = (-3*KE_0  + 4*KE_F  - KE_F2)/(2*h);
            APE_tendency = (-3*APE_0 + 4*APE_F - APE_F2)/(2*h);
            Tendency_scheme = 'second_order_forward';
        elseif has_0 && has_B && has_B2
            KE_tendency  = (3*KE_0  - 4*KE_B  + KE_B2)/(2*h);
            APE_tendency = (3*APE_0 - 4*APE_B + APE_B2)/(2*h);
            Tendency_scheme = 'second_order_backward';
        elseif has_0 && has_F
            KE_tendency  = (KE_F-KE_0)/h;
            APE_tendency = (APE_F-APE_0)/h;
            Tendency_scheme = 'first_order_forward';
        elseif has_0 && has_B
            KE_tendency  = (KE_0-KE_B)/h;
            APE_tendency = (APE_0-APE_B)/h;
            Tendency_scheme = 'first_order_backward';
        else
            disp(['Skip tendency calculation: no neighboring file for ',T_name])
            continue
        end
        dt = h;

        KE_residual  = KE_tendency  - BT_0_to_n - APE_to_KE;
        APE_residual = APE_tendency - APE_gen    + APE_to_KE;

        mass_weight = mass_weight_2d(r2,z2,rho2,dr,Budget_Radius);
        KE_int          = mass_integral_by_wn(KE,mass_weight);
        APE_int         = mass_integral_by_wn(APE,mass_weight);
        APE_gen_int     = mass_integral_by_wn(APE_gen,mass_weight);
        APE_to_KE_int   = mass_integral_by_wn(APE_to_KE,mass_weight);
        BT_0_to_n_int   = mass_integral_by_wn(BT_0_to_n,mass_weight);
        KE_tendency_int = mass_integral_by_wn(KE_tendency,mass_weight);
        APE_tendency_int= mass_integral_by_wn(APE_tendency,mass_weight);
        KE_residual_int = mass_integral_by_wn(KE_residual,mass_weight);
        APE_residual_int= mass_integral_by_wn(APE_residual,mass_weight);

        group_name = {'WN0','WN1_2','WN3_plus','WN_all'};
        group_index = {find(WN==0),find(WN>=1&WN<=2),find(WN>=3),find(WN>=0)};
        KE_group          = group_sum(KE_int,group_index);
        APE_group         = group_sum(APE_int,group_index);
        APE_gen_group     = group_sum(APE_gen_int,group_index);
        APE_to_KE_group   = group_sum(APE_to_KE_int,group_index);
        BT_0_to_n_group   = group_sum(BT_0_to_n_int,group_index);
        KE_tendency_group = group_sum(KE_tendency_int,group_index);
        APE_tendency_group= group_sum(APE_tendency_int,group_index);
        KE_residual_group = group_sum(KE_residual_int,group_index);
        APE_residual_group= group_sum(APE_residual_int,group_index);

        z      = z2;
        r      = r2;
        P      = P2;
        u_mean = um2;
        v_mean = vm2;
        w_mean = wm2;

        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
            'R','PHI','dR','dPhi','dr','dt','WN','Max_WN','Budget_Radius',...
            'Tendency_scheme','therm_name','Use_thetaE',...
            'TIME','z','r','P','u_mean','v_mean','w_mean','theta_ref','N2_ref','ape_coef',...
            'KE','APE','APE_gen','APE_to_KE','BT_0_to_n',...
            'KE_tendency','APE_tendency','KE_residual','APE_residual',...
            'mass_weight','KE_int','APE_int','APE_gen_int','APE_to_KE_int','BT_0_to_n_int',...
            'KE_tendency_int','APE_tendency_int','KE_residual_int','APE_residual_int',...
            'group_name','group_index','KE_group','APE_group','APE_gen_group','APE_to_KE_group',...
            'BT_0_to_n_group','KE_tendency_group','APE_tendency_group',...
            'KE_residual_group','APE_residual_group',...
            'lon_TC','lat_TC','slp_TC','swd_TC')

        clear R PHI dR dPhi dr dt WN Tendency_scheme
        clear TIME z r P u v w rho theta thetaE therm H_DIABATIC
        clear KE APE APE_gen APE_to_KE BT_0_to_n
        clear KE_tendency APE_tendency KE_residual APE_residual
        clear mass_weight KE_int APE_int APE_gen_int APE_to_KE_int BT_0_to_n_int
        clear KE_tendency_int APE_tendency_int KE_residual_int APE_residual_int
        clear group_name group_index KE_group APE_group APE_gen_group APE_to_KE_group
        clear BT_0_to_n_group KE_tendency_group APE_tendency_group KE_residual_group APE_residual_group
        clear lon_TC lat_TC slp_TC swd_TC
    end
end

function [KE,APE,APE_gen,APE_to_KE,BT_0_to_n] = local_energy_terms(u,v,w,therm_anom,heat_anom,um,vm,z,r,ape_coef,WN,dr,g,theta_ref)

nz = size(u,1);
nr = size(u,3);
nw = length(WN);
KE          = NaN(nz,nr,nw);
APE         = NaN(nz,nr,nw);
APE_gen     = NaN(nz,nr,nw);
APE_to_KE   = NaN(nz,nr,nw);
BT_0_to_n   = NaN(nz,nr,nw);

dumdr = d_dr_2d(um,dr);
dvmdr = d_dr_2d(vm,dr);
dumdz = d_dz_2d(um,z);
dvmdz = d_dz_2d(vm,z);

for nloc=1:nw
    n = WN(nloc);
    uu = spectral_cov(u,u,n);
    vv = spectral_cov(v,v,n);
    ww = spectral_cov(w,w,n);
    uv = spectral_cov(u,v,n);
    wu = spectral_cov(w,u,n);
    wv = spectral_cov(w,v,n);
    wt = spectral_cov(w,therm_anom,n);
    ht = spectral_cov(heat_anom,therm_anom,n);
    tt = spectral_cov(therm_anom,therm_anom,n);

    KE(:,:,nloc)        = 0.5*(uu + vv + ww);
    APE(:,:,nloc)       = 0.5*ape_coef.*tt;
    APE_gen(:,:,nloc)   = ape_coef.*ht;
    APE_to_KE(:,:,nloc) = repmat(g./theta_ref(:),1,nr).*wt;
    if n==0
        BT_0_to_n(:,:,nloc) = zeros(nz,nr);
    else
        BT_0_to_n(:,:,nloc) = -uu.*dumdr - uv.*(dvmdr - vm./r) - wu.*dumdz - wv.*dvmdz;
    end
end
end

function c = spectral_cov(a,b,n)

a = fill_nan_phi(a);
b = fill_nan_phi(b);
nphi = size(a,2);
A = fft(a,[],2)/nphi;
B = fft(b,[],2)/nphi;
if n==0
    c = squeeze(real(A(:,1,:).*conj(B(:,1,:))));
elseif n==nphi/2 && mod(nphi,2)==0
    c = squeeze(real(A(:,n+1,:).*conj(B(:,n+1,:))));
else
    c = squeeze(2*real(A(:,n+1,:).*conj(B(:,n+1,:))));
end
end

function a = fill_nan_phi(a)

for k=1:size(a,1)
    for j=1:size(a,3)
        x = squeeze(a(k,:,j));
        loc = find(isnan(x));
        if ~isempty(loc)
            xmean = nanmean(x);
            if ~isnan(xmean)
                x(loc) = xmean;
                a(k,:,j) = x;
            end
        end
    end
end
end

function val = level_weighted_mean_2d(a,r,rho)

val = NaN(size(a,1),1);
for k=1:size(a,1)
    A = squeeze(a(k,:));
    W = squeeze(rho(k,:)).*squeeze(r(k,:));
    W(find(isnan(A)|isnan(W)|isinf(W)|W<=0)) = NaN;
    val(k) = nansum(A.*W)./nansum(W);
end
end

function val = level_weighted_mean_3d(a,r,rho)

val = NaN(size(a,1),1);
for k=1:size(a,1)
    A = squeeze(a(k,:,:));
    W = squeeze(rho(k,:,:)).*squeeze(r(k,:,:));
    W(find(isnan(A)|isnan(W)|isinf(W)|W<=0)) = NaN;
    val(k) = nansum(A(:).*W(:))./nansum(W(:));
end
end

function dzv = d_dz_2d(v,z)

dzv = NaN(size(v));
for j=1:size(v,2)
    Z = squeeze(z(:,j));
    V = squeeze(v(:,j));
    dzv(:,j) = gradient(V)./gradient(Z);
end
end

function drv = d_dr_2d(v,dr)

drv = NaN(size(v));
for k=1:size(v,1)
    drv(k,:) = gradient(squeeze(v(k,:)))./dr;
end
end

function weight = mass_weight_2d(r,z,rho,dr,Budget_Radius)

radius_limit = Budget_Radius*1000;
dz = layer_thickness_2d(z);
area = annulus_area_1d(r,dr,radius_limit);
weight = rho.*repmat(area(:)',size(rho,1),1).*dz;
weight(find(isnan(weight)|isinf(weight)|weight<=0)) = NaN;
end

function dz = layer_thickness_2d(z)

dz = NaN(size(z));
for j=1:size(z,2)
    Z = squeeze(z(:,j));
    valid = find(~isnan(Z));
    if length(valid)==1
        dz(valid,j) = NaN;
    elseif length(valid)>=2
        Zi = Z(valid);
        edge = NaN(length(Zi)+1,1);
        edge(2:end-1) = 0.5*(Zi(1:end-1)+Zi(2:end));
        edge(1) = Zi(1) - 0.5*(Zi(2)-Zi(1));
        edge(end) = Zi(end) + 0.5*(Zi(end)-Zi(end-1));
        dzi = diff(edge);
        dz(valid,j) = dzi;
    end
end
end

function area = annulus_area_1d(r,dr,radius_limit)

R = squeeze(nanmean(r,1));
area = NaN(size(R));
for j=1:length(R)
    if isnan(R(j)) || R(j)>radius_limit
        continue
    end
    r_in  = max(0,R(j)-0.5*dr);
    r_out = min(radius_limit,R(j)+0.5*dr);
    if r_out>r_in
        area(j) = pi*(r_out.^2-r_in.^2);
    end
end
end

function out = mass_integral_by_wn(term,weight)

out = NaN(1,size(term,3));
for n=1:size(term,3)
    tmp = squeeze(term(:,:,n)).*weight;
    out(n) = nansum(tmp(:))./nansum(weight(:));
end
end

function out = group_sum(in,group_index)

out = NaN(1,length(group_index));
for g=1:length(group_index)
    idx = group_index{g};
    if isempty(idx)
        out(g) = NaN;
    else
        out(g) = nansum(in(idx));
    end
end
end

function [KE,APE,has_file] = load_ebg_energy_state(file_name,T_name,TIME,offset,del_T,R,PHI,WN,Use_thetaE,min_N2)

g = 9.81;
if offset==0
    file_t = file_name;
else
    [year_num,month_num,day_num,hour_num,minu_num,seco_num] = date2str(TIME+offset*del_T);
    name_t = [year_num,'-',month_num,'-',day_num,'_',hour_num,':',minu_num,':',seco_num];
    file_t = [file_name(1:end-length(T_name)),name_t];
end

has_file = ~isempty(dir([file_t,'.mat']));
if ~has_file
    KE  = [];
    APE = [];
    return
end

R_t        = load_data([file_t,'.mat'],'R');
PHI_t      = load_data([file_t,'.mat'],'PHI');
u          = load_data([file_t,'.mat'],'u');
v          = load_data([file_t,'.mat'],'v');
w          = load_data([file_t,'.mat'],'w');
z          = load_data([file_t,'.mat'],'z');
rho        = load_data([file_t,'.mat'],'rho');
r          = load_data([file_t,'.mat'],'r');
theta      = load_data([file_t,'.mat'],'theta');
thetaE     = load_data([file_t,'.mat'],'thetaE');

if (nansum(abs(R_t-R))+nansum(abs(PHI_t-PHI)))>0
    [Rx_t,PHIx_t] = meshgrid(R_t,PHI_t);
    [Rx,PHIx]     = meshgrid(R,PHI);
    u_i      = NaN(size(u,1),length(PHI),length(R));
    v_i      = NaN(size(v,1),length(PHI),length(R));
    w_i      = NaN(size(w,1),length(PHI),length(R));
    z_i      = NaN(size(z,1),length(PHI),length(R));
    rho_i    = NaN(size(rho,1),length(PHI),length(R));
    theta_i  = NaN(size(theta,1),length(PHI),length(R));
    thetaE_i = NaN(size(thetaE,1),length(PHI),length(R));
    for k = 1:size(u,1)
        u_i(k,:,:)      = griddata(Rx_t,PHIx_t,squeeze(u(k,:,:)),Rx,PHIx);
        v_i(k,:,:)      = griddata(Rx_t,PHIx_t,squeeze(v(k,:,:)),Rx,PHIx);
        w_i(k,:,:)      = griddata(Rx_t,PHIx_t,squeeze(w(k,:,:)),Rx,PHIx);
        z_i(k,:,:)      = griddata(Rx_t,PHIx_t,squeeze(z(k,:,:)),Rx,PHIx);
        rho_i(k,:,:)    = griddata(Rx_t,PHIx_t,squeeze(rho(k,:,:)),Rx,PHIx);
        theta_i(k,:,:)  = griddata(Rx_t,PHIx_t,squeeze(theta(k,:,:)),Rx,PHIx);
        thetaE_i(k,:,:) = griddata(Rx_t,PHIx_t,squeeze(thetaE(k,:,:)),Rx,PHIx);
    end
    r_i = NaN(size(z_i));
    for k=1:size(z_i,1)
        for j=1:length(PHI)
            r_i(k,j,:) = R*1000;
        end
    end
    r_i(r_i==0) = NaN;
    u = u_i; v = v_i; w = w_i; z = z_i; rho = rho_i; r = r_i;
    theta = theta_i; thetaE = thetaE_i;
end

if Use_thetaE
    therm = thetaE;
else
    therm = theta;
end

th2 = squeeze(nanmean(therm,2));
z2 = squeeze(nanmean(z,2));
rho2 = squeeze(nanmean(rho,2));
r2 = squeeze(nanmean(r,2));
theta_ref = level_weighted_mean_2d(th2,r2,rho2);
z_ref = level_weighted_mean_2d(z2,r2,rho2);
dthdz_ref = gradient(theta_ref)./gradient(z_ref);
N2_ref = g./theta_ref.*dthdz_ref;
N2_ref(find(N2_ref<min_N2|isnan(N2_ref))) = min_N2;
ape_coef_lev = g.^2./(N2_ref.*theta_ref.^2);
ape_coef = repmat(ape_coef_lev(:),1,length(R));

therm_anom = therm;
for k=1:size(therm,1)
    therm_anom(k,:,:) = squeeze(therm(k,:,:)) - theta_ref(k);
end

nz = size(u,1);
nr = size(u,3);
KE  = NaN(nz,nr,length(WN));
APE = NaN(nz,nr,length(WN));
for nloc=1:length(WN)
    n = WN(nloc);
    KE(:,:,nloc)  = 0.5*(spectral_cov(u,u,n) + spectral_cov(v,v,n) + spectral_cov(w,w,n));
    APE(:,:,nloc) = 0.5*ape_coef.*spectral_cov(therm_anom,therm_anom,n);
end
end
