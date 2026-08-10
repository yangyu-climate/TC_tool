clear
clc

Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_KEBG_config;

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Radius     = cfg.Radius;
dR         = cfg.dR;
dPhi       = cfg.dPhi;
Kday_to_Ks       = cfg.Kday_to_Ks;

PHI        = 0:dPhi:2*pi-dPhi;
R          = 0:dR:Radius;

Track_file = cfg.Track_file;
Data_dir   = cfg.Input_dir;
Head_nam   = cfg.Head_nam;
Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/Data'];
mkdir(Save_dir)

T_beg      = datenum(Time_beg);
T_end      = datenum(Time_end);
T_frq      = Time_frq/60/24;

TC_time   = load_data(Track_file,'TIME');
TC_lon    = load_data(Track_file,'LON');
TC_lat    = load_data(Track_file,'LAT');
TC_slp    = load_data(Track_file,'SLP');
TC_swd    = load_data(Track_file,'SWD');
track_quality = load(Track_file,'CENTER_VALID','CENTER_HELD');
TC_center_valid = logical(track_quality.CENTER_VALID);
assert(numel(TC_center_valid)==numel(TC_time),'TC_KEBG:TrackQuality','CENTER_VALID must match TIME')
% The storm-relative velocity must be the derivative of the exact track used
% as the moving cylindrical origin; no independent wind track or smoothing.
[TC_U,TC_V] = tc_track_motion(TC_time,TC_lat,TC_lon,TC_center_valid);
TC_diagnostic_valid = TC_center_valid & isfinite(TC_U) & isfinite(TC_V);
center_motion_method = 'track_geodesic_finite_difference';

for T = T_beg:T_frq:T_end
    TIME                            = T;
    [year,month,day,hour,minu,seco] = date2num(TIME);
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num]    = date2str(TIME);
    T_name    = tc_time_name(TIME);
    [filename,~] = tc_find_time_file(Data_dir,Head_nam,TIME,'*_time.nc');
    if ~isempty(filename)
        TC_loc = tc_match_track_time(TC_time,TIME,0.5*T_frq,TC_diagnostic_valid);
        if ~isempty(TC_loc)
        lon_track = TC_lon(TC_loc);
        lat_track = TC_lat(TC_loc);
        lon_TC = lon_track;
        lat_TC = lat_track;
        slp_track = TC_slp(TC_loc);
        swd_track = TC_swd(TC_loc);
        u_TC   = TC_U(TC_loc);
        v_TC   = TC_V(TC_loc);
        disp([' '])
        disp(['Date: ',T_name])
        disp(['TC center: ',num2str(lon_TC),'E ',num2str(lat_TC),'N'])
        disp(['Track SLP: ',num2str(slp_track),'hPa    Max Wind: ',num2str(swd_track),'m/s'])
        disp(['TC Moving Speed: U ',num2str(u_TC),'m/s  V ',num2str(v_TC),'m/s'])

        disp(['loading...'])
        file_name = filename.name(1:end-8);
        file_name = [Data_dir,'/',file_name];
        tc_assert_earth_relative_wind([file_name,'_u.nc'],[file_name,'_v.nc'])

        lon        = ncload_2D([file_name,'_lon.nc']       ,'lon');
        lat        = ncload_2D([file_name,'_lat.nc']       ,'lat');
        P          = ncload_3D([file_name,'_p.nc']         ,'p');
        omega      = ncload_3D([file_name,'_omega.nc']     ,'omega');
        u          = ncload_3D([file_name,'_u.nc']         ,'u');
        v          = ncload_3D([file_name,'_v.nc']         ,'v');
        tk         = ncload_3D([file_name,'_tk.nc']        ,'tk');
        theta      = ncload_3D([file_name,'_theta.nc']     ,'theta');
        H_MICRO    = load_optional_3D([file_name,'_H_DIABATIC.nc'],'H_DIABATIC',theta)*Kday_to_Ks;
        H_RAD      = load_optional_3D([file_name,'_RTHRATEN.nc'],'RTHRATEN',H_MICRO)*Kday_to_Ks;
        H_PBL      = load_optional_3D([file_name,'_RTHBLTEN.nc'],'RTHBLTEN',H_MICRO)*Kday_to_Ks;
        H_CU       = load_optional_3D([file_name,'_RTHCUTEN.nc'],'RTHCUTEN',H_MICRO)*Kday_to_Ks;
        H_SHALLOW  = load_optional_3D([file_name,'_RTHSHTEN.nc'],'RTHSHTEN',H_MICRO)*Kday_to_Ks;
        % All retained heating components are potential-temperature
        % tendencies (K s-1).  Conversion to temperature heating occurs
        % only after interpolation to a common pressure surface.
        H_DIABATIC = H_MICRO + H_RAD + H_PBL + H_CU + H_SHALLOW;
        heating_components_available = struct('micro',true,...
            'radiation',~isempty(dir([file_name,'_RTHRATEN.nc'])),...
            'pbl',~isempty(dir([file_name,'_RTHBLTEN.nc'])),...
            'cumulus',~isempty(dir([file_name,'_RTHCUTEN.nc'])),...
            'shallow_convection',~isempty(dir([file_name,'_RTHSHTEN.nc'])));
        heating_components_available.micro = ~isempty(dir([file_name,'_H_DIABATIC.nc']));
        if ~any(struct2array(heating_components_available))
            warning('TC_KEBG:NoHeatingTerms',...
                'No diabatic-heating tendencies were exported for %s; KEBG heating pathways are zero.',file_name)
        end

        u = u - u_TC;
        v = v - v_TC;

        % The supplied track is the sole cylindrical origin. This guarantees
        % that the centre and the track-derived translational velocity match.
        lon_TC = lon_track;
        lat_TC = lat_track;
        center_slp = slp_track;
        disp(['Calculating...'])
        % Exact spherical distance and initial bearing from the instantaneous
        % SLP centre.  This replaces the legacy fixed-3-km grid approximation.
        [dist,X,Y] = tc_great_circle_xy(lat,lon,lat_TC,lon_TC);
        mask  = NaN(size(lon));
        x = X;
        y = Y;
        mask(dist<=Radius) = 1;
        phi = mod(atan2(y,x),2*pi);
        r   = hypot(x,y);

        [u,v] = VectorTrans_R2C(x,y,u,v);

        [X,Y] = meshgrid(R,PHI);
        lon   = Car2Cly(r,phi,lon,X,Y);
        lat   = Car2Cly(r,phi,lat,X,Y);
        output_size = [size(P,1),numel(PHI),numel(R)];
        PS = NaN(output_size); omegaS = PS; uS = PS; vS = PS;
        tkS = PS; thetaS = PS; H_DIABATICS = PS;
        for k=1:size(P,1)
            PS(k,:,:)          = Car2Cly(r,phi,squeeze(P(k,:,:)).*mask,X,Y);
            omegaS(k,:,:)      = Car2Cly(r,phi,squeeze(omega(k,:,:)).*mask,X,Y);
            uS(k,:,:)          = Car2Cly(r,phi,squeeze(u(k,:,:)).*mask,X,Y);
            vS(k,:,:)          = Car2Cly(r,phi,squeeze(v(k,:,:)).*mask,X,Y);
            tkS(k,:,:)         = Car2Cly(r,phi,squeeze(tk(k,:,:)).*mask,X,Y);
            thetaS(k,:,:)      = Car2Cly(r,phi,squeeze(theta(k,:,:)).*mask,X,Y);
            H_DIABATICS(k,:,:) = Car2Cly(r,phi,squeeze(H_DIABATIC(k,:,:)).*mask,X,Y);
        end

        P          = PS;
        omega      = omegaS;
        u          = uS;
        v          = vS;
        tk         = tkS;
        theta      = thetaS;
        H_DIABATIC = H_DIABATICS;
        clear PS omegaS uS vS tkS thetaS H_DIABATICS

        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
            'R','PHI','dR','dPhi',...
            'TIME','lon','lat','P','omega',...
            'u','v','tk','theta','H_DIABATIC',...
            'lon_TC','lat_TC','lon_track','lat_track','center_slp','slp_track','swd_track','u_TC','v_TC',...
            'center_motion_method','heating_components_available','TC_center_valid')
        clear TIME lon lat x y X Y P omega
        clear u v tk theta H_DIABATIC H_MICRO H_RAD H_PBL H_CU H_SHALLOW

        end
    end
end
