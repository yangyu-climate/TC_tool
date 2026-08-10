clear
clc

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
Omega = cfg.Omega;

T_beg = datenum(Time_beg);
T_end = datenum(Time_end);
D_to_S = 24*60*60;
assert(isscalar(Tendency_frq) && isfinite(Tendency_frq) && Tendency_frq>0,...
    'TC_PVBG:TendencyFrequency','cfg.Tendency_frq must be a positive number of minutes.')
Tendency_step_day = Tendency_frq/(24*60);

filename = dir(fullfile(Data_dir,[Head_nam,'*.mat']));
[~,order] = sort({filename.name});
filename = filename(order);
for file_index = 1:numel(filename)
    file_name = filename(file_index).name(1:end-4);
    file_TN = fullfile(Data_dir,file_name);
    TIME = load_data([file_TN,'.mat'],'TIME');
    if TIME>=T_beg && TIME<=T_end
        source_T_name = tc_time_name(TIME,contains(filename(file_index).name,':'));
        T_name = tc_time_name(TIME);
        disp([' '])
        disp(['Date: ',T_name])

        R          = load_data([file_TN,'.mat'],'R');
        PHI        = load_data([file_TN,'.mat'],'PHI');
        dR         = load_data([file_TN,'.mat'],'dR');
        dPhi       = load_data([file_TN,'.mat'],'dPhi');
        z          = load_data([file_TN,'.mat'],'z');
        r          = load_data([file_TN,'.mat'],'r');
        P          = load_data([file_TN,'.mat'],'P');
        lat        = load_data([file_TN,'.mat'],'lat');
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
        heating_components_available = load_data([file_TN,'.mat'],'heating_components_available');
        lon_TC     = load_data([file_TN,'.mat'],'lon_TC');
        lat_TC     = load_data([file_TN,'.mat'],'lat_TC');
        slp_TC     = load_data([file_TN,'.mat'],'slp_TC');
        swd_TC     = load_data([file_TN,'.mat'],'swd_TC');

        dr = dR*1000;
        if Use_thetaE
            b = thetaE;
            PV = pv_thetaE;
            pv_name = 'thetaE';
            PV_budget_interpretation = ['Generalized Ertel PV of diagnostic equivalent potential temperature. ',...
                'PV_therm uses diagnosed D(thetaE)/Dt and is not a uniquely process-separated moist-PV heating budget.'];
        else
            b = theta;
            PV = pv_theta;
            pv_name = 'theta';
            PV_budget_interpretation = ['Dry-theta Ertel PV budget. PV_therm uses the exported ',...
                'theta-tendency sum; its interpretation remains limited by available WRF tendencies.'];
        end

        [PV_0 ,b_0 ,has_0 ,time_0 ] = load_pv_state(file_TN,source_T_name,TIME, 0,Tendency_step_day,R,PHI,Use_thetaE);
        [PV_B ,b_B ,has_B ,time_B ] = load_pv_state(file_TN,source_T_name,TIME,-1,Tendency_step_day,R,PHI,Use_thetaE);
        [PV_F ,b_F ,has_F ,time_F ] = load_pv_state(file_TN,source_T_name,TIME, 1,Tendency_step_day,R,PHI,Use_thetaE);
        [PV_B2,b_B2,has_B2,time_B2] = load_pv_state(file_TN,source_T_name,TIME,-2,Tendency_step_day,R,PHI,Use_thetaE);
        [PV_F2,b_F2,has_F2,time_F2] = load_pv_state(file_TN,source_T_name,TIME, 2,Tendency_step_day,R,PHI,Use_thetaE);

        [PV_tendency,b_tendency,Tendency_scheme] = local_tendency(PV_0,PV_B,PV_F,PV_B2,PV_F2,...
                                                                  b_0,b_B,b_F,b_B2,b_F2,...
                                                                  has_0,has_B,has_F,has_B2,has_F2,...
                                                                  time_0,time_B,time_F,time_B2,time_F2,D_to_S);
        if isempty(PV_tendency)
            disp(['Skip tendency calculation: no neighboring file for ',T_name])
            continue
        end
        dt = NaN;
        if has_B && has_F, dt = 0.5*(time_F-time_B)*D_to_S; end

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

        [zeta_r,zeta_phi,zeta_z] = absolute_vorticity_cyl(u,v,w,avo,r_safe,z,dr,dPhi,lat,PHI,Omega);
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

        z2       = squeeze(mean(z,2,'omitnan'));
        r2       = squeeze(mean(r,2,'omitnan'));
        P2       = squeeze(mean(P,2,'omitnan'));
        rho2     = squeeze(mean(rho,2,'omitnan'));
        pvo_wrf2 = squeeze(mean(pvo_wrf,2,'omitnan'));
        pv_theta2  = squeeze(mean(pv_theta,2,'omitnan'));
        pv_thetaE2 = squeeze(mean(pv_thetaE,2,'omitnan'));
        pv_diff2   = pv_thetaE2 - pv_theta2;
        pv_theta_pvu2  = squeeze(mean(pv_theta_pvu,2,'omitnan'));
        pv_thetaE_pvu2 = squeeze(mean(pv_thetaE_pvu,2,'omitnan'));
        pv_diff_pvu2   = pv_thetaE_pvu2 - pv_theta_pvu2;
        b2       = squeeze(mean(b,2,'omitnan'));
        theta2   = squeeze(mean(theta,2,'omitnan'));
        thetaE2  = squeeze(mean(thetaE,2,'omitnan'));
        H2       = squeeze(mean(H_DIABATIC,2,'omitnan'));
        bdot2    = squeeze(mean(b_dot,2,'omitnan'));
        u_mean   = squeeze(mean(u,2,'omitnan'));
        v_mean   = squeeze(mean(v,2,'omitnan'));
        w_mean   = squeeze(mean(w,2,'omitnan'));
        Upbl_mean = squeeze(mean(Upbl,2,'omitnan'));
        Vpbl_mean = squeeze(mean(Vpbl,2,'omitnan'));

        PV_tendency     = squeeze(mean(PV_tendency,2,'omitnan'));
        PV_radial_adv   = squeeze(mean(PV_radial_adv,2,'omitnan'));
        PV_azimuth_adv  = squeeze(mean(PV_azimuth_adv,2,'omitnan'));
        PV_vertical_adv = squeeze(mean(PV_vertical_adv,2,'omitnan'));
        PV_solenoidal   = squeeze(mean(PV_solenoidal,2,'omitnan'));
        PV_therm        = squeeze(mean(PV_therm,2,'omitnan'));
        PV_friction_pbl = squeeze(mean(PV_friction_pbl,2,'omitnan'));
        PV_friction_khkv = squeeze(mean(PV_friction_khkv,2,'omitnan'));
        PV_friction     = squeeze(mean(PV_friction,2,'omitnan'));
        PV_sum          = squeeze(mean(PV_sum,2,'omitnan'));
        PV_residual     = squeeze(mean(PV_residual,2,'omitnan'));

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
            'R','PHI','dR','dPhi','dr','dt','Use_thetaE','Use_khkv_friction','Omega','pv_name',...
            'Tendency_scheme','b_dot_source','Friction_note','PV_budget_interpretation','heating_components_available',...
            'TIME','z','r','P','P_pa','rho','u_mean','v_mean','w_mean','Upbl_mean','Vpbl_mean',...
            'pvo_wrf','pv_theta','pv_thetaE','pv_diff','pv_theta_pvu','pv_thetaE_pvu','pv_diff_pvu',...
            'b','theta','thetaE','H_DIABATIC','b_dot',...
            'PV_tendency','PV_radial_adv','PV_azimuth_adv','PV_vertical_adv',...
            'PV_solenoidal','PV_therm','PV_friction_pbl','PV_friction_khkv','PV_friction','PV_sum','PV_residual',...
            'lon_TC','lat_TC','slp_TC','swd_TC')

        clear R PHI dR dPhi dr dt Tendency_scheme
        clear TIME lat z r P P_pa rho rho2 u v w avo kh kv Upbl Vpbl pvo_wrf pv_theta pv_thetaE pv_diff
        clear pv_theta_pvu pv_thetaE_pvu pv_diff_pvu
        clear theta thetaE H_DIABATIC heating_components_available b b_dot
        clear PV_tendency PV_radial_adv PV_azimuth_adv PV_vertical_adv
        clear PV_solenoidal PV_therm PV_friction_pbl PV_friction_khkv PV_friction PV_sum PV_residual
        clear lon_TC lat_TC slp_TC swd_TC
    end
end

function [tend,btend,scheme] = local_tendency(PV_0,PV_B,PV_F,PV_B2,PV_F2,...
                                              b_0,b_B,b_F,b_B2,b_F2,...
                                              has_0,has_B,has_F,has_B2,has_F2,...
                                              time_0,time_B,time_F,time_B2,time_F2,day_to_second)

tend = [];
btend = [];
scheme = 'none';
if has_B2 && has_B && has_F && has_F2 && is_uniform_time_grid([time_B2 time_B time_0 time_F time_F2])
    h = (time_F-time_0)*day_to_second;
    tend  = (-PV_F2 + 8*PV_F - 8*PV_B + PV_B2)/(12*h);
    btend = (-b_F2  + 8*b_F  - 8*b_B  + b_B2 )/(12*h);
    scheme = 'fourth_order_centered';
elseif has_0 && has_B && has_F
    tend  = three_point_time_derivative(PV_B,time_B,PV_0,time_0,PV_F,time_F,day_to_second);
    btend = three_point_time_derivative(b_B,time_B,b_0,time_0,b_F,time_F,day_to_second);
    scheme = 'second_order_centered_variable_step';
elseif has_0 && has_F && has_F2
    tend  = three_point_time_derivative(PV_0,time_0,PV_F,time_F,PV_F2,time_F2,day_to_second);
    btend = three_point_time_derivative(b_0,time_0,b_F,time_F,b_F2,time_F2,day_to_second);
    scheme = 'second_order_forward_variable_step';
elseif has_0 && has_B && has_B2
    tend  = three_point_time_derivative(PV_B2,time_B2,PV_B,time_B,PV_0,time_0,day_to_second);
    btend = three_point_time_derivative(b_B2,time_B2,b_B,time_B,b_0,time_0,day_to_second);
    scheme = 'second_order_backward_variable_step';
elseif has_0 && has_F
    h = (time_F-time_0)*day_to_second;
    tend  = (PV_F-PV_0)/h;
    btend = (b_F-b_0)/h;
    scheme = 'first_order_forward';
elseif has_0 && has_B
    h = (time_0-time_B)*day_to_second;
    tend  = (PV_0-PV_B)/h;
    btend = (b_0-b_B)/h;
    scheme = 'first_order_backward';
end
end

function [PV,b,has_file,state_time] = load_pv_state(file_name,T_name,TIME,offset,tendency_step_day,R,PHI,Use_thetaE)

% Select the configured tendency stencil by saved time.  Do not silently use
% the next file when an output is missing or has a different cadence.
prefix = file_name(1:end-length(T_name));
persistent cached_prefix cached_entries cached_times
if isempty(cached_prefix) || ~strcmp(cached_prefix,prefix)
    cached_entries = dir([prefix,'*.mat']);
    cached_times = NaN(size(cached_entries));
    for k = 1:numel(cached_entries)
        cached_times(k) = load_data(fullfile(cached_entries(k).folder,cached_entries(k).name),'TIME');
    end
    [cached_times,order] = sort(cached_times);
    cached_entries = cached_entries(order);
    cached_prefix = prefix;
end
entries = cached_entries;
state_times = cached_times;
[time_error,~] = min(abs(state_times-TIME));
if isempty(state_times) || ~isfinite(time_error) || time_error>0.5/86400
    error('TC_PVBG:TendencyTime','Unable to locate the current state by its saved timestamp.')
end
target_time = TIME + offset*tendency_step_day;
[time_error,target_index] = min(abs(state_times-target_time));
has_file = ~isempty(target_index) && isfinite(time_error) && time_error<=0.5/86400;
if ~has_file
    file_t = '';
    PV = [];
    b = [];
    state_time = NaN;
    return
end
file_t = fullfile(entries(target_index).folder,entries(target_index).name);

R_t   = load_data(file_t,'R');
PHI_t = load_data(file_t,'PHI');
state_time = load_data(file_t,'TIME');
if Use_thetaE
    PV = load_data(file_t,'pv_thetaE');
    b  = load_data(file_t,'thetaE');
else
    PV = load_data(file_t,'pv_theta');
    b  = load_data(file_t,'theta');
end
if (sum(abs(R_t-R),'omitnan')+sum(abs(PHI_t-PHI),'omitnan'))>0
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

function [zeta_r,zeta_phi,zeta_z] = absolute_vorticity_cyl(u,v,w,avo,r,z,dr,dPhi,lat,PHI,Omega)

[zeta_r,zeta_phi,zeta_z] = tc_absolute_vorticity_cyl(u,v,w,avo,r,z,dr,dPhi,lat,PHI,Omega);
end

function [curlF_r,curlF_phi,curlF_z] = curl_horizontal_forcing_cyl(Fr,Fphi,r,z,dr,dPhi)

curlF_r   = -d_z_3d(Fphi,z);
curlF_phi = d_z_3d(Fr,z);
rFphi = r.*Fphi;
rFphi(:,:,1) = 0; % regular cylindrical limit prevents axis-NaN leakage
curlF_z   = 1./r.*d_dr_3d(rFphi,dr) - 1./r.*d_phi_3d(Fr,dPhi);
end

function [Fr,Fphi] = khkv_momentum_forcing_cyl(u,v,w,kh,kv,r,z,dr,dPhi,rho)

v_over_r = v./r;
if size(r,3)>1
    v_over_r(:,:,1) = v_over_r(:,:,2);
end
Trp = kh.*(d_phi_3d(u,dPhi)./r + r.*d_dr_3d(v_over_r,dr));
Tpz = kv.*(d_phi_3d(w,dPhi)./r + d_z_3d(v,z));
Trr = 2*kh.*d_dr_3d(u,dr);
Tpp = 2*kh.*(d_phi_3d(v,dPhi)./r + u./r);
Trz = kv.*(d_z_3d(u,z) + d_dr_3d(w,dr));

r_rho_Trr = r.*rho.*Trr;
r_rho_Trr(:,:,1) = 0;
r2_rho_Trp = (r.^2).*rho.*Trp;
r2_rho_Trp(:,:,1) = 0;
Fr = 1./(r.*rho).*d_dr_3d(r_rho_Trr,dr) + ...
     1./(r.*rho).*d_phi_3d(rho.*Trp,dPhi) + ...
     1./rho.*d_z_3d(rho.*Trz,z) - Tpp./r;
Fphi = 1./((r.^2).*rho).*d_dr_3d(r2_rho_Trp,dr) + ...
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
dpv = cylindrical_phi_derivative(v,dPhi);
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

function derivative = three_point_time_derivative(y1,t1,y2,t2,y3,t3,day_to_second)

t1=t1*day_to_second; t2=t2*day_to_second; t3=t3*day_to_second;
assert(t1<t2 && t2<t3,'TC_PVBG:TendencyTime','Tendency timestamps must be strictly increasing.')
w1 = (t2-t3)/((t1-t2)*(t1-t3));
w2 = (2*t2-t1-t3)/((t2-t1)*(t2-t3));
w3 = (t2-t1)/((t3-t1)*(t3-t2));
derivative = w1*y1 + w2*y2 + w3*y3;
end

function tf = is_uniform_time_grid(t)

dt = diff(t)*86400;
tf = all(isfinite(dt)) && all(dt>0) && max(abs(dt-dt(1))) <= max(1e-6,1e-8*dt(1));
end
