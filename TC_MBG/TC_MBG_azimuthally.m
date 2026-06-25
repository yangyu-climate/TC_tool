clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_MBG_config;

Data_dir   = [pwd,'/Result/Data'];
Head_nam   = cfg.Save_nam;
Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/azimuthally'];
mkdir(Save_dir)

file_name = [Head_nam,'*.mat'];
filename  = dir([Data_dir,'/',file_name]);

if   ~isempty(filename)
    for N = 1:length(filename)
        file_name = filename(N).name;
        fileN     = [Data_dir,'/',file_name];
        TIME      = load_data(fileN,'TIME');
        [year,month,day,hour,minu,seco] = date2num(TIME);
        [year_num,month_num,day_num,...
         hour_num,minu_num,seco_num]    = date2str(TIME);
        T_name    = [year_num,'-',month_num,'-',day_num,'_',...
                     hour_num,':',minu_num,':',seco_num];
        disp([' '])
        disp(['Date: ',T_name])
        disp(['File: ',fileN])
        disp(['Loading...'])

        R      = load_data(fileN,'R');
        PHI    = load_data(fileN,'PHI');
        dR     = load_data(fileN,'dR');
        dPhi   = load_data(fileN,'dPhi');
        lon    = load_data(fileN,'lon');
        lat    = load_data(fileN,'lat');
        z      = load_data(fileN,'z');
        P      = load_data(fileN,'P');
        p      = P*100;
        f      = load_data(fileN,'f');
        u      = load_data(fileN,'u');
        v      = load_data(fileN,'v');
        w      = load_data(fileN,'w');
        kh     = load_data(fileN,'kh');
        kv     = load_data(fileN,'kv');
        Upbl   = load_data(fileN,'Upbl');
        Vpbl   = load_data(fileN,'Vpbl');
        avo    = load_data(fileN,'avo');
        rho    = load_data(fileN,'rho');
        lon_TC = load_data(fileN,'lon_TC');
        lat_TC = load_data(fileN,'lat_TC');
        slp_TC = load_data(fileN,'slp_TC');
        swd_TC = load_data(fileN,'swd_TC');
        
        dr = dR*1000;
        for k=1:size(z,1)
            F(k,:,:) = f;
            for j=1:size(z,2)
                r(k,j,:) = R*1000;
            end
        end
        r(r==0) = NaN;
        vo = avo-F;
        
        Trp =   kh.*(dVdPhi(u,dPhi)./r + r.*dVdR(v./r,dr));
        Tpz =   kv.*(dVdPhi(w,dPhi)./r + dVdZ(v,z));
        Trr = 2*kh.*(dVdR(u,dr));
        Tpp = 2*kh.*(dVdPhi(v,dPhi)./r + u./r);
        Trz =   kv.*(dVdZ(u,z)         + dVdR(w,dr));
        
        disp(['Calculating...'])
        for j=1:size(z,2)
            um(:,j,:)     = nanmean(u,2);
            vm(:,j,:)     = nanmean(v,2);
            wm(:,j,:)     = nanmean(w,2);
            Om(:,j,:)     = nanmean(vo,2);
            Rm(:,j,:)     = nanmean(rho,2);
            Pm(:,j,:)     = nanmean(p,2);
            TrpM(:,j,:)   = nanmean(Trp,2);
            TpzM(:,j,:)   = nanmean(Tpz,2);
            TrrM(:,j,:)   = nanmean(Trr,2);
            TppM(:,j,:)   = nanmean(Tpp,2);
            TrzM(:,j,:)   = nanmean(Trz,2);
            UpblM(:,j,:)  = nanmean(Upbl,2);
            VpblM(:,j,:)  = nanmean(Vpbl,2);
        end
        up    = u    - um;
        vp    = v    - vm;
        wp    = w    - wm;
        Op    = vo   - Om;
        Rp    = rho  - Rm;
        Pp    = p    - Pm;
        
        % Save Data
        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
              'R','PHI','dR','dPhi','r','dr',...
              'TIME','lon','lat','z','P',...
              'f','u','v','w','kh','kv','F','vo','rho','p',...
              'um','vm','wm','Om','Rm','Pm',...
              'up','vp','wp','Op','Rp','Pp',...
              'TrpM','TpzM','TrrM','TppM','TrzM',...
              'UpblM','VpblM',...
              'lon_TC','lat_TC','slp_TC','swd_TC')
        clear R PHI dR dPhi r dr
        clear TIME lon lat z P
        clear f u v w kh kv Upbl Vpbl avo F vo rho p
        clear um vm wm Om Rm Pm
        clear up vp wp Op Rp Pp
        clear Trp  Tpz  Trr  Tpp  Trz
        clear TrpM TpzM TrrM TppM TrzM UpblM VpblM
        clear lon_TC lat_TC slp_TC swd_TC
        
    end
end
