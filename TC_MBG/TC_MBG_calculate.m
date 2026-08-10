clear
clc

Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_MBG_config;

Data_dir   = [pwd,'/Result/azimuthally'];
Head_nam   = cfg.Save_nam;
Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/MBG'];
mkdir(Save_dir)

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Subgrid_momentum_mode = cfg.calc.Subgrid_momentum_mode;
Tendency_frq = cfg.calc.Tendency_frq;
assert(isscalar(Tendency_frq) && isfinite(Tendency_frq) && Tendency_frq>0,...
    'TC_MBG:TendencyFrequency','cfg.calc.Tendency_frq must be a positive number of minutes.')
Tendency_step_day = Tendency_frq/(24*60);

T_beg      = datenum(Time_beg);
T_end      = datenum(Time_end);
D_to_S     = 24*60*60;

filename = dir(fullfile(Data_dir,[Head_nam,'*.mat']));
[~,order] = sort({filename.name});
filename = filename(order);
for file_index = 1:numel(filename)
    file_name = filename(file_index).name(1:end-4);
    file_name = fullfile(Data_dir,file_name);
    file_TN   = file_name;
    TIME = load_data([file_TN,'.mat'],'TIME');
    if TIME>=T_beg && TIME<=T_end
        source_T_name = tc_time_name(TIME,contains(filename(file_index).name,':'));
        T_name = tc_time_name(TIME);
        disp([' '])	
        disp(['Date: ',T_name])	
        % Basic Variables
        R     = load_data([file_TN,'.mat'],'R');
        PHI   = load_data([file_TN,'.mat'],'PHI');
        dR    = load_data([file_TN,'.mat'],'dR');
        dPhi  = load_data([file_TN,'.mat'],'dPhi');
        lon   = load_data([file_TN,'.mat'],'lon');
        lat   = load_data([file_TN,'.mat'],'lat');
        r     = load_data([file_TN,'.mat'],'r');
        dr    = load_data([file_TN,'.mat'],'dr');
        r(r==0) = NaN;
        z     = load_data([file_TN,'.mat'],'z');
        P     = load_data([file_TN,'.mat'],'P');
        f     = load_data([file_TN,'.mat'],'f');
        u     = load_data([file_TN,'.mat'],'u');
        v     = load_data([file_TN,'.mat'],'v');
        lon_TC= load_data([file_TN,'.mat'],'lon_TC');
        lat_TC= load_data([file_TN,'.mat'],'lat_TC');
        slp_TC= load_data([file_TN,'.mat'],'slp_TC');
        swd_TC= load_data([file_TN,'.mat'],'swd_TC');

        
        % Tendency (Ut&Vt)
        disp(['Calculating... : Ut & Vt'])
        [var_0u ,var_0v ,has_0 ,~,time_0 ] = load_mbg_tendency_state(file_name,source_T_name,TIME, 0,Tendency_step_day,R,PHI);
        [var_Bu ,var_Bv ,has_B ,~,time_B ] = load_mbg_tendency_state(file_name,source_T_name,TIME,-1,Tendency_step_day,R,PHI);
        [var_Fu ,var_Fv ,has_F ,~,time_F ] = load_mbg_tendency_state(file_name,source_T_name,TIME, 1,Tendency_step_day,R,PHI);
        [var_B2u,var_B2v,has_B2,~,time_B2] = load_mbg_tendency_state(file_name,source_T_name,TIME,-2,Tendency_step_day,R,PHI);
        [var_F2u,var_F2v,has_F2,~,time_F2] = load_mbg_tendency_state(file_name,source_T_name,TIME, 2,Tendency_step_day,R,PHI);

        if has_B2 && has_B && has_F && has_F2 && is_uniform_time_grid([time_B2 time_B time_0 time_F time_F2])
            h = (time_F-time_0)*D_to_S;
            Ut = (-var_F2u + 8*var_Fu - 8*var_Bu + var_B2u)/(12*h);
            Vt = (-var_F2v + 8*var_Fv - 8*var_Bv + var_B2v)/(12*h);
            Tendency_scheme = 'fourth_order_centered';
        elseif has_0 && has_B && has_F
            Ut = three_point_time_derivative(var_Bu,time_B,var_0u,time_0,var_Fu,time_F,D_to_S);
            Vt = three_point_time_derivative(var_Bv,time_B,var_0v,time_0,var_Fv,time_F,D_to_S);
            Tendency_scheme = 'second_order_centered_variable_step';
        elseif has_0 && has_F && has_F2
            Ut = three_point_time_derivative(var_0u,time_0,var_Fu,time_F,var_F2u,time_F2,D_to_S);
            Vt = three_point_time_derivative(var_0v,time_0,var_Fv,time_F,var_F2v,time_F2,D_to_S);
            Tendency_scheme = 'second_order_forward_variable_step';
        elseif has_0 && has_B && has_B2
            Ut = three_point_time_derivative(var_B2u,time_B2,var_Bu,time_B,var_0u,time_0,D_to_S);
            Vt = three_point_time_derivative(var_B2v,time_B2,var_Bv,time_B,var_0v,time_0,D_to_S);
            Tendency_scheme = 'second_order_backward_variable_step';
        elseif has_0 && has_F
            h = (time_F-time_0)*D_to_S;
            Ut = (var_Fu-var_0u)/h;
            Vt = (var_Fv-var_0v)/h;
            Tendency_scheme = 'first_order_forward';
        elseif has_0 && has_B
            h = (time_0-time_B)*D_to_S;
            Ut = (var_0u-var_Bu)/h;
            Vt = (var_0v-var_Bv)/h;
            Tendency_scheme = 'first_order_backward';
        else
            disp(['Skip tendency calculation: no neighboring file for ',T_name])
            continue
        end
        dt = NaN;
        if has_B && has_F, dt = 0.5*(time_F-time_B)*D_to_S; end
        disp(['Tendency scheme: ',Tendency_scheme])
        clear h var_0u var_0v var_Bu var_Bv var_Fu var_Fv var_B2u var_B2v var_F2u var_F2v
        clear has_0 has_B has_F has_B2 has_F2

        
        % V momentum equation
        % Mean radial influx of absolute vertical votyicity (Vmzeta)
        disp(['Calculating... : Vmzeta'])
        um    = load_data([file_TN,'.mat'],'um');
        Om    = load_data([file_TN,'.mat'],'Om');
        F     = load_data([file_TN,'.mat'],'F');
        Vmzeta= -um.*(Om+F);
        clear um Om F
        
        % Mean vertical advection of mean tangential momentum (Vmv)
        disp(['Calculating... : Vmv'])
        wm    = load_data([file_TN,'.mat'],'wm');
        vm    = load_data([file_TN,'.mat'],'vm');
        Vmv   = -wm.*dVdZ(vm,z);
        clear wm vm
        
        % Eddy radial vorticity flux (Vezeta)
        disp(['Calculating... : Vezeta'])
        up    = load_data([file_TN,'.mat'],'up');
        Op    = load_data([file_TN,'.mat'],'Op');
        Vezeta= -up.*Op;
        clear up Op
        
        % Vertical advection of eddy tangential momentum (Vev)
        disp(['Calculating... : Vev'])
        wp    = load_data([file_TN,'.mat'],'wp');
        vp    = load_data([file_TN,'.mat'],'vp');
        Vev   = -wp.*dVdZ(vp,z);
        clear wp vp
                
        % Combined mean horzential and vertical diffusive tendency (Vd)
        disp(['Calculating... : Vd'])
        Rm    = load_data([file_TN,'.mat'],'Rm');
        TrpM  = load_data([file_TN,'.mat'],'TrpM');
        TpzM  = load_data([file_TN,'.mat'],'TpzM');
        Vdr_flux = (r.^2).*Rm.*TrpM;
        Vdr_flux(:,:,1) = 0; % regular cylindrical limit at r=0
        Vdr   = 1./((r.^2).*Rm).*dVdR(Vdr_flux,dr);
        Vdz   = 1./Rm.*dVdZ(Rm.*TpzM,z);
        Vd    = Vdr + Vdz;
        clear Rm TrpM TpzM

        % Direct WRF PBL tangential tendency (Vpbl)
        disp(['Calculating... : Vpbl'])
        Vpbl  = load_data([file_TN,'.mat'],'VpblM');
        
        
        % U momentum equation
        % Mean radial advection of radial momentum (Umr)
        disp(['Calculating... : Umr'])
        um    = load_data([file_TN,'.mat'],'um');
        Umr   = um.*dVdR(um,dr);
        clear um
        
        % Mean horizential advection of eddy radial momentum (Ueh)
        disp(['Calculating... : Ueh'])
        up    = load_data([file_TN,'.mat'],'up');
        vp    = load_data([file_TN,'.mat'],'vp');
        Ueh   = up.*dVdR(up,dr) + vp./r.*dVdPhi(up,dPhi);
        clear up vp
        
        % Minus the mean vertical advection of mean radial momentum (Umv)
        disp(['Calculating... : Umv'])
        um    = load_data([file_TN,'.mat'],'um');
        wm    = load_data([file_TN,'.mat'],'wm');
        Umv   = -wm.*dVdZ(um,z);
        clear um wm
        
        % Minus the eddy vertical advection of eddy radial momentum (Uev)
        disp(['Calculating... : Uev'])
        up    = load_data([file_TN,'.mat'],'up');
        wp    = load_data([file_TN,'.mat'],'wp');
        Uev   = -wp.*dVdZ(up,z);
        clear up wp
        
        % Mean curvature/Coriolis and pressure-gradient accelerations.
        disp(['Calculating... : Uagf_total'])
        vm    = load_data([file_TN,'.mat'],'vm');
        F     = load_data([file_TN,'.mat'],'F');
        P_sample = P(~isnan(P));
        pressure_scale_to_pa = 1;
        Pressure_gradient_unit = 'Pa';
        if ~isempty(P_sample) && mean(abs(P_sample(:)),'omitnan')<2000
            pressure_scale_to_pa = 100;
            Pressure_gradient_unit = 'converted_hPa_to_Pa';
        end
        % Compute -rho^{-1} dp/dr before azimuthal averaging.  Replacing
        % this by -<rho>^{-1} d<p>/dr omits a density--pressure-gradient
        % covariance and is not the exact mean radial pressure force.
        rho   = load_data([file_TN,'.mat'],'rho');
        Upressure = -1./rho.*dVdR(P*pressure_scale_to_pa,dr);
        Umagf = (vm.^2)./r + F.*vm;
        clear vm F rho
        
        % Eddy agradient force (Ueagf)
        disp(['Calculating... : Ueagf'])
        vp    = load_data([file_TN,'.mat'],'vp');
        Ueagf = (vp.^2)./r;
        clear vp
        
        % Combined mean radial and vertical diffusive tendency (Ud)
        disp(['Calculating... : Ud'])
        Rm    = load_data([file_TN,'.mat'],'Rm');
        TrrM  = load_data([file_TN,'.mat'],'TrrM');
        TppM  = load_data([file_TN,'.mat'],'TppM');
        TrzM  = load_data([file_TN,'.mat'],'TrzM');
        Udh_flux = r.*Rm.*TrrM;
        Udh_flux(:,:,1) = 0; % regular cylindrical limit at r=0
        Udh   = 1./(r.*Rm).*dVdR(Udh_flux,dr) - TppM./r;
        Udz   = 1./Rm.*dVdZ(Rm.*TrzM,z);
        Ud    = Udh + Udz;
        clear Rm TrrM TppM TrzM

        % Direct WRF PBL radial tendency (Upbl)
        disp(['Calculating... : Upbl'])
        Upbl  = load_data([file_TN,'.mat'],'UpblM');
        
        
        % Azimuthlly average
        z      = squeeze(mean(z,2,'omitnan'));
        P      = squeeze(mean(P,2,'omitnan'));
        u      = squeeze(mean(u,2,'omitnan'));
        v      = squeeze(mean(v,2,'omitnan'));
        
        Vt     = squeeze(mean(Vt,2,'omitnan'));
        Vmzeta = squeeze(mean(Vmzeta,2,'omitnan'));
        Vmv    = squeeze(mean(Vmv,2,'omitnan'));
        Vezeta = squeeze(mean(Vezeta,2,'omitnan'));
        Vev    = squeeze(mean(Vev,2,'omitnan'));
        Vd     = squeeze(mean(Vd,2,'omitnan'));
        Vdr    = squeeze(mean(Vdr,2,'omitnan'));
        Vdz    = squeeze(mean(Vdz,2,'omitnan'));
        Vpbl   = squeeze(mean(Vpbl,2,'omitnan'));
        
        Ut     = squeeze(mean(Ut,2,'omitnan'));
        Umr    = squeeze(mean(Umr,2,'omitnan'));
        Ueh    = squeeze(mean(Ueh,2,'omitnan'));
        Umv    = squeeze(mean(Umv,2,'omitnan'));
        Uev    = squeeze(mean(Uev,2,'omitnan'));
        Umagf  = squeeze(mean(Umagf,2,'omitnan'));
        Upressure = squeeze(mean(Upressure,2,'omitnan'));
        Uagf_total = Umagf + Upressure;
        Uagf_definition = ['Uagf_total = Umagf + Upressure; ',...
            'Umagf = vm^2/r + f*vm (mean curvature/Coriolis acceleration); ',...
            'Upressure = <-(1/rho) dp/dr>.'];
        Upressure_definition = 'Azimuthal mean of the pointwise pressure-gradient acceleration <-(1/rho) dp/dr>.';
        Ueagf  = squeeze(mean(Ueagf,2,'omitnan'));
        Ud     = squeeze(mean(Ud,2,'omitnan'));
        Udh    = squeeze(mean(Udh,2,'omitnan'));
        Udz    = squeeze(mean(Udz,2,'omitnan'));
        Upbl   = squeeze(mean(Upbl,2,'omitnan'));
         
 
        % Budget closure diagnostics.  Direct WRF PBL tendencies and the
        % kh/kv stress-tensor diagnostic represent alternative subgrid
        % forcings, so including both would double count mixing.
        switch lower(Subgrid_momentum_mode)
            case 'wrf_pbl_tendency'
                V_subgrid = Vpbl;
                U_subgrid = Upbl;
                Subgrid_momentum_source = 'direct_WRF_PBL_tendency';
            case 'khkv_stress'
                V_subgrid = Vd;
                U_subgrid = Ud;
                Subgrid_momentum_source = 'diagnosed_kh_kv_stress';
            otherwise
                error('TC_MBG:SubgridMode','Unknown cfg.calc.Subgrid_momentum_mode: %s',Subgrid_momentum_mode)
        end
        % V component
        Cadd_V(1,:,:) = Vmzeta;
        Cadd_V(2,:,:) = Vmv;
        Cadd_V(3,:,:) = Vezeta;
        Cadd_V(4,:,:) = Vev;
        Cadd_V(5,:,:) = V_subgrid;
        Sum_V      = squeeze(sum(Cadd_V,'omitnan'));
        Residual_V = Vt - Sum_V;
        % U component
        Cadd_U(1,:,:) =-Umr;
        Cadd_U(2,:,:) =-Ueh;
        Cadd_U(3,:,:) = Umv;
        Cadd_U(4,:,:) = Uev;
        Cadd_U(5,:,:) = Uagf_total;
        Cadd_U(6,:,:) = Ueagf;
        Cadd_U(7,:,:) = U_subgrid;
        Sum_U      = squeeze(sum(Cadd_U,'omitnan'));
        Residual_U = Ut - Sum_U;
        clear Cadd_V Cadd_U


        % Save data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
        'R','PHI','dR','dPhi','dr','dt',...
        'Tendency_scheme','Pressure_gradient_unit','Subgrid_momentum_mode','Subgrid_momentum_source',...
        'Uagf_definition','Upressure_definition',...
        'TIME','z','P','u','v',...
        'Vt','Vmzeta','Vmv','Vezeta','Vev','Vd','Vdr','Vdz','Vpbl',...
        'Ut','Umr','Ueh','Umv','Uev','Umagf','Upressure','Uagf_total','Ueagf','Ud','Udh','Udz','Upbl',...
        'V_subgrid','U_subgrid','Sum_V','Residual_V','Sum_U','Residual_U',...
        'lon_TC','lat_TC','slp_TC','swd_TC')
        
        clear R PHI dR dPhi r dr
        clear TIME dt Tendency_scheme Pressure_gradient_unit lon lat z P f u v
        clear Vt Vmzeta Vmv Vezeta Vev Vd Vdr Vdz Vpbl V_subgrid
        clear Ut Umr Ueh Umv Uev Umagf Upressure Uagf_total Ueagf Ud Udh Udz Upbl U_subgrid
        clear Sum_V Residual_V Sum_U Residual_U
        clear lon_TC lat_TC slp_TC swd_TC

    end
end

function [var_u,var_v,has_file,file_t,state_time] = load_mbg_tendency_state(file_name,T_name,TIME,offset,tendency_step_day,R,PHI)

% Select the configured tendency stencil by saved time.  Do not silently use
% the next file when an output is missing or has a different cadence.
prefix = file_name(1:end-length(T_name));
% Cache this small metadata catalogue; reopening every MAT file for each of
% five stencil states would otherwise turn a long case into O(n^2) I/O.
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
    error('TC_MBG:TendencyTime','Unable to locate the current state by its saved timestamp.')
end
target_time = TIME + offset*tendency_step_day;
[time_error,target_index] = min(abs(state_times-target_time));
has_file = ~isempty(target_index) && isfinite(time_error) && time_error<=0.5/86400;
if ~has_file
    file_t = '';
    var_u = [];
    var_v = [];
    state_time = NaN;
    return
end
file_t = fullfile(entries(target_index).folder,entries(target_index).name);

R_t     = load_data(file_t,'R');
PHI_t   = load_data(file_t,'PHI');
state_time = load_data(file_t,'TIME');
var_tu  = load_data(file_t,'um');
var_tv  = load_data(file_t,'vm');

if (sum(abs(R_t-R),'omitnan')+sum(abs(PHI_t-PHI),'omitnan'))>0
    [Rx_t,PHIx_t] = meshgrid(R_t,PHI_t);
    [Rx,PHIx]     = meshgrid(R,PHI);
    var_u = NaN(size(var_tu,1),length(PHI),length(R));
    var_v = NaN(size(var_tv,1),length(PHI),length(R));
    for k = 1:size(var_tu,1)
        var_u(k,:,:) = griddata(Rx_t,PHIx_t,squeeze(var_tu(k,:,:)),Rx,PHIx);
        var_v(k,:,:) = griddata(Rx_t,PHIx_t,squeeze(var_tv(k,:,:)),Rx,PHIx);
    end
else
    var_u = var_tu;
    var_v = var_tv;
end
end

function derivative = three_point_time_derivative(y1,t1,y2,t2,y3,t3,day_to_second)

t1=t1*day_to_second; t2=t2*day_to_second; t3=t3*day_to_second;
assert(t1<t2 && t2<t3,'TC_MBG:TendencyTime','Tendency timestamps must be strictly increasing.')
w1 = (t2-t3)/((t1-t2)*(t1-t3));
w2 = (2*t2-t1-t3)/((t2-t1)*(t2-t3));
w3 = (t2-t1)/((t3-t1)*(t3-t2));
derivative = w1*y1 + w2*y2 + w3*y3;
end

function tf = is_uniform_time_grid(t)

dt = diff(t)*86400;
tf = all(isfinite(dt)) && all(dt>0) && max(abs(dt-dt(1))) <= max(1e-6,1e-8*dt(1));
end
