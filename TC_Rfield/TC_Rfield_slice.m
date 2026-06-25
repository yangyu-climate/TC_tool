clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_Rfield_config;

Time_beg    = cfg.Time_beg;
Time_end    = cfg.Time_end;

Data_dir   = [pwd,'/Result/MVCT'];
Head_nam   = cfg.Save_nam;
Radius     = cfg.Radius;
resolution = cfg.resolution;
dR         = cfg.slice.smooth_dR;
dr         = dR/2;

Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/SLICE'];
mkdir(Save_dir)

R = [0:resolution:ceil(Radius/resolution)*resolution];

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
        
        x              = load_data(fileN,'x');
        y              = load_data(fileN,'y');
        dist           = sqrt(x.^2+y.^2);        
        z              = load_data(fileN,'z');
        P              = load_data(fileN,'P');

        pblh           = load_data(fileN,'pblh');
        LHF            = load_data(fileN,'LHF');
        SHF            = load_data(fileN,'SHF');
        SST            = load_data(fileN,'SST');
        SLP            = load_data(fileN,'SLP');
        U10            = load_data(fileN,'U10');
        V10            = load_data(fileN,'V10');
        SWD            = sqrt(U10.^2 + V10.^2);
        clear U10 V10

        u              = load_data(fileN,'u');
        v              = load_data(fileN,'v');
        w              = load_data(fileN,'w');
        w2             = w.^2;
        M              = load_data(fileN,'M');
        avo            = load_data(fileN,'avo');
        pvo            = load_data(fileN,'pvo');
        rvo            = load_data(fileN,'rvo');

        theta          = load_data(fileN,'theta');
        thetaE         = load_data(fileN,'thetaE');
        DethDz         = load_data(fileN,'DethDz');
        Qv             = load_data(fileN,'Qv');
        Qc             = load_data(fileN,'Qc');
        Qr             = load_data(fileN,'Qr');
        Qi             = load_data(fileN,'Qi');
        Qs             = load_data(fileN,'Qs');
        Qg             = load_data(fileN,'Qg');
        QW             = load_data(fileN,'QW');
        QI             = load_data(fileN,'QI');
        H_DIABATIC     = load_data(fileN,'H_DIABATIC'); 

        DIABATIC_P     = H_DIABATIC;
        DIABATIC_N     = H_DIABATIC;
        DIABATIC_P(find(DIABATIC_P<=0))=NaN;
        DIABATIC_N(find(DIABATIC_N>=0))=NaN;

        for i =1:length(R)
            mask = NaN*ones(size(dist));
            loc  = find( dist>=(R(i)-dr) & dist<(R(i)+dr) );
            mask(loc) = 1;
            pblhS(i) = mean_2D(pblh.*mask);
            LHFS(i)  = mean_2D(LHF .*mask);
            SHFS(i)  = mean_2D(SHF .*mask);
            SSTS(i)  = mean_2D(SST .*mask);
            SLPS(i)  = mean_2D(SLP .*mask);
            SWDS(i)  = mean_2D(SWD .*mask);
            for layerN = 1:size(P,1)
                zS(layerN,i)          = mean_2D(squeeze(z(layerN,:,:))         .*mask);
                PS(layerN,i)          = mean_2D(squeeze(P(layerN,:,:))         .*mask);
                uS(layerN,i)          = mean_2D(squeeze(u(layerN,:,:))         .*mask);
                vS(layerN,i)          = mean_2D(squeeze(v(layerN,:,:))         .*mask);
                wS(layerN,i)          = mean_2D(squeeze(w(layerN,:,:))         .*mask);
                w2S(layerN,i)         = mean_2D(squeeze(w2(layerN,:,:))        .*mask);
                MS(layerN,i)          = mean_2D(squeeze(M(layerN,:,:))         .*mask);
                avoS(layerN,i)        = mean_2D(squeeze(avo(layerN,:,:))       .*mask); 
                pvoS(layerN,i)        = mean_2D(squeeze(pvo(layerN,:,:))       .*mask); 
                rvoS(layerN,i)        = mean_2D(squeeze(rvo(layerN,:,:))       .*mask); 
                thetaS(layerN,i)      = mean_2D(squeeze(theta(layerN,:,:))     .*mask); 
                thetaES(layerN,i)     = mean_2D(squeeze(thetaE(layerN,:,:))    .*mask); 
                DethDzS(layerN,i)     = mean_2D(squeeze(DethDz(layerN,:,:))    .*mask); 
                QvS(layerN,i)         = mean_2D(squeeze(Qv(layerN,:,:))        .*mask); 
                QcS(layerN,i)         = mean_2D(squeeze(Qc(layerN,:,:))        .*mask); 
                QrS(layerN,i)         = mean_2D(squeeze(Qr(layerN,:,:))        .*mask); 
                QiS(layerN,i)         = mean_2D(squeeze(Qi(layerN,:,:))        .*mask); 
                QsS(layerN,i)         = mean_2D(squeeze(Qs(layerN,:,:))        .*mask); 
                QgS(layerN,i)         = mean_2D(squeeze(Qg(layerN,:,:))        .*mask); 
                QWS(layerN,i)         = mean_2D(squeeze(QW(layerN,:,:))        .*mask); 
                QIS(layerN,i)         = mean_2D(squeeze(QI(layerN,:,:))        .*mask); 
                H_DIABATICS(layerN,i) = mean_2D(squeeze(H_DIABATIC(layerN,:,:)).*mask); 
                DIABATIC_PS(layerN,i) = mean_2D(squeeze(DIABATIC_P(layerN,:,:)).*mask); 
                DIABATIC_NS(layerN,i) = mean_2D(squeeze(DIABATIC_N(layerN,:,:)).*mask); 
            end
        end
        
        pblh           = pblhS;
        LHF            = LHFS;
        SHF            = SHFS;
        SST            = SSTS;
        SLP            = SLPS;
        SWD            = SWDS;

        z              = zS;
        P              = PS;
        u              = uS;
        v              = vS;
        w              = wS;
        w2             = w2S;
        M              = MS;
        avo            = avoS;
        pvo            = pvoS;
        rvo            = rvoS;

        theta          = thetaS;
        thetaE         = thetaES;
        DethDz         = DethDzS;
        Qv             = QvS;
        Qc             = QcS;
        Qr             = QrS;
        Qi             = QiS;
        Qs             = QsS;
        Qg             = QgS;
        QW             = QWS;
        QI             = QIS;
        H_DIABATIC     = H_DIABATICS;
        DIABATIC_P     = DIABATIC_PS;
        DIABATIC_N     = DIABATIC_NS;

        clear pblhS LHFS SHFS SSTS SLPS SWDS
        clear zS PS 
        clear uS vS wS w2S MS avoS pvoS rvoS
        clear thetaS thetaES DethDzS
        clear QvS QcS QrS QiS QsS QgS QWS QIS
        clear H_DIABATICS DIABATIC_PS DIABATIC_NS
        
        % Save Data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
            'TIME','R','z','P','pblh',...
            'LHF','SHF','SST','SLP','SWD',...
            'u','v','w','w2','M','avo','pvo','rvo',...
            'theta','thetaE','DethDz',...
            'Qv','Qc','Qr','Qi','Qs','Qg','QW','QI',...
            'H_DIABATIC','DIABATIC_P','DIABATIC_N',...
            'lon_TC','lat_TC','slp_TC','swd_TC','u_TC','v_TC')
        end
    end
end
