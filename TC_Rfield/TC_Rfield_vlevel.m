clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start
cfg = TC_Rfield_config;

Time_beg    = cfg.Time_beg;
Time_end    = cfg.Time_end;
level_type  = cfg.vlevel.level_type;
level_slect = cfg.vlevel.level_slect;

Data_dir  = [pwd,'/Result/MVCT'];
Head_nam  = cfg.Save_nam;
Save_nam  = cfg.Save_nam;
Save_dir  = [pwd,'/Result/VLEVEL'];
mkdir(Save_dir)

T_beg     = datenum(Time_beg);
T_end     = datenum(Time_end);
file_name = [Head_nam,'*.mat'];
filename  = dir([Data_dir,'/',file_name]);

if ~isempty(filename)
    for N = 1:length(filename)
        file_name = filename(N).name;
        fileN     = [Data_dir,'/',file_name];        
        TIME      = load_data(fileN,'TIME');
        lon_TC    = load_data(fileN,'lon_TC');
        lat_TC    = load_data(fileN,'lat_TC');
        slp_TC    = load_data(fileN,'slp_TC');
        swd_TC    = load_data(fileN,'swd_TC');
        u_TC      = load_data(fileN,'u_TC');
        v_TC      = load_data(fileN,'v_TC');
        
        if TIME>=T_beg&&TIME<=T_end
        [year,month,day,hour,minu,seco] = date2num(TIME);
        [year_num,month_num,day_num,...
         hour_num,minu_num,seco_num]    = date2str(TIME);
        T_name    = [year_num,'-',month_num,'-',day_num,'_',...
                     hour_num,':',minu_num,':',seco_num];
        disp([' '])
        disp(['Date: ',T_name])
        disp(['File: ',fileN])
        disp(['TC center: ',num2str(lon_TC),'E ',num2str(lat_TC),'N'])
        disp(['SLP: ',num2str(slp_TC),'hPa    Max Wind: ',num2str(swd_TC),'m/s'])
        disp(['TC Moving Speed: U ',num2str(u_TC),'m/s  V ',num2str(v_TC),'m/s'])
        disp(['Calculating...'])
        
        Radius = load_data(fileN,'Radius');
        dR     = load_data(fileN,'dR');
        lon    = load_data(fileN,'lon');
        lat    = load_data(fileN,'lat');
        x      = load_data(fileN,'x');
        y      = load_data(fileN,'y');
        z      = load_data(fileN,'z');
        r      = load_data(fileN,'r');
        P      = load_data(fileN,'P');
        f      = load_data(fileN,'f');
        LHF    = load_data(fileN,'LHF');
        SHF    = load_data(fileN,'SHF');
        SST    = load_data(fileN,'SST');
        U10    = load_data(fileN,'U10');
        V10    = load_data(fileN,'V10');
        SWD    = sqrt(U10.^2 + V10.^2);
        % Hydrometeor
        Qv     = load_data(fileN,'Qv');
        Qc     = load_data(fileN,'Qc');
        Qr     = load_data(fileN,'Qr');
        Qi     = load_data(fileN,'Qi');
        Qs     = load_data(fileN,'Qs');
        Qg     = load_data(fileN,'Qg');
        QW     = load_data(fileN,'QW');
        QI     = load_data(fileN,'QI');
        % Dynamic
        uc     = load_data(fileN,'uc');
        vc     = load_data(fileN,'vc');
        u      = load_data(fileN,'u');
        v      = load_data(fileN,'v');
        w      = load_data(fileN,'w');
        avo    = load_data(fileN,'avo');
        pvo    = load_data(fileN,'pvo');
        rvo    = load_data(fileN,'rvo');
        % Thermodynamic 
        rho    = load_data(fileN,'rho');
        theta  = load_data(fileN,'theta');
        thetaE = load_data(fileN,'thetaE');
        DethDz = load_data(fileN,'DethDz');
        Hdia   = load_data(fileN,'H_DIABATIC');
        
        if level_type==0
            V_lev = z;
        elseif level_type==1
            V_lev = P;
        end
        
        var_size = [length(level_slect),size(r,1),size(r,2)];
        Qv_S     = NaN*ones(var_size);
        Qc_S     = NaN*ones(var_size);
        Qr_S     = NaN*ones(var_size);
        Qi_S     = NaN*ones(var_size);
        Qs_S     = NaN*ones(var_size);
        Qg_S     = NaN*ones(var_size);
        QW_S     = NaN*ones(var_size);
        QI_S     = NaN*ones(var_size);
        uc_S     = NaN*ones(var_size);
        vc_S     = NaN*ones(var_size);
        u_S      = NaN*ones(var_size);
        v_S      = NaN*ones(var_size);
        w_S      = NaN*ones(var_size);
        avo_S    = NaN*ones(var_size);
        pvo_S    = NaN*ones(var_size);
        rvo_S    = NaN*ones(var_size);
        rho_S    = NaN*ones(var_size);
        theta_S  = NaN*ones(var_size);
        thetaE_S = NaN*ones(var_size);
        DethDz_S = NaN*ones(var_size);
        Hdia_S   = NaN*ones(var_size);

        for i=1:size(r,1)
          for j=1:size(r,2)
            valid_lev = ~isnan(V_lev(:,i,j));
            if sum(valid_lev)>=2
            lev = squeeze(V_lev(valid_lev,i,j));
            % Hydrometeor
            Qv_S(:,i,j) = interp1(lev,squeeze(Qv(valid_lev,i,j)),level_slect);
            Qc_S(:,i,j) = interp1(lev,squeeze(Qc(valid_lev,i,j)),level_slect);
            Qr_S(:,i,j) = interp1(lev,squeeze(Qr(valid_lev,i,j)),level_slect);
            Qi_S(:,i,j) = interp1(lev,squeeze(Qi(valid_lev,i,j)),level_slect);
            Qs_S(:,i,j) = interp1(lev,squeeze(Qs(valid_lev,i,j)),level_slect);
            Qg_S(:,i,j) = interp1(lev,squeeze(Qg(valid_lev,i,j)),level_slect);
            QW_S(:,i,j) = interp1(lev,squeeze(QW(valid_lev,i,j)),level_slect);
            QI_S(:,i,j) = interp1(lev,squeeze(QI(valid_lev,i,j)),level_slect);
            % Dynamic
            uc_S(:,i,j)    = interp1(lev,squeeze(uc(valid_lev,i,j))   ,level_slect);
            vc_S(:,i,j)    = interp1(lev,squeeze(vc(valid_lev,i,j))   ,level_slect);
            u_S(:,i,j)     = interp1(lev,squeeze(u(valid_lev,i,j))    ,level_slect);
            v_S(:,i,j)     = interp1(lev,squeeze(v(valid_lev,i,j))    ,level_slect);
            w_S(:,i,j)     = interp1(lev,squeeze(w(valid_lev,i,j))    ,level_slect);
            avo_S(:,i,j)   = interp1(lev,squeeze(avo(valid_lev,i,j))  ,level_slect);
            pvo_S(:,i,j)   = interp1(lev,squeeze(pvo(valid_lev,i,j))  ,level_slect);
            rvo_S(:,i,j)   = interp1(lev,squeeze(rvo(valid_lev,i,j))  ,level_slect);
            % Thermodynamic 
            rho_S(:,i,j)    = interp1(lev,squeeze(rho(valid_lev,i,j))   ,level_slect);
            theta_S(:,i,j)  = interp1(lev,squeeze(theta(valid_lev,i,j)) ,level_slect);
            thetaE_S(:,i,j) = interp1(lev,squeeze(thetaE(valid_lev,i,j)),level_slect);
            DethDz_S(:,i,j) = interp1(lev,squeeze(DethDz(valid_lev,i,j)),level_slect);
            Hdia_S(:,i,j)   = interp1(lev,squeeze(Hdia(valid_lev,i,j))  ,level_slect);
            end
          end
        end
        % Hydrometeor
        Qv     = Qv_S;
        Qc     = Qc_S;
        Qr     = Qr_S;
        Qi     = Qi_S;
        Qs     = Qs_S;
        Qg     = Qg_S;
        QW     = QW_S;
        QI     = QI_S;
        % Dynamic
        uc     = uc_S;
        vc     = vc_S;
        u      = u_S;
        v      = v_S;
        w      = w_S;
        avo    = avo_S;
        pvo    = pvo_S;
        rvo    = rvo_S;
        % Thermodynamic
        rho    = rho_S;
        theta  = theta_S;
        thetaE = thetaE_S;
        DethDz = DethDz_S;
        Hdia   = Hdia_S;
        clear Qv_S Qc_S Qr_S Qi_S Qs_S Qg_S QW_S QI_S 
        clear uc_S vc_S u_S v_S w_S avo_S pvo_S rvo_S
        clear rho_S theta_S thetaE_S DethDz_S Hdia_S
        clear var_size valid_lev lev
        
        % Save Data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
              'Radius','dR',...
              'TIME','lon','lat','x','y','r','f',...
              'level_type','level_slect',...
              'LHF','SHF','SST','U10','V10','SWD',...
              'Qv','Qc','Qr','Qi','Qs','Qg','QW','QI',...
              'uc','vc','u','v','w','avo','pvo','rvo',...
              'rho','theta','thetaE','DethDz','Hdia',...
              'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC')
        clear Radius dR TIME lon lat x y z r P f
        clear LHF SHF SST U10 V10 SWD
        clear Qv Qc Qr Qi Qs Qg QW QI
        clear uc vc u v w avo pvo rvo
        clear rho theta thetaE DethDz Hdia
        clear lon_TC lat_TC slp_TC swd_TC u_TC v_TC
        
        end
    end
end
