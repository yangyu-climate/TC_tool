clear
clc

Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_MBG_config;

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Radius     = cfg.Radius;
dR         = cfg.dR;
dPhi       = cfg.dPhi;
IF_Zfix    = cfg.IF_Zfix;
z_hight    = cfg.z_hight;

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
assert(numel(TC_center_valid)==numel(TC_time),'TC_MBG:TrackQuality','CENTER_VALID must match TIME')
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
        tc_assert_earth_relative_wind([file_name,'_RUBLTEN.nc'],[file_name,'_RVBLTEN.nc'])
        % Basic Variables
        lon   = ncload_2D([file_name,'_lon.nc'] ,'lon');
        lat   = ncload_2D([file_name,'_lat.nc'] ,'lat');
        z     = ncload_3D([file_name,'_z.nc']   ,'z');
        P     = ncload_3D([file_name,'_p.nc']   ,'p');
        % Dynamic Variables
        f     = ncload_2D([file_name,'_f.nc']   ,'f');
        u     = ncload_3D([file_name,'_u.nc']   ,'u');
        v     = ncload_3D([file_name,'_v.nc']   ,'v');
        w     = ncload_3D([file_name,'_w.nc']   ,'w');
        kh    = ncload_3D([file_name,'_kh.nc']  ,'kh');
        kv    = ncload_3D([file_name,'_kv.nc']  ,'kv');
        RUBLTEN = ncload_3D([file_name,'_RUBLTEN.nc'],'RUBLTEN');
        RVBLTEN = ncload_3D([file_name,'_RVBLTEN.nc'],'RVBLTEN');
        avo   = ncload_3D([file_name,'_avo.nc'] ,'avo');
        rho   = ncload_3D([file_name,'_rho.nc'] ,'rho');
        % TC Moving Frame
        u = u - u_TC;
        v = v - v_TC;
        
        disp(['Calculating...'])
        mask  = NaN(size(lon));
        [dist,X,Y] = tc_great_circle_xy(lat,lon,lat_TC,lon_TC);
        x = X;
        y = Y;
        mask(dist<=Radius)=1;

        if IF_Zfix
          fixed_size = [numel(z_hight),size(lon,1),size(lon,2)];
          zS = repmat(reshape(z_hight,[],1,1),1,size(lon,1),size(lon,2));
          PS = NaN(fixed_size); uS = PS; vS = PS; wS = PS;
          khS = PS; kvS = PS; RUBLTENS = PS; RVBLTENS = PS;
          avoS = PS; rhoS = PS;
          for i=1:size(x,1)
            for j = 1:size(y,2) 
              [zq,iq]        = unique_sorted_height(squeeze(z(:,i,j)));
              zS(:,i,j)      = z_hight;
              PS(:,i,j)      = interpolate_height(zq,iq,squeeze(P(:,i,j)),z_hight);
              uS(:,i,j)      = interpolate_height(zq,iq,squeeze(u(:,i,j)),z_hight);
              vS(:,i,j)      = interpolate_height(zq,iq,squeeze(v(:,i,j)),z_hight);
              wS(:,i,j)      = interpolate_height(zq,iq,squeeze(w(:,i,j)),z_hight);
              khS(:,i,j)     = interpolate_height(zq,iq,squeeze(kh(:,i,j)),z_hight);
              kvS(:,i,j)     = interpolate_height(zq,iq,squeeze(kv(:,i,j)),z_hight);
              RUBLTENS(:,i,j)= interpolate_height(zq,iq,squeeze(RUBLTEN(:,i,j)),z_hight);
              RVBLTENS(:,i,j)= interpolate_height(zq,iq,squeeze(RVBLTEN(:,i,j)),z_hight);
              avoS(:,i,j)    = interpolate_height(zq,iq,squeeze(avo(:,i,j)),z_hight);
              rhoS(:,i,j)    = interpolate_height(zq,iq,squeeze(rho(:,i,j)),z_hight);
            end
          end
          z    = zS;
          P    = PS;
          u    = uS;
          v    = vS;
          w    = wS;
          kh   = khS;
          kv   = kvS;
          RUBLTEN = RUBLTENS;
          RVBLTEN = RVBLTENS;
          avo  = avoS;
          rho  = rhoS;
          clear zS  PS  uS  vS  wS  khS  kvS  RUBLTENS RVBLTENS avoS  rhoS
        end
      
        phi = mod(atan2(y,x),2*pi);
        r   = hypot(x,y);

        % Rectangular to Cylindrical
        uc    = u;
        vc    = v;
        [u,v] = VectorTrans_R2C(x,y,u,v);
        [Upbl,Vpbl] = VectorTrans_R2C(x,y,RUBLTEN,RVBLTEN);
        
        [X,Y] = meshgrid(R,PHI);
        lon   = Car2Cly(r,phi,lon,X,Y);
        lat   = Car2Cly(r,phi,lat,X,Y);
        f     = Car2Cly(r,phi,f  ,X,Y);
        output_size = [size(z,1),numel(PHI),numel(R)];
        zS = NaN(output_size); PS = zS; uS = zS; vS = zS; wS = zS;
        khS = zS; kvS = zS; UpblS = zS; VpblS = zS; avoS = zS; rhoS = zS;
        for k=1:size(z,1)
            zS(k,:,:)     = Car2Cly(r,phi,squeeze(z(k,:,:))  ,X,Y);
            PS(k,:,:)     = Car2Cly(r,phi,squeeze(P(k,:,:))  ,X,Y);
            uS(k,:,:)     = Car2Cly(r,phi,squeeze(u(k,:,:))  ,X,Y);
            vS(k,:,:)     = Car2Cly(r,phi,squeeze(v(k,:,:))  ,X,Y);
            wS(k,:,:)     = Car2Cly(r,phi,squeeze(w(k,:,:))  ,X,Y);
            khS(k,:,:)    = Car2Cly(r,phi,squeeze(kh(k,:,:)) ,X,Y); 
            kvS(k,:,:)    = Car2Cly(r,phi,squeeze(kv(k,:,:)) ,X,Y); 
            UpblS(k,:,:)   = Car2Cly(r,phi,squeeze(Upbl(k,:,:)),X,Y);
            VpblS(k,:,:)   = Car2Cly(r,phi,squeeze(Vpbl(k,:,:)),X,Y);
            avoS(k,:,:)   = Car2Cly(r,phi,squeeze(avo(k,:,:)),X,Y); 
            rhoS(k,:,:)   = Car2Cly(r,phi,squeeze(rho(k,:,:)),X,Y);
        end
        
        z    = zS;
        P    = PS;
        u    = uS;
        v    = vS;
        w    = wS;
        kh   = khS;
        kv   = kvS;
        Upbl = UpblS;
        Vpbl = VpblS;
        avo  = avoS;
        rho  = rhoS;
        clear  zS  PS  uS  vS  wS  khS kvS  UpblS VpblS avoS  rhoS
        
        % Save Data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
            'R','PHI','dR','dPhi',...
            'TIME','lon','lat','z','P',...
            'f','u','v','w','kh','kv','Upbl','Vpbl','avo','rho',...
            'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC','center_motion_method','TC_center_valid')
        clear TIME lon lat x y X Y z P 
        clear f u v w kh kv Upbl Vpbl RUBLTEN RVBLTEN rho avo

        end
    end
end

function [zq,iq] = unique_sorted_height(z)
valid = isfinite(z);
z = z(valid);
original_index = find(valid);
[zq,order] = sort(z);
original_index = original_index(order);
[zq,unique_index] = unique(zq,'stable');
iq = original_index(unique_index);
end

function value = interpolate_height(zq,iq,source,target)
value = NaN(size(target));
if numel(zq) < 2
    return
end
source = source(iq);
valid = isfinite(source);
if nnz(valid) >= 2
    value = interp1(zq(valid),source(valid),target,'linear',NaN);
end
end
