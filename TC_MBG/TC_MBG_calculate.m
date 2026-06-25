clear
clc

warning off
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
Tendency_frq = cfg.calc.Tendency_frq;
                       % i.e. dt=2*Tendency_frq (minute) or dt=Tendency_frq(BC)
                       % second order accurary useing Tendency_frq=Time_frq

T_beg      = datenum(Time_beg);
T_end      = datenum(Time_end);
T_frq      = Time_frq/60/24;
del_T      = Tendency_frq/60/24;
D_to_S     = 24*60*60;

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
        h = del_T*D_to_S;
        [var_0u ,var_0v ,has_0 ,~       ] = load_mbg_tendency_state(file_name,T_name,TIME, 0,del_T,R,PHI);
        [var_Bu ,var_Bv ,has_B ,~       ] = load_mbg_tendency_state(file_name,T_name,TIME,-1,del_T,R,PHI);
        [var_Fu ,var_Fv ,has_F ,~       ] = load_mbg_tendency_state(file_name,T_name,TIME, 1,del_T,R,PHI);
        [var_B2u,var_B2v,has_B2,~       ] = load_mbg_tendency_state(file_name,T_name,TIME,-2,del_T,R,PHI);
        [var_F2u,var_F2v,has_F2,~       ] = load_mbg_tendency_state(file_name,T_name,TIME, 2,del_T,R,PHI);

        if has_B2 && has_B && has_F && has_F2
            Ut = (-var_F2u + 8*var_Fu - 8*var_Bu + var_B2u)/(12*h);
            Vt = (-var_F2v + 8*var_Fv - 8*var_Bv + var_B2v)/(12*h);
            Tendency_scheme = 'fourth_order_centered';
        elseif has_B && has_F
            Ut = (var_Fu-var_Bu)/(2*h);
            Vt = (var_Fv-var_Bv)/(2*h);
            Tendency_scheme = 'second_order_centered';
        elseif has_0 && has_F && has_F2
            Ut = (-3*var_0u + 4*var_Fu - var_F2u)/(2*h);
            Vt = (-3*var_0v + 4*var_Fv - var_F2v)/(2*h);
            Tendency_scheme = 'second_order_forward';
        elseif has_0 && has_B && has_B2
            Ut = (3*var_0u - 4*var_Bu + var_B2u)/(2*h);
            Vt = (3*var_0v - 4*var_Bv + var_B2v)/(2*h);
            Tendency_scheme = 'second_order_backward';
        elseif has_0 && has_F
            Ut = (var_Fu-var_0u)/h;
            Vt = (var_Fv-var_0v)/h;
            Tendency_scheme = 'first_order_forward';
        elseif has_0 && has_B
            Ut = (var_0u-var_Bu)/h;
            Vt = (var_0v-var_Bv)/h;
            Tendency_scheme = 'first_order_backward';
        else
            disp(['Skip tendency calculation: no neighboring file for ',T_name])
            continue
        end
        dt = h;
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
        Vdr   = 1./((r.^2).*Rm).*dVdR((r.^2).*Rm.*TrpM,dr);
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
        
        % Mean agradient force (Umagf)
        disp(['Calculating... : Umagf'])
        vm    = load_data([file_TN,'.mat'],'vm');
        F     = load_data([file_TN,'.mat'],'F');
        Pm    = load_data([file_TN,'.mat'],'Pm');
        Rm    = load_data([file_TN,'.mat'],'Rm');
        Pm_sample = Pm(~isnan(Pm));
        pressure_scale_to_pa = 1;
        Pressure_gradient_unit = 'Pa';
        if ~isempty(Pm_sample) && nanmean(abs(Pm_sample(:)))<2000
            pressure_scale_to_pa = 100;
            Pressure_gradient_unit = 'converted_hPa_to_Pa';
            Pm = Pm*pressure_scale_to_pa;
        end
        Umagf = (vm.^2)./r + F.*vm - 1./Rm.*dVdR(Pm,dr);
        clear vm F Pm Rm
        
        % Eddy agradient force (Ueagf)
        disp(['Calculating... : Ueagf'])
        vp    = load_data([file_TN,'.mat'],'vp');
        Pp    = load_data([file_TN,'.mat'],'Pp');
        rho   = load_data([file_TN,'.mat'],'rho');
        Pp = Pp*pressure_scale_to_pa;
        Ueagf = (vp.^2)./r - 1./rho.*dVdR(Pp,dr);
        clear vp Pp rho
        
        % Combined mean radial and vertical diffusive tendency (Ud)
        disp(['Calculating... : Ud'])
        Rm    = load_data([file_TN,'.mat'],'Rm');
        TrrM  = load_data([file_TN,'.mat'],'TrrM');
        TppM  = load_data([file_TN,'.mat'],'TppM');
        TrzM  = load_data([file_TN,'.mat'],'TrzM');
        Udh   = 1./(r.*Rm).*dVdR(r.*Rm.*TrrM,dr) - TppM./r;
        Udz   = 1./Rm.*dVdZ(Rm.*TrzM,z);
        Ud    = Udh + Udz;
        clear Rm TrrM TppM TrzM

        % Direct WRF PBL radial tendency (Upbl)
        disp(['Calculating... : Upbl'])
        Upbl  = load_data([file_TN,'.mat'],'UpblM');
        
        
        % Azimuthlly average
        z      = squeeze(nanmean(z,2));
        P      = squeeze(nanmean(P,2));
        u      = squeeze(nanmean(u,2));
        v      = squeeze(nanmean(v,2));
        
        Vt     = squeeze(nanmean(Vt,2));
        Vmzeta = squeeze(nanmean(Vmzeta,2));
        Vmv    = squeeze(nanmean(Vmv,2));
        Vezeta = squeeze(nanmean(Vezeta,2));
        Vev    = squeeze(nanmean(Vev,2));
        Vd     = squeeze(nanmean(Vd,2));
        Vdr    = squeeze(nanmean(Vdr,2));
        Vdz    = squeeze(nanmean(Vdz,2));
        Vpbl   = squeeze(nanmean(Vpbl,2));
        
        Ut     = squeeze(nanmean(Ut,2));
        Umr    = squeeze(nanmean(Umr,2));
        Ueh    = squeeze(nanmean(Ueh,2));
        Umv    = squeeze(nanmean(Umv,2));
        Uev    = squeeze(nanmean(Uev,2));
        Umagf  = squeeze(nanmean(Umagf,2));
        Ueagf  = squeeze(nanmean(Ueagf,2));
        Ud     = squeeze(nanmean(Ud,2));
        Udh    = squeeze(nanmean(Udh,2));
        Udz    = squeeze(nanmean(Udz,2));
        Upbl   = squeeze(nanmean(Upbl,2));
         
 
        % Budget closure diagnostics
        % V component
        Cadd_V(1,:,:) = Vmzeta;
        Cadd_V(2,:,:) = Vmv;
        Cadd_V(3,:,:) = Vezeta;
        Cadd_V(4,:,:) = Vev;
        Cadd_V(5,:,:) = Vpbl;
        Sum_V      = squeeze(nansum(Cadd_V));
        Residual_V = Vt - Sum_V;
        % U component
        Cadd_U(1,:,:) =-Umr;
        Cadd_U(2,:,:) =-Ueh;
        Cadd_U(3,:,:) = Umv;
        Cadd_U(4,:,:) = Uev;
        Cadd_U(5,:,:) = Umagf;
        Cadd_U(6,:,:) = Ueagf;
        Cadd_U(7,:,:) = Upbl;
        Sum_U      = squeeze(nansum(Cadd_U));
        Residual_U = Ut - Sum_U;
        clear Cadd_V Cadd_U


        % Save data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
        'R','PHI','dR','dPhi','dr','dt',...
        'Tendency_scheme','Pressure_gradient_unit',...
        'TIME','z','P','u','v',...
        'Vt','Vmzeta','Vmv','Vezeta','Vev','Vd','Vdr','Vdz','Vpbl',...
        'Ut','Umr','Ueh','Umv','Uev','Umagf','Ueagf','Ud','Udh','Udz','Upbl',...
        'Sum_V','Residual_V','Sum_U','Residual_U',...
        'lon_TC','lat_TC','slp_TC','swd_TC')
        
        clear R PHI dR dPhi r dr
        clear TIME dt Tendency_scheme Pressure_gradient_unit lon lat z P f u v
        clear Vt Vmzeta Vmv Vezeta Vev Vd Vdr Vdz Vpbl
        clear Ut Umr Ueh Umv Uev Umagf Ueagf Ud Udh Udz Upbl
        clear Sum_V Residual_V Sum_U Residual_U
        clear lon_TC lat_TC slp_TC swd_TC

    end
end

function [var_u,var_v,has_file,file_t] = load_mbg_tendency_state(file_name,T_name,TIME,offset,del_T,R,PHI)

if offset==0
    file_t = file_name;
else
    [year_num,month_num,day_num,hour_num,minu_num,seco_num] = date2str(TIME+offset*del_T);
    name_t = [year_num,'-',month_num,'-',day_num,'_',hour_num,':',minu_num,':',seco_num];
    file_t = [file_name(1:end-length(T_name)),name_t];
end

has_file = ~isempty(dir([file_t,'.mat']));
if ~has_file
    var_u = [];
    var_v = [];
    return
end

R_t     = load_data([file_t,'.mat'],'R');
PHI_t   = load_data([file_t,'.mat'],'PHI');
var_tu  = load_data([file_t,'.mat'],'um');
var_tv  = load_data([file_t,'.mat'],'vm');

if (nansum(abs(R_t-R))+nansum(abs(PHI_t-PHI)))>0
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
