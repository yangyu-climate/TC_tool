clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_Rfield_config;

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Radius     = cfg.Radius;
resolution = cfg.resolution;
rough_dist = cfg.rough_dist;
rough_reso = cfg.rough_reso;
TC_smooth_hours  = cfg.TC_smooth_hours;
TC_smooth_pass   = cfg.TC_smooth_pass;
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
TW_lon     = load_data(Track_file,'LON_W');
TW_lat     = load_data(Track_file,'LAT_W');
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

        for k=1:size(z,1)
        rvo(k,:,:) = squeeze(avo(k,:,:))-f;
        end

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
        mask(dist<=(Radius+dR)) = 1;

        if rough_dist
          lon  = interp2(X,Y,lon .*mask,x,y);
          lat  = interp2(X,Y,lat .*mask,x,y);
          f    = interp2(X,Y,f   .*mask,x,y);
          pblh = interp2(X,Y,pblh.*mask,x,y);
          GLW  = interp2(X,Y,GLW .*mask,x,y);
          GSW  = interp2(X,Y,GSW .*mask,x,y);
          LHF  = interp2(X,Y,LHF .*mask,x,y);
          SHF  = interp2(X,Y,SHF .*mask,x,y);
          SLP  = interp2(X,Y,SLP .*mask,x,y);
          SST  = interp2(X,Y,SST .*mask,x,y);
          U10  = interp2(X,Y,U10 .*mask,x,y);
          V10  = interp2(X,Y,V10 .*mask,x,y);
        else
          lon  = griddata(X,Y,lon .*mask,x,y);
          lat  = griddata(X,Y,lat .*mask,x,y);
          f    = griddata(X,Y,f   .*mask,x,y);
          pblh = griddata(X,Y,pblh.*mask,x,y);
          GLW  = griddata(X,Y,GLW .*mask,x,y);
          GSW  = griddata(X,Y,GSW .*mask,x,y);
          LHF  = griddata(X,Y,LHF .*mask,x,y);
          SHF  = griddata(X,Y,SHF .*mask,x,y);
          SLP  = griddata(X,Y,SLP .*mask,x,y);
          SST  = griddata(X,Y,SST .*mask,x,y);
          U10  = griddata(X,Y,U10 .*mask,x,y);
          V10  = griddata(X,Y,V10 .*mask,x,y);
        end
        for k = 1:size(z,1)
          if rough_dist
            zS(k,:,:)          = interp2(X,Y,squeeze(z(k,:,:)),x,y); 
            PS(k,:,:)          = interp2(X,Y,squeeze(P(k,:,:)),x,y); 
            uS(k,:,:)          = interp2(X,Y,squeeze(u(k,:,:))         .*mask,x,y); 
            vS(k,:,:)          = interp2(X,Y,squeeze(v(k,:,:))         .*mask,x,y); 
            wS(k,:,:)          = interp2(X,Y,squeeze(w(k,:,:))         .*mask,x,y); 
            avoS(k,:,:)        = interp2(X,Y,squeeze(avo(k,:,:))       .*mask,x,y); 
            pvoS(k,:,:)        = interp2(X,Y,squeeze(pvo(k,:,:))       .*mask,x,y); 
            rvoS(k,:,:)        = interp2(X,Y,squeeze(rvo(k,:,:))       .*mask,x,y); 
            rhoS(k,:,:)        = interp2(X,Y,squeeze(rho(k,:,:))       .*mask,x,y);
            thetaS(k,:,:)      = interp2(X,Y,squeeze(theta(k,:,:))     .*mask,x,y);
            thetaES(k,:,:)     = interp2(X,Y,squeeze(thetaE(k,:,:))    .*mask,x,y);
            DethDzS(k,:,:)     = interp2(X,Y,squeeze(DethDz(k,:,:))    .*mask,x,y);
            H_DIABATICS(k,:,:) = interp2(X,Y,squeeze(H_DIABATIC(k,:,:)).*mask,x,y); 
            QvS(k,:,:)         = interp2(X,Y,squeeze(Qv(k,:,:))        .*mask,x,y); 
            QcS(k,:,:)         = interp2(X,Y,squeeze(Qc(k,:,:))        .*mask,x,y); 
            QrS(k,:,:)         = interp2(X,Y,squeeze(Qr(k,:,:))        .*mask,x,y); 
            QiS(k,:,:)         = interp2(X,Y,squeeze(Qi(k,:,:))        .*mask,x,y); 
            QsS(k,:,:)         = interp2(X,Y,squeeze(Qs(k,:,:))        .*mask,x,y); 
            QgS(k,:,:)         = interp2(X,Y,squeeze(Qg(k,:,:))        .*mask,x,y); 
            QWS(k,:,:)         = interp2(X,Y,squeeze(QW(k,:,:))        .*mask,x,y);
            QIS(k,:,:)         = interp2(X,Y,squeeze(QI(k,:,:))        .*mask,x,y);
          else 
            zS(k,:,:)          = griddata(X,Y,squeeze(z(k,:,:)),x,y); 
            PS(k,:,:)          = griddata(X,Y,squeeze(P(k,:,:)),x,y); 
            uS(k,:,:)          = griddata(X,Y,squeeze(u(k,:,:))         .*mask,x,y); 
            vS(k,:,:)          = griddata(X,Y,squeeze(v(k,:,:))         .*mask,x,y); 
            wS(k,:,:)          = griddata(X,Y,squeeze(w(k,:,:))         .*mask,x,y);
            avoS(k,:,:)        = griddata(X,Y,squeeze(avo(k,:,:))       .*mask,x,y); 
            pvoS(k,:,:)        = griddata(X,Y,squeeze(pvo(k,:,:))       .*mask,x,y); 
            rvoS(k,:,:)        = griddata(X,Y,squeeze(rvo(k,:,:))       .*mask,x,y); 
            rhoS(k,:,:)        = griddata(X,Y,squeeze(rho(k,:,:))       .*mask,x,y);
            thetaS(k,:,:)      = griddata(X,Y,squeeze(theta(k,:,:))     .*mask,x,y);
            thetaES(k,:,:)     = griddata(X,Y,squeeze(thetaE(k,:,:))    .*mask,x,y);
            DethDzS(k,:,:)     = griddata(X,Y,squeeze(DethDz(k,:,:))    .*mask,x,y);
            H_DIABATICS(k,:,:) = griddata(X,Y,squeeze(H_DIABATIC(k,:,:)).*mask,x,y); 
            QvS(k,:,:)         = griddata(X,Y,squeeze(Qv(k,:,:))        .*mask,x,y); 
            QcS(k,:,:)         = griddata(X,Y,squeeze(Qc(k,:,:))        .*mask,x,y); 
            QrS(k,:,:)         = griddata(X,Y,squeeze(Qr(k,:,:))        .*mask,x,y); 
            QiS(k,:,:)         = griddata(X,Y,squeeze(Qi(k,:,:))        .*mask,x,y); 
            QsS(k,:,:)         = griddata(X,Y,squeeze(Qs(k,:,:))        .*mask,x,y); 
            QgS(k,:,:)         = griddata(X,Y,squeeze(Qg(k,:,:))        .*mask,x,y); 
            QWS(k,:,:)         = griddata(X,Y,squeeze(QW(k,:,:))        .*mask,x,y);
            QIS(k,:,:)         = griddata(X,Y,squeeze(QI(k,:,:))        .*mask,x,y);
          end
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
        
        r     = sqrt(x.^2+y.^2)*1000;
        for k = 1:size(z,1)
        M(k,:,:) = r.*squeeze(v(k,:,:)) + 0.5*f.*(r.^2);
        end
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
            'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC')

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
