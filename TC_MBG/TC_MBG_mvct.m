clear
clc

warning off
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
rough_dist = cfg.rough_dist;
rough_reso = cfg.rough_reso;
TC_smooth_hours  = cfg.TC_smooth_hours;
TC_smooth_pass   = cfg.TC_smooth_pass;
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
TW_lon    = load_data(Track_file,'LON_W');
TW_lat    = load_data(Track_file,'LAT_W');

for num=1:length(TC_time)
    if num==1||num==length(TC_time)
        TC_U(num) = 0;
        TC_V(num) = 0;
    else
        lat_mid = 0.5*(TW_lat(num+1)+TW_lat(num-1));
        TC_U(num) = (TW_lon(num+1)-TW_lon(num-1))...
                   /(TC_time(num+1)-TC_time(num-1))...
                   *111.2*cos(lat_mid*pi/180)*1000/24/60/60;
        TC_V(num) = (TW_lat(num+1)-TW_lat(num-1))...
                   /(TC_time(num+1)-TC_time(num-1))...
                   *111.2*1000/24/60/60;
    end
end
TC_smooth_window = max(1,2*floor((TC_smooth_hours*60/Time_frq)/2)+1);
for smoothN = 1:TC_smooth_pass
    TC_U = running_mean_1D(TC_U,TC_smooth_window);
    TC_V = running_mean_1D(TC_V,TC_smooth_window);
end

for T = T_beg:T_frq:T_end
    TIME                            = T;
    [year,month,day,hour,minu,seco] = date2num(TIME);
    [year_num,month_num,day_num,...
     hour_num,minu_num,seco_num]    = date2str(TIME);
    T_name    = [year_num,'-',month_num,'-',day_num,'_',...
                 hour_num,':',minu_num,':',seco_num];
    file_name = [Head_nam,'*',T_name,'*_time.nc'];
    filename  = dir([Data_dir,'/',file_name]);
    if ~isempty(filename)
        TC_loc = find(TC_time==TIME);
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
        dist  = NaN*ones(size(lon));
        mask  = NaN*ones(size(lon));
        index = find(lon==lon_TC&lat==lat_TC);
        if ~isempty(index)
        [x1,x2] = ind2sub(size(mask),index);
        else
        rough_dist = 0;
        end
        if rough_dist
          disty   = ((1:size(dist,1)) - x1)*rough_reso;
          distx   = ((1:size(dist,2)) - x2)*rough_reso;
          [X,Y]   = meshgrid(distx,disty);
          dist    = sqrt(X.^2+Y.^2);
          clear distx disty x1 x2
        else
          for i = 1:size(mask,1)
            for j = 1:size(mask,2)
              dist(i,j) = distbear([lat(i,j) lat_TC],[lon(i,j) lon_TC],'wgs84')/1000;
              X(i,j)    = distbear([lat_TC   lat_TC],[lon(i,j) lon_TC],'wgs84')/1000*sign(lon(i,j)-lon_TC);
              Y(i,j)    = distbear([lat(i,j) lat_TC],[lon_TC   lon_TC],'wgs84')/1000*sign(lat(i,j)-lat_TC);
            end
          end
        end
        x = X;
        y = Y;
        mask(find(dist<=Radius))=1;

        if IF_Zfix
          for i=1:size(x,1)
            for j = 1:size(y,2) 
              zS(:,i,j)     = z_hight; 
              PS(:,i,j)     = interp1(squeeze(z(:,i,j)),squeeze(P(:,i,j))   ,z_hight); 
              uS(:,i,j)     = interp1(squeeze(z(:,i,j)),squeeze(u(:,i,j))   ,z_hight); 
              vS(:,i,j)     = interp1(squeeze(z(:,i,j)),squeeze(v(:,i,j))   ,z_hight); 
              wS(:,i,j)     = interp1(squeeze(z(:,i,j)),squeeze(w(:,i,j))   ,z_hight); 
              khS(:,i,j)    = interp1(squeeze(z(:,i,j)),squeeze(kh(:,i,j))  ,z_hight);
              kvS(:,i,j)    = interp1(squeeze(z(:,i,j)),squeeze(kv(:,i,j))  ,z_hight); 
              RUBLTENS(:,i,j)= interp1(squeeze(z(:,i,j)),squeeze(RUBLTEN(:,i,j)),z_hight);
              RVBLTENS(:,i,j)= interp1(squeeze(z(:,i,j)),squeeze(RVBLTEN(:,i,j)),z_hight);
              avoS(:,i,j)   = interp1(squeeze(z(:,i,j)),squeeze(avo(:,i,j)) ,z_hight); 
              rhoS(:,i,j)   = interp1(squeeze(z(:,i,j)),squeeze(rho(:,i,j)) ,z_hight);
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
      
        for i=1:size(x,1)
          for j=1:size(x,2)
            if x(i,j)~=0||y(i,j)~=0
              phi(i,j) = get_angle(x(i,j),y(i,j))/180*pi;
              r(i,j)   = sqrt(x(i,j)^2+y(i,j)^2);
            else
              phi(i,j)     = 0;
              r(i,j)       = 0;
            end
          end 
        end

        % Rectangular to Cylindrical
        uc    = u;
        vc    = v;
        [u,v] = VectorTrans_R2C(x,y,u,v);
        [Upbl,Vpbl] = VectorTrans_R2C(x,y,RUBLTEN,RVBLTEN);
        
        [X,Y] = meshgrid(R,PHI);
        lon   = Car2Cly(r,phi,lon,X,Y);
        lat   = Car2Cly(r,phi,lat,X,Y);
        f     = Car2Cly(r,phi,f  ,X,Y);
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
            'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC')
        clear TIME lon lat x y X Y z P 
        clear f u v w kh kv Upbl Vpbl RUBLTEN RVBLTEN rho avo

        end
    end
end
