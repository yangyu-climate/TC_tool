clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_PVBG_config;

Data_dir = [pwd,'/Result/Data'];
Head_nam = cfg.Save_nam;
Save_nam = cfg.Save_nam;
Save_dir = [pwd,'/Result/PVBG'];
mkdir(Save_dir)

Time_beg = cfg.Time_beg;
Time_end = cfg.Time_end;
Time_frq = cfg.Time_frq;
Tendency_frq = cfg.Tendency_frq;
Use_thetaE = cfg.Use_thetaE;
Use_khkv_friction = cfg.Use_khkv_friction;

T_beg = datenum(Time_beg);
T_end = datenum(Time_end);
T_frq = Time_frq/60/24;
del_T = Tendency_frq/60/24;
D_to_S = 24*60*60;

for T = T_beg:T_frq:T_end
    TIME = T;
    [year_num,month_num,day_num,hour_num,minu_num,seco_num] = date2str(TIME);
    T_name = [year_num,'-',month_num,'-',day_num,'_',...
              hour_num,':',minu_num,':',seco_num];
    file_name = [Head_nam,'*',T_name,'.mat'];
    filename = dir([Data_dir,'/',file_name]);
    if ~isempty(filename)
        disp([' '])
        disp(['Date: ',T_name])
        file_name = filename.name(1:end-4);
        file_TN = [Data_dir,'/',file_name];

        R          = load_data([file_TN,'.mat'],'R');
        PHI        = load_data([file_TN,'.mat'],'PHI');
        dR         = load_data([file_TN,'.mat'],'dR');
        dPhi       = load_data([file_TN,'.mat'],'dPhi');
        z          = load_data([file_TN,'.mat'],'z');
        r          = load_data([file_TN,'.mat'],'r');
        P          = load_data([file_TN,'.mat'],'P');
        u          = load_data([file_TN,'.mat'],'u');
        v          = load_data([file_TN,'.mat'],'v');
        w          = load_data([file_TN,'.mat'],'w');
        rho        = load_data([file_TN,'.mat'],'rho');
        avo        = load_data([file_TN,'.mat'],'avo');
        kh         = load_data([file_TN,'.mat'],'kh');
        kv         = load_data([file_TN,'.mat'],'kv');
        Upbl       = load_data([file_TN,'.mat'],'Upbl');
        Vpbl       = load_data([file_TN,'.mat'],'Vpbl');
        pvo_wrf    = load_data([file_TN,'.mat'],'pvo');
        pv_theta   = load_data([file_TN,'.mat'],'pv_theta');
        pv_thetaE  = load_data([file_TN,'.mat'],'pv_thetaE');
        pv_theta_pvu  = load_data([file_TN,'.mat'],'pv_theta_pvu');
        pv_thetaE_pvu = load_data([file_TN,'.mat'],'pv_thetaE_pvu');
        theta      = load_data([file_TN,'.mat'],'theta');
        thetaE     = load_data([file_TN,'.mat'],'thetaE');
        H_DIABATIC = load_data([file_TN,'.mat'],'H_DIABATIC');
        lon_TC     = load_data([file_TN,'.mat'],'lon_TC');
        lat_TC     = load_data([file_TN,'.mat'],'lat_TC');
        slp_TC     = load_data([file_TN,'.mat'],'slp_TC');
        swd_TC     = load_data([file_TN,'.mat'],'swd_TC');

        dr = dR*1000;
        h = del_T*D_to_S;
        if Use_thetaE
            b = thetaE;
            PV = pv_thetaE;
            pv_name = 'thetaE';
        else
            b = theta;
            PV = pv_theta;
            pv_name = 'theta';
        end

        [PV_0 ,b_0 ,has_0 ] = load_pv_state(file_TN,T_name,TIME, 0,del_T,R,PHI,Use_thetaE);
        [PV_B ,b_B ,has_B ] = load_pv_state(file_TN,T_name,TIME,-1,del_T,R,PHI,Use_thetaE);
        [PV_F ,b_F ,has_F ] = load_pv_state(file_TN,T_name,TIME, 1,del_T,R,PHI,Use_thetaE);
        [PV_B2,b_B2,has_B2] = load_pv_state(file_TN,T_name,TIME,-2,del_T,R,PHI,Use_thetaE);
        [PV_F2,b_F2,has_F2] = load_pv_state(file_TN,T_name,TIME, 2,del_T,R,PHI,Use_thetaE);

        [PV_tendency,b_tendency,Tendency_scheme] = local_tendency(PV_0,PV_B,PV_F,PV_B2,PV_F2,...
                                                                  b_0,b_B,b_F,b_B2,b_F2,...
                                                                  has_0,has_B,has_F,has_B2,has_F2,h);
        if isempty(PV_tendency)
            disp(['Skip tendency calculation: no neighboring file for ',T_name])
            continue
        end
        dt = h;

        r_safe = r;
        r_safe(r_safe==0) = NaN;
        [PV_r,PV_phi,PV_z] = grad_cyl(PV,r_safe,z,dr,dPhi);
        [b_r,b_phi,b_z] = grad_cyl(b,r_safe,z,dr,dPhi);
        [rho_r,rho_phi,rho_z] = grad_cyl(rho,r_safe,z,dr,dPhi);
        P_pa = P*100;
        [P_r,P_phi,P_z] = grad_cyl(P_pa,r_safe,z,dr,dPhi);

        PV_radial_adv   = -u.*PV_r;
        PV_azimuth_adv  = -v.*PV_phi;
        PV_vertical_adv = -w.*PV_z;

        [zeta_r,zeta_phi,zeta_z] = absolute_vorticity_cyl(u,v,w,avo,r_safe,z,dr,dPhi);
        PV_solenoidal = dot_cross_grad(rho_r,rho_phi,rho_z,P_r,P_phi,P_z,b_r,b_phi,b_z)./(rho.^3);

        if Use_thetaE
            b_dot = b_tendency + u.*b_r + v.*b_phi + w.*b_z;
            b_dot_source = 'material_tendency';
        else
            b_dot = H_DIABATIC;
            b_dot_source = 'H_DIABATIC';
        end
        [bdot_r,bdot_phi,bdot_z] = grad_cyl(b_dot,r_safe,z,dr,dPhi);
        PV_therm = (zeta_r.*bdot_r + zeta_phi.*bdot_phi + zeta_z.*bdot_z)./rho;

        [curlF_r,curlF_phi,curlF_z] = curl_horizontal_forcing_cyl(Upbl,Vpbl,r_safe,z,dr,dPhi);
        PV_friction_pbl = (curlF_r.*b_r + curlF_phi.*b_phi + curlF_z.*b_z)./rho;
        [Fkhkv_r,Fkhkv_phi] = khkv_momentum_forcing_cyl(u,v,w,kh,kv,r_safe,z,dr,dPhi,rho);
        [curlK_r,curlK_phi,curlK_z] = curl_horizontal_forcing_cyl(Fkhkv_r,Fkhkv_phi,r_safe,z,dr,dPhi);
        PV_friction_khkv = (curlK_r.*b_r + curlK_phi.*b_phi + curlK_z.*b_z)./rho;
        if Use_khkv_friction
            PV_friction = PV_friction_pbl + PV_friction_khkv;
            Friction_note = 'PV_friction includes WRF PBL momentum tendencies plus kh/kv stress-tensor diagnostic; check for double counting.';
        else
            PV_friction = PV_friction_pbl;
            Friction_note = 'PV_friction uses WRF PBL momentum tendencies. PV_friction_khkv is saved as a diagnostic only to avoid double counting.';
        end

        PV_sum = PV_radial_adv + PV_azimuth_adv + PV_vertical_adv + ...
                 PV_solenoidal + PV_therm + PV_friction;
        PV_residual = PV_tendency - PV_sum;

        z2       = squeeze(nanmean(z,2));
        r2       = squeeze(nanmean(r,2));
        P2       = squeeze(nanmean(P,2));
        rho2     = squeeze(nanmean(rho,2));
        pvo_wrf2 = squeeze(nanmean(pvo_wrf,2));
        pv_theta2  = squeeze(nanmean(pv_theta,2));
        pv_thetaE2 = squeeze(nanmean(pv_thetaE,2));
        pv_diff2   = pv_thetaE2 - pv_theta2;
        pv_theta_pvu2  = squeeze(nanmean(pv_theta_pvu,2));
        pv_thetaE_pvu2 = squeeze(nanmean(pv_thetaE_pvu,2));
        pv_diff_pvu2   = pv_thetaE_pvu2 - pv_theta_pvu2;
        b2       = squeeze(nanmean(b,2));
        theta2   = squeeze(nanmean(theta,2));
        thetaE2  = squeeze(nanmean(thetaE,2));
        H2       = squeeze(nanmean(H_DIABATIC,2));
        bdot2    = squeeze(nanmean(b_dot,2));
        u_mean   = squeeze(nanmean(u,2));
        v_mean   = squeeze(nanmean(v,2));
        w_mean   = squeeze(nanmean(w,2));
        Upbl_mean = squeeze(nanmean(Upbl,2));
        Vpbl_mean = squeeze(nanmean(Vpbl,2));

        PV_tendency     = squeeze(nanmean(PV_tendency,2));
        PV_radial_adv   = squeeze(nanmean(PV_radial_adv,2));
        PV_azimuth_adv  = squeeze(nanmean(PV_azimuth_adv,2));
        PV_vertical_adv = squeeze(nanmean(PV_vertical_adv,2));
        PV_solenoidal   = squeeze(nanmean(PV_solenoidal,2));
        PV_therm        = squeeze(nanmean(PV_therm,2));
        PV_friction_pbl = squeeze(nanmean(PV_friction_pbl,2));
        PV_friction_khkv = squeeze(nanmean(PV_friction_khkv,2));
        PV_friction     = squeeze(nanmean(PV_friction,2));
        PV_sum          = squeeze(nanmean(PV_sum,2));
        PV_residual     = squeeze(nanmean(PV_residual,2));

        z = z2;
        r = r2;
        P = P2;
        P_pa = P*100;
        rho = rho2;
        pvo_wrf = pvo_wrf2;
        pv_theta = pv_theta2;
        pv_thetaE = pv_thetaE2;
        pv_diff = pv_diff2;
        pv_theta_pvu = pv_theta_pvu2;
        pv_thetaE_pvu = pv_thetaE_pvu2;
        pv_diff_pvu = pv_diff_pvu2;
        b = b2;
        theta = theta2;
        thetaE = thetaE2;
        H_DIABATIC = H2;
        b_dot = bdot2;

        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
            'R','PHI','dR','dPhi','dr','dt','Use_thetaE','Use_khkv_friction','pv_name',...
            'Tendency_scheme','b_dot_source','Friction_note',...
            'TIME','z','r','P','P_pa','rho','u_mean','v_mean','w_mean','Upbl_mean','Vpbl_mean',...
            'pvo_wrf','pv_theta','pv_thetaE','pv_diff','pv_theta_pvu','pv_thetaE_pvu','pv_diff_pvu',...
            'b','theta','thetaE','H_DIABATIC','b_dot',...
            'PV_tendency','PV_radial_adv','PV_azimuth_adv','PV_vertical_adv',...
            'PV_solenoidal','PV_therm','PV_friction_pbl','PV_friction_khkv','PV_friction','PV_sum','PV_residual',...
            'lon_TC','lat_TC','slp_TC','swd_TC')

        clear R PHI dR dPhi dr dt Tendency_scheme
        clear TIME z r P P_pa rho rho2 u v w avo kh kv Upbl Vpbl pvo_wrf pv_theta pv_thetaE pv_diff
        clear pv_theta_pvu pv_thetaE_pvu pv_diff_pvu
        clear theta thetaE H_DIABATIC b b_dot
        clear PV_tendency PV_radial_adv PV_azimuth_adv PV_vertical_adv
        clear PV_solenoidal PV_therm PV_friction_pbl PV_friction_khkv PV_friction PV_sum PV_residual
        clear lon_TC lat_TC slp_TC swd_TC
    end
end

function [tend,btend,scheme] = local_tendency(PV_0,PV_B,PV_F,PV_B2,PV_F2,...
                                              b_0,b_B,b_F,b_B2,b_F2,...
                                              has_0,has_B,has_F,has_B2,has_F2,h)

tend = [];
btend = [];
scheme = 'none';
if has_B2 && has_B && has_F && has_F2
    tend  = (-PV_F2 + 8*PV_F - 8*PV_B + PV_B2)/(12*h);
    btend = (-b_F2  + 8*b_F  - 8*b_B  + b_B2 )/(12*h);
    scheme = 'fourth_order_centered';
elseif has_B && has_F
    tend  = (PV_F-PV_B)/(2*h);
    btend = (b_F-b_B)/(2*h);
    scheme = 'second_order_centered';
elseif has_0 && has_F && has_F2
    tend  = (-3*PV_0 + 4*PV_F - PV_F2)/(2*h);
    btend = (-3*b_0  + 4*b_F  - b_F2 )/(2*h);
    scheme = 'second_order_forward';
elseif has_0 && has_B && has_B2
    tend  = (3*PV_0 - 4*PV_B + PV_B2)/(2*h);
    btend = (3*b_0  - 4*b_B  + b_B2 )/(2*h);
    scheme = 'second_order_backward';
elseif has_0 && has_F
    tend  = (PV_F-PV_0)/h;
    btend = (b_F-b_0)/h;
    scheme = 'first_order_forward';
elseif has_0 && has_B
    tend  = (PV_0-PV_B)/h;
    btend = (b_0-b_B)/h;
    scheme = 'first_order_backward';
end
end

function [PV,b,has_file] = load_pv_state(file_name,T_name,TIME,offset,del_T,R,PHI,Use_thetaE)

if offset==0
    file_t = file_name;
else
    [year_num,month_num,day_num,hour_num,minu_num,seco_num] = date2str(TIME+offset*del_T);
    name_t = [year_num,'-',month_num,'-',day_num,'_',hour_num,':',minu_num,':',seco_num];
    file_t = [file_name(1:end-length(T_name)),name_t];
end

has_file = ~isempty(dir([file_t,'.mat']));
if ~has_file
    PV = [];
    b = [];
    return
end

R_t   = load_data([file_t,'.mat'],'R');
PHI_t = load_data([file_t,'.mat'],'PHI');
if Use_thetaE
    PV = load_data([file_t,'.mat'],'pv_thetaE');
    b  = load_data([file_t,'.mat'],'thetaE');
else
    PV = load_data([file_t,'.mat'],'pv_theta');
    b  = load_data([file_t,'.mat'],'theta');
end
if (nansum(abs(R_t-R))+nansum(abs(PHI_t-PHI)))>0
    [Rx_t,PHIx_t] = meshgrid(R_t,PHI_t);
    [Rx,PHIx] = meshgrid(R,PHI);
    PV_i = NaN(size(PV,1),length(PHI),length(R));
    b_i  = NaN(size(b,1),length(PHI),length(R));
    for k=1:size(PV,1)
        PV_i(k,:,:) = griddata(Rx_t,PHIx_t,squeeze(PV(k,:,:)),Rx,PHIx);
        b_i(k,:,:)  = griddata(Rx_t,PHIx_t,squeeze(b(k,:,:)) ,Rx,PHIx);
    end
    PV = PV_i;
    b = b_i;
end
end

function [ar,ap,az] = grad_cyl(a,r,z,dr,dPhi)

ar = d_dr_3d(a,dr);
ap = 1./r.*d_phi_3d(a,dPhi);
az = d_z_3d(a,z);
end

function s = dot_cross_grad(ar,ap,az,br,bp,bz,cr,cp,cz)

s = (ap.*bz - az.*bp).*cr + ...
    (az.*br - ar.*bz).*cp + ...
    (ar.*bp - ap.*br).*cz;
end

function [zeta_r,zeta_phi,zeta_z] = absolute_vorticity_cyl(u,v,w,avo,r,z,dr,dPhi)

zeta_r   = 1./r.*d_phi_3d(w,dPhi) - d_z_3d(v,z);
zeta_phi = d_z_3d(u,z) - d_dr_3d(w,dr);
zeta_z   = avo;
end

function [curlF_r,curlF_phi,curlF_z] = curl_horizontal_forcing_cyl(Fr,Fphi,r,z,dr,dPhi)

curlF_r   = -d_z_3d(Fphi,z);
curlF_phi = d_z_3d(Fr,z);
curlF_z   = 1./r.*d_dr_3d(r.*Fphi,dr) - 1./r.*d_phi_3d(Fr,dPhi);
end

function [Fr,Fphi] = khkv_momentum_forcing_cyl(u,v,w,kh,kv,r,z,dr,dPhi,rho)

Trp = kh.*(d_phi_3d(u,dPhi)./r + r.*d_dr_3d(v./r,dr));
Tpz = kv.*(d_phi_3d(w,dPhi)./r + d_z_3d(v,z));
Trr = 2*kh.*d_dr_3d(u,dr);
Tpp = 2*kh.*(d_phi_3d(v,dPhi)./r + u./r);
Trz = kv.*(d_z_3d(u,z) + d_dr_3d(w,dr));

Fr = 1./(r.*rho).*d_dr_3d(r.*rho.*Trr,dr) + ...
     1./(r.*rho).*d_phi_3d(rho.*Trp,dPhi) + ...
     1./rho.*d_z_3d(rho.*Trz,z) - Tpp./r;
Fphi = 1./((r.^2).*rho).*d_dr_3d((r.^2).*rho.*Trp,dr) + ...
       1./(r.*rho).*d_phi_3d(rho.*Tpp,dPhi) + ...
       1./rho.*d_z_3d(rho.*Tpz,z);
end

function drv = d_dr_3d(v,dr)

drv = NaN(size(v));
for k=1:size(v,1)
    for i=1:size(v,2)
        drv(k,i,:) = gradient(squeeze(v(k,i,:)))./dr;
    end
end
end

function dpv = d_phi_3d(v,dPhi)

dpv = NaN(size(v));
nphi = size(v,2);
for k=1:size(v,1)
    for j=1:size(v,3)
        x = squeeze(v(k,:,j));
        dpv(k,:,j) = (circshift(x,[0 -1]) - circshift(x,[0 1]))/(2*dPhi);
        if nphi<3
            dpv(k,:,j) = gradient(x)./dPhi;
        end
    end
end
end

function dzv = d_z_3d(v,z)

dzv = NaN(size(v));
for i=1:size(v,2)
    for j=1:size(v,3)
        Z = squeeze(z(:,i,j));
        V = squeeze(v(:,i,j));
        dzv(:,i,j) = gradient(V)./gradient(Z);
    end
end
end
