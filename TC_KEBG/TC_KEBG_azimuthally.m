clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_KEBG_config;

Data_dir   = [pwd,'/Result/Data'];
Head_nam   = cfg.Save_nam;
Save_nam   = cfg.Save_nam;
Save_dir   = [pwd,'/Result/azimuthally'];
mkdir(Save_dir)

file_name = [Head_nam,'*.mat'];
filename  = dir([Data_dir,'/',file_name]);

if ~isempty(filename)
    for N = 1:length(filename)
        file_name = filename(N).name;
        fileN     = [Data_dir,'/',file_name];
        TIME      = load_data(fileN,'TIME');
        [year,month,day,hour,minu,seco] = date2num(TIME);
        [year_num,month_num,day_num,...
         hour_num,minu_num,seco_num]    = date2str(TIME);
        T_name = [year_num,'-',month_num,'-',day_num,'_',...
                  hour_num,':',minu_num,':',seco_num];
        disp([' '])
        disp(['Date: ',T_name])
        disp(['File: ',fileN])
        disp(['Loading...'])

        R          = load_data(fileN,'R');
        PHI        = load_data(fileN,'PHI');
        dR         = load_data(fileN,'dR');
        dPhi       = load_data(fileN,'dPhi');
        lon        = load_data(fileN,'lon');
        lat        = load_data(fileN,'lat');
        z          = load_data(fileN,'z');
        P          = load_data(fileN,'P');
        p          = P*100;
        u          = load_data(fileN,'u');
        v          = load_data(fileN,'v');
        w          = load_data(fileN,'w');
        rho        = load_data(fileN,'rho');
        tk         = load_data(fileN,'tk');
        theta      = load_data(fileN,'theta');
        thetaE     = load_data(fileN,'thetaE');
        H_DIABATIC = load_data(fileN,'H_DIABATIC');
        lon_TC     = load_data(fileN,'lon_TC');
        lat_TC     = load_data(fileN,'lat_TC');
        slp_TC     = load_data(fileN,'slp_TC');
        swd_TC     = load_data(fileN,'swd_TC');

        dr = dR*1000;
        for k=1:size(z,1)
            for j=1:size(z,2)
                r(k,j,:) = R*1000;
            end
        end
        r(r==0) = NaN;

        disp(['Calculating...'])
        for j=1:size(z,2)
            um(:,j,:)      = nanmean(u,2);
            vm(:,j,:)      = nanmean(v,2);
            wm(:,j,:)      = nanmean(w,2);
            Rm(:,j,:)      = nanmean(rho,2);
            Pm(:,j,:)      = nanmean(p,2);
            Tm(:,j,:)      = nanmean(tk,2);
            thm(:,j,:)     = nanmean(theta,2);
            thEm(:,j,:)    = nanmean(thetaE,2);
            Hm(:,j,:)      = nanmean(H_DIABATIC,2);
        end

        up   = u          - um;
        vp   = v          - vm;
        wp   = w          - wm;
        Rp   = rho        - Rm;
        Pp   = p          - Pm;
        Tp   = tk         - Tm;
        thp  = theta      - thm;
        thEp = thetaE     - thEm;
        Hp   = H_DIABATIC - Hm;

        dthmdr = dVdR(thm,dr);
        dthmdz = dVdZ(thm,z);
        dTmdr  = dVdR(Tm,dr);
        dTmdz  = dVdZ(Tm,z);

        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
              'R','PHI','dR','dPhi','r','dr',...
              'TIME','lon','lat','z','P','p',...
              'u','v','w','rho','tk','theta','thetaE','H_DIABATIC',...
              'um','vm','wm','Rm','Pm','Tm','thm','thEm','Hm',...
              'up','vp','wp','Rp','Pp','Tp','thp','thEp','Hp',...
              'dthmdr','dthmdz','dTmdr','dTmdz',...
              'lon_TC','lat_TC','slp_TC','swd_TC')
        clear R PHI dR dPhi r dr
        clear TIME lon lat z P p
        clear u v w rho tk theta thetaE H_DIABATIC
        clear um vm wm Rm Pm Tm thm thEm Hm
        clear up vp wp Rp Pp Tp thp thEp Hp
        clear dthmdr dthmdz dTmdr dTmdz
        clear lon_TC lat_TC slp_TC swd_TC
    end
end
