clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_PVBG_config;

Time_beg   = cfg.Time_beg;
Time_end   = cfg.Time_end;
Time_frq   = cfg.Time_frq;
Radius     = cfg.Radius;
dR         = cfg.dR;
dPhi       = cfg.dPhi;
rough_dist = cfg.rough_dist;
rough_reso = cfg.rough_reso;
TC_smooth_hours = cfg.TC_smooth_hours;
TC_smooth_pass  = cfg.TC_smooth_pass;
Kday_to_Ks      = cfg.Kday_to_Ks;
IF_Zfix    = cfg.IF_Zfix;
z_hight    = cfg.z_hight;
z_fix      = z_hight(:);

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

TC_time = load_data(Track_file,'TIME');
TC_lon  = load_data(Track_file,'LON');
TC_lat  = load_data(Track_file,'LAT');
TC_slp  = load_data(Track_file,'SLP');
TC_swd  = load_data(Track_file,'SWD');
TW_lon  = load_data(Track_file,'LON_W');
TW_lat  = load_data(Track_file,'LAT_W');

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
    TIME = T;
    [year_num,month_num,day_num,hour_num,minu_num,seco_num] = date2str(TIME);
    T_name = [year_num,'-',month_num,'-',day_num,'_',...
              hour_num,':',minu_num,':',seco_num];
    file_name = [Head_nam,'*',T_name,'*_time.nc'];
    filename = dir([Data_dir,'/',file_name]);
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

            lon   = ncload_2D([file_name,'_lon.nc']  ,'lon');
            lat   = ncload_2D([file_name,'_lat.nc']  ,'lat');
            z     = ncload_3D([file_name,'_z.nc']    ,'z');
            P     = ncload_3D([file_name,'_p.nc']    ,'p');
            f     = ncload_2D([file_name,'_f.nc']    ,'f');
            u     = ncload_3D([file_name,'_u.nc']    ,'u');
            v     = ncload_3D([file_name,'_v.nc']    ,'v');
            w     = ncload_3D([file_name,'_w.nc']    ,'w');
            rho   = ncload_3D([file_name,'_rho.nc']  ,'rho');
            avo   = ncload_3D([file_name,'_avo.nc']  ,'avo');
            kh    = ncload_3D([file_name,'_kh.nc']   ,'kh');
            kv    = ncload_3D([file_name,'_kv.nc']   ,'kv');
            RUBLTEN = ncload_3D([file_name,'_RUBLTEN.nc'],'RUBLTEN');
            RVBLTEN = ncload_3D([file_name,'_RVBLTEN.nc'],'RVBLTEN');
            theta = ncload_3D([file_name,'_theta.nc'] ,'theta');
            thetaE= ncload_3D([file_name,'_thetaE.nc'],'thetaE');
            if ~isempty(dir([file_name,'_pvo.nc']))
                pvo = ncload_3D([file_name,'_pvo.nc'],'pvo');
            else
                pvo = NaN(size(theta));
            end

            H_MICRO    = ncload_3D([file_name,'_H_DIABATIC.nc'],'H_DIABATIC')*Kday_to_Ks;
            H_RAD      = load_optional_3D([file_name,'_RTHRATEN.nc'],'RTHRATEN',H_MICRO)*Kday_to_Ks;
            H_PBL      = load_optional_3D([file_name,'_RTHBLTEN.nc'],'RTHBLTEN',H_MICRO)*Kday_to_Ks;
            H_CU       = load_optional_3D([file_name,'_RTHCUTEN.nc'],'RTHCUTEN',H_MICRO)*Kday_to_Ks;
            H_DIABATIC = H_MICRO + H_RAD + H_PBL + H_CU;

            if IF_Zfix
                for i=1:size(lon,1)
                    for j=1:size(lon,2)
                        z_col = squeeze(z(:,i,j));
                        valid_z = find(~isnan(z_col));
                        if length(valid_z)>=2
                            zS(:,i,j)          = z_fix;
                            PS(:,i,j)          = interp1(z_col(valid_z),squeeze(P(valid_z,i,j)),z_fix);
                            uS(:,i,j)          = interp1(z_col(valid_z),squeeze(u(valid_z,i,j)),z_fix);
                            vS(:,i,j)          = interp1(z_col(valid_z),squeeze(v(valid_z,i,j)),z_fix);
                            wS(:,i,j)          = interp1(z_col(valid_z),squeeze(w(valid_z,i,j)),z_fix);
                            rhoS(:,i,j)        = interp1(z_col(valid_z),squeeze(rho(valid_z,i,j)),z_fix);
                            avoS(:,i,j)        = interp1(z_col(valid_z),squeeze(avo(valid_z,i,j)),z_fix);
                            khS(:,i,j)         = interp1(z_col(valid_z),squeeze(kh(valid_z,i,j)),z_fix);
                            kvS(:,i,j)         = interp1(z_col(valid_z),squeeze(kv(valid_z,i,j)),z_fix);
                            RUBLTENS(:,i,j)    = interp1(z_col(valid_z),squeeze(RUBLTEN(valid_z,i,j)),z_fix);
                            RVBLTENS(:,i,j)    = interp1(z_col(valid_z),squeeze(RVBLTEN(valid_z,i,j)),z_fix);
                            pvoS(:,i,j)        = interp1(z_col(valid_z),squeeze(pvo(valid_z,i,j)),z_fix);
                            thetaS(:,i,j)      = interp1(z_col(valid_z),squeeze(theta(valid_z,i,j)),z_fix);
                            thetaES(:,i,j)     = interp1(z_col(valid_z),squeeze(thetaE(valid_z,i,j)),z_fix);
                            H_DIABATICS(:,i,j) = interp1(z_col(valid_z),squeeze(H_DIABATIC(valid_z,i,j)),z_fix);
                        else
                            zS(:,i,j)          = z_fix;
                            PS(:,i,j)          = NaN(size(z_fix));
                            uS(:,i,j)          = NaN(size(z_fix));
                            vS(:,i,j)          = NaN(size(z_fix));
                            wS(:,i,j)          = NaN(size(z_fix));
                            rhoS(:,i,j)        = NaN(size(z_fix));
                            avoS(:,i,j)        = NaN(size(z_fix));
                            khS(:,i,j)         = NaN(size(z_fix));
                            kvS(:,i,j)         = NaN(size(z_fix));
                            RUBLTENS(:,i,j)    = NaN(size(z_fix));
                            RVBLTENS(:,i,j)    = NaN(size(z_fix));
                            pvoS(:,i,j)        = NaN(size(z_fix));
                            thetaS(:,i,j)      = NaN(size(z_fix));
                            thetaES(:,i,j)     = NaN(size(z_fix));
                            H_DIABATICS(:,i,j) = NaN(size(z_fix));
                        end
                    end
                end
                z          = zS;
                P          = PS;
                u          = uS;
                v          = vS;
                w          = wS;
                rho        = rhoS;
                avo        = avoS;
                kh         = khS;
                kv         = kvS;
                RUBLTEN    = RUBLTENS;
                RVBLTEN    = RVBLTENS;
                pvo        = pvoS;
                theta      = thetaS;
                thetaE     = thetaES;
                H_DIABATIC = H_DIABATICS;
                clear zS PS uS vS wS rhoS avoS khS kvS RUBLTENS RVBLTENS pvoS thetaS thetaES H_DIABATICS
            end

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
                disty = ((1:size(dist,1)) - x1)*rough_reso;
                distx = ((1:size(dist,2)) - x2)*rough_reso;
                [X,Y] = meshgrid(distx,disty);
                dist  = sqrt(X.^2+Y.^2);
                clear distx disty x1 x2
            else
                for i = 1:size(mask,1)
                    for j = 1:size(mask,2)
                        dist(i,j) = distbear([lat(i,j) lat_TC],[lon(i,j) lon_TC],'wgs84')/1000;
                        X(i,j)    = distbear([lat_TC lat_TC],[lon(i,j) lon_TC],'wgs84')/1000*sign(lon(i,j)-lon_TC);
                        Y(i,j)    = distbear([lat(i,j) lat_TC],[lon_TC lon_TC],'wgs84')/1000*sign(lat(i,j)-lat_TC);
                    end
                end
            end
            x = X;
            y = Y;
            mask(find(dist<=Radius)) = 1;

            for i=1:size(x,1)
                for j=1:size(x,2)
                    if x(i,j)~=0||y(i,j)~=0
                        phi(i,j) = get_angle(x(i,j),y(i,j))/180*pi;
                        r(i,j)   = sqrt(x(i,j)^2+y(i,j)^2);
                    else
                        phi(i,j) = 0;
                        r(i,j)   = 0;
                    end
                end
            end

            [u,v] = VectorTrans_R2C(x,y,u,v);
            [Upbl,Vpbl] = VectorTrans_R2C(x,y,RUBLTEN,RVBLTEN);

            [Xc,Yc] = meshgrid(R,PHI);
            lon = Car2Cly(r,phi,lon,Xc,Yc);
            lat = Car2Cly(r,phi,lat,Xc,Yc);
            f   = Car2Cly(r,phi,f  ,Xc,Yc);
            for k=1:size(z,1)
                zS(k,:,:)          = Car2Cly(r,phi,squeeze(z(k,:,:))         .*mask,Xc,Yc);
                PS(k,:,:)          = Car2Cly(r,phi,squeeze(P(k,:,:))         .*mask,Xc,Yc);
                uS(k,:,:)          = Car2Cly(r,phi,squeeze(u(k,:,:))         .*mask,Xc,Yc);
                vS(k,:,:)          = Car2Cly(r,phi,squeeze(v(k,:,:))         .*mask,Xc,Yc);
                wS(k,:,:)          = Car2Cly(r,phi,squeeze(w(k,:,:))         .*mask,Xc,Yc);
                rhoS(k,:,:)        = Car2Cly(r,phi,squeeze(rho(k,:,:))       .*mask,Xc,Yc);
                avoS(k,:,:)        = Car2Cly(r,phi,squeeze(avo(k,:,:))       .*mask,Xc,Yc);
                khS(k,:,:)         = Car2Cly(r,phi,squeeze(kh(k,:,:))        .*mask,Xc,Yc);
                kvS(k,:,:)         = Car2Cly(r,phi,squeeze(kv(k,:,:))        .*mask,Xc,Yc);
                UpblS(k,:,:)       = Car2Cly(r,phi,squeeze(Upbl(k,:,:))      .*mask,Xc,Yc);
                VpblS(k,:,:)       = Car2Cly(r,phi,squeeze(Vpbl(k,:,:))      .*mask,Xc,Yc);
                pvoS(k,:,:)        = Car2Cly(r,phi,squeeze(pvo(k,:,:))       .*mask,Xc,Yc);
                thetaS(k,:,:)      = Car2Cly(r,phi,squeeze(theta(k,:,:))     .*mask,Xc,Yc);
                thetaES(k,:,:)     = Car2Cly(r,phi,squeeze(thetaE(k,:,:))    .*mask,Xc,Yc);
                H_DIABATICS(k,:,:) = Car2Cly(r,phi,squeeze(H_DIABATIC(k,:,:)).*mask,Xc,Yc);
            end

            z          = zS;
            P          = PS;
            u          = uS;
            v          = vS;
            w          = wS;
            rho        = rhoS;
            avo        = avoS;
            kh         = khS;
            kv         = kvS;
            Upbl       = UpblS;
            Vpbl       = VpblS;
            pvo        = pvoS;
            theta      = thetaS;
            thetaE     = thetaES;
            H_DIABATIC = H_DIABATICS;
            r          = repmat(reshape(R*1000,1,1,length(R)),size(z,1),length(PHI),1);
            pv_theta   = ertel_pv_cyl(u,v,w,avo,theta,r,z,dR*1000,dPhi,rho);
            pv_thetaE  = ertel_pv_cyl(u,v,w,avo,thetaE,r,z,dR*1000,dPhi,rho);
            pv_diff    = pv_thetaE - pv_theta;
            pv_theta_pvu  = pv_theta*1e6;
            pv_thetaE_pvu = pv_thetaE*1e6;
            pv_diff_pvu   = pv_diff*1e6;

            clear zS PS uS vS wS rhoS avoS khS kvS UpblS VpblS pvoS thetaS thetaES H_DIABATICS

            Save_file = [Save_nam,'_',T_name,'.mat'];
            save([Save_dir,'/',Save_file],...
                'R','PHI','dR','dPhi',...
                'IF_Zfix','z_hight',...
                'TIME','lon','lat','z','r','P','f',...
                'u','v','w','rho','avo','kh','kv','Upbl','Vpbl','pvo','pv_theta','pv_thetaE','pv_diff',...
                'pv_theta_pvu','pv_thetaE_pvu','pv_diff_pvu',...
                'theta','thetaE','H_DIABATIC',...
                'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC')

            clear TIME lon lat x y X Y Xc Yc z r P f
            clear u v w rho avo kh kv Upbl Vpbl RUBLTEN RVBLTEN pvo pv_theta pv_thetaE pv_diff pv_theta_pvu pv_thetaE_pvu pv_diff_pvu
            clear theta thetaE H_DIABATIC
            clear H_MICRO H_RAD H_PBL H_CU phi dist mask
        end
    end
end

function pv = ertel_pv_cyl(u,v,w,avo,b,r,z,dr,dPhi,rho)

r_safe = r;
r_safe(r_safe==0) = NaN;
br = d_dr_3d(b,dr);
bp = 1./r_safe.*d_phi_3d(b,dPhi);
bz = d_z_3d(b,z);
zeta_r   = 1./r_safe.*d_phi_3d(w,dPhi) - d_z_3d(v,z);
zeta_phi = d_z_3d(u,z) - d_dr_3d(w,dr);
pv = (zeta_r.*br + zeta_phi.*bp + avo.*bz)./rho;
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
