clear
clc

Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_Rfield_config;

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Radius     = cfg.Radius;
resolution = cfg.resolution;
Track_file = cfg.Track_file;
Data_dir   = cfg.Input_dir;
Head_nam   = cfg.Head_nam;
Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/MVCT'];
mkdir(Save_dir)

T_beg      = datenum(Time_beg);
T_end      = datenum(Time_end);
T_frq      = Time_frq/60/24;
dR         = resolution;
x          = [-ceil(Radius/dR)*dR:dR:ceil(Radius/dR)*dR];
y          = [-ceil(Radius/dR)*dR:dR:ceil(Radius/dR)*dR];
[x,y]      = meshgrid(x,y);

TC_time    = load_data(Track_file,'TIME');
TC_lon     = load_data(Track_file,'LON');
TC_lat     = load_data(Track_file,'LAT');
TC_slp     = load_data(Track_file,'SLP');
TC_swd     = load_data(Track_file,'SWD');
track_quality = load(Track_file,'CENTER_VALID','CENTER_HELD');
TC_center_valid = logical(track_quality.CENTER_VALID);
assert(numel(TC_center_valid)==numel(TC_time),'TC_Rfield:TrackQuality','CENTER_VALID must match TIME')
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
        lon_TC = TC_lon(TC_loc);
        lat_TC = TC_lat(TC_loc);
        slp_TC = TC_slp(TC_loc);
        swd_TC = TC_swd(TC_loc);
        u_TC   = TC_U(TC_loc);
        v_TC   = TC_V(TC_loc);
        disp([' '])	
        disp(['Date: ',T_name])	
        disp(['TC center: ',num2str(lon_TC),'E ',num2str(lat_TC),'N'])
        disp(['SLP: ',num2str(slp_TC),'hPa    Max Wind: ',num2str(swd_TC),'m/s'])
        disp(['TC Moving Speed: U ',num2str(u_TC),'m/s  V ',num2str(v_TC),'m/s'])
        
        disp(['loading...'])	
        file_name = filename.name(1:end-8);
        file_name = [Data_dir,'/',file_name];
        tc_assert_earth_relative_wind([file_name,'_u.nc'],[file_name,'_v.nc'])
        % Basic Variables
        lon        = ncload_2D([file_name,'_lon.nc'] ,'lon');
        lat        = ncload_2D([file_name,'_lat.nc'] ,'lat');
        z          = ncload_3D([file_name,'_z.nc']   ,'z');
        P          = ncload_3D([file_name,'_p.nc']   ,'p');
        pblh       = ncload_2D([file_name,'_pblh.nc'],'pblh');
        % Dynamic Variables
        avo        = ncload_3D([file_name,'_avo.nc'] ,'avo');
        pvo        = ncload_3D([file_name,'_pvo.nc'] ,'pvo');
        f          = ncload_2D([file_name,'_f.nc']   ,'f');
        u          = ncload_3D([file_name,'_u.nc']   ,'u');
        v          = ncload_3D([file_name,'_v.nc']   ,'v');
        w          = ncload_3D([file_name,'_w.nc']   ,'w');
        rho        = ncload_3D([file_name,'_rho.nc'] ,'rho');
        U10        = ncload_3D([file_name,'_U10.nc'] ,'U10');
        V10        = ncload_3D([file_name,'_V10.nc'] ,'V10');
        % Surface Heat Flux
        GLW        = ncload_2D([file_name,'_glw.nc'] ,'glw');
        GSW        = ncload_2D([file_name,'_gsw.nc'] ,'gsw');
        SHF        = ncload_2D([file_name,'_hfx.nc'] ,'hfx');
        LHF        = ncload_2D([file_name,'_lh.nc']  ,'lh');
        SLP        = ncload_2D([file_name,'_slp.nc'] ,'slp');
        SST        = ncload_2D([file_name,'_sst.nc'] ,'sst');
        % Themodynamic Variables
        H_DIABATIC = ncload_3D([file_name,'_H_DIABATIC.nc'],'H_DIABATIC');
        tk         = ncload_3D([file_name,'_tk.nc']        ,'tk');
        rh         = ncload_3D([file_name,'_rh.nc']        ,'rh');
        theta      = ncload_3D([file_name,'_theta.nc']     ,'theta');
        thetaE     = ncload_3D([file_name,'_thetaE.nc']    ,'thetaE');
        DethDz     = dVdZ(thetaE,z);
        % Water Phase Variables
        QVAPOR     = ncload_3D([file_name,'_QVAPOR.nc'],'QVAPOR');
        QCLOUD     = ncload_3D([file_name,'_QCLOUD.nc'],'QCLOUD');
        QGRAUP     = ncload_3D([file_name,'_QGRAUP.nc'],'QGRAUP');
        QRAIN      = ncload_3D([file_name,'_QRAIN.nc'] ,'QRAIN');
        QSNOW      = ncload_3D([file_name,'_QSNOW.nc'] ,'QSNOW');
        QICE       = ncload_3D([file_name,'_QICE.nc']  ,'QICE');
      
        Qv         = QVAPOR;
        Qc         = QCLOUD;
        Qr         = QRAIN;
        Qi         = QICE;
        Qs         = QSNOW;
        Qg         = QGRAUP;
        QW         = (QCLOUD + QRAIN);
        QI         = (QICE + QSNOW + QGRAUP);
        clear QVAPOR QCLOUD QGRAUP QRAIN QSNOW QICE

        rvo = avo - reshape(f,1,size(f,1),size(f,2));

        disp(['Calculating...'])
        mask  = NaN*ones(size(lon));
        [dist,X,Y] = tc_great_circle_xy(lat,lon,lat_TC,lon_TC);
        mask(dist<=(Radius+dR)) = 1;
        % Source geometry is shared by every field and vertical level. Reuse
        % one triangulation instead of rebuilding it for each griddata call.
        Fxy = scatteredInterpolant(X(:),Y(:),zeros(numel(X),1),'linear','none');

        lon  = remap_xy(Fxy,lon .*mask,x,y);
        lat  = remap_xy(Fxy,lat .*mask,x,y);
        f    = remap_xy(Fxy,f   .*mask,x,y);
        pblh = remap_xy(Fxy,pblh.*mask,x,y);
        GLW  = remap_xy(Fxy,GLW .*mask,x,y);
        GSW  = remap_xy(Fxy,GSW .*mask,x,y);
        LHF  = remap_xy(Fxy,LHF .*mask,x,y);
        SHF  = remap_xy(Fxy,SHF .*mask,x,y);
        SLP  = remap_xy(Fxy,SLP .*mask,x,y);
        SST  = remap_xy(Fxy,SST .*mask,x,y);
        U10  = remap_xy(Fxy,U10 .*mask,x,y);
        V10  = remap_xy(Fxy,V10 .*mask,x,y);
        output_size = [size(z,1),size(x,1),size(x,2)];
        zS = NaN(output_size); PS = zS; uS = zS; vS = zS; wS = zS;
        avoS = zS; pvoS = zS; rvoS = zS; rhoS = zS; thetaS = zS;
        thetaES = zS; DethDzS = zS; H_DIABATICS = zS;
        QvS = zS; QcS = zS; QrS = zS; QiS = zS; QsS = zS; QgS = zS;
        QWS = zS; QIS = zS;
        for k = 1:size(z,1)
            zS(k,:,:)          = remap_xy(Fxy,squeeze(z(k,:,:)),x,y);
            PS(k,:,:)          = remap_xy(Fxy,squeeze(P(k,:,:)),x,y);
            uS(k,:,:)          = remap_xy(Fxy,squeeze(u(k,:,:)).*mask,x,y);
            vS(k,:,:)          = remap_xy(Fxy,squeeze(v(k,:,:)).*mask,x,y);
            wS(k,:,:)          = remap_xy(Fxy,squeeze(w(k,:,:)).*mask,x,y);
            avoS(k,:,:)        = remap_xy(Fxy,squeeze(avo(k,:,:)).*mask,x,y);
            pvoS(k,:,:)        = remap_xy(Fxy,squeeze(pvo(k,:,:)).*mask,x,y);
            rvoS(k,:,:)        = remap_xy(Fxy,squeeze(rvo(k,:,:)).*mask,x,y);
            rhoS(k,:,:)        = remap_xy(Fxy,squeeze(rho(k,:,:)).*mask,x,y);
            thetaS(k,:,:)      = remap_xy(Fxy,squeeze(theta(k,:,:)).*mask,x,y);
            thetaES(k,:,:)     = remap_xy(Fxy,squeeze(thetaE(k,:,:)).*mask,x,y);
            DethDzS(k,:,:)     = remap_xy(Fxy,squeeze(DethDz(k,:,:)).*mask,x,y);
            H_DIABATICS(k,:,:) = remap_xy(Fxy,squeeze(H_DIABATIC(k,:,:)).*mask,x,y);
            QvS(k,:,:)         = remap_xy(Fxy,squeeze(Qv(k,:,:)).*mask,x,y);
            QcS(k,:,:)         = remap_xy(Fxy,squeeze(Qc(k,:,:)).*mask,x,y);
            QrS(k,:,:)         = remap_xy(Fxy,squeeze(Qr(k,:,:)).*mask,x,y);
            QiS(k,:,:)         = remap_xy(Fxy,squeeze(Qi(k,:,:)).*mask,x,y);
            QsS(k,:,:)         = remap_xy(Fxy,squeeze(Qs(k,:,:)).*mask,x,y);
            QgS(k,:,:)         = remap_xy(Fxy,squeeze(Qg(k,:,:)).*mask,x,y);
            QWS(k,:,:)         = remap_xy(Fxy,squeeze(QW(k,:,:)).*mask,x,y);
            QIS(k,:,:)         = remap_xy(Fxy,squeeze(QI(k,:,:)).*mask,x,y);
        end
        z              = zS;
        P              = PS;
        u              = uS;
        v              = vS;
        w              = wS;
        avo            = avoS;
        pvo            = pvoS;
        rvo            = rvoS;
        rho            = rhoS;
        theta          = thetaS;
        thetaE         = thetaES;
        DethDz         = DethDzS;
        H_DIABATIC     = H_DIABATICS;
        Qv             = QvS;
        Qc             = QcS;
        Qr             = QrS;
        Qi             = QiS;
        Qs             = QsS;
        Qg             = QgS;
        QW             = QWS;
        QI             = QIS;
        clear zS PS uS vS wS avoS pvoS rvoS rhoS 
        clear thetaS thetaES DethDzS H_DIABATICS 
        clear QvS QcS QrS QiS QsS QgS QWS QIS

        % Cartesian Coordinate
        uc  = u;
        vc  = v;
        % TC Moving Frame
        u   = u - u_TC;
        v   = v - v_TC;
        % Rectangular to Cylindrical
        [u,v] = VectorTrans_R2C(x,y,u,v);
        
        r     = hypot(x,y)*1000;
        % v is [level,y,x], while r and f are horizontal [y,x] fields.
        % Put the horizontal fields on singleton level dimensions so the
        % absolute angular momentum is evaluated at every vertical level.
        r3    = reshape(r,1,size(r,1),size(r,2));
        f3    = reshape(f,1,size(f,1),size(f,2));
        M     = r3.*v + 0.5*f3.*(r3.^2);
        r     = r/1000;

        % Save Data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
            'Radius','dR',...
            'TIME','lon','lat',...
            'x','y','z','r','P',...
            'U10','V10','SLP','pblh',...
            'GLW','GSW','LHF','SHF','SST',...
            'H_DIABATIC','theta','thetaE','DethDz',...
            'Qv','Qc','Qr','Qi','Qs','Qg','QW','QI',...
            'rho','uc','vc','w','f',...
            'u','v','M','avo','pvo','rvo',...
            'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC','center_motion_method','TC_center_valid')

        clear TIME lon lat 
        clear X Y z P
        clear U10 V10 SLP pblh 
        clear GLW GSW LHF SHF SST
        clear rho uc vc w
        clear u v M avo pvo rvo
        clear H_DIABATIC theta thetaE DethDz
        clear Qv Qc Qr Qi Qs Qg QW QI

        end
    end
end

function output = remap_xy(interpolant,values,xq,yq)
interpolant.Values = values(:);
output = interpolant(xq,yq);
end
