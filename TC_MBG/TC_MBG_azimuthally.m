clear
clc

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
        T_name    = tc_time_name(TIME);
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
        F = repmat(reshape(f,1,size(f,1),size(f,2)),size(z,1),1,1);
        r = repmat(reshape(R*1000,1,1,[]),size(z,1),size(z,2),1);
        r(r==0) = NaN;
        vo = avo-F;
        
        % At the axis v/r has a finite regular-flow limit.  Leaving the
        % axis as NaN before dVdR contaminates the first non-zero radius
        % through the one-sided stencil, so extend it from that first ring.
        v_over_r = v./r;
        if size(r,3)>1
            v_over_r(:,:,1) = v_over_r(:,:,2);
        end
        Trp =   kh.*(dVdPhi(u,dPhi)./r + r.*dVdR(v_over_r,dr));
        Tpz =   kv.*(dVdPhi(w,dPhi)./r + dVdZ(v,z));
        Trr = 2*kh.*(dVdR(u,dr));
        Tpp = 2*kh.*(dVdPhi(v,dPhi)./r + u./r);
        Trz =   kv.*(dVdZ(u,z)         + dVdR(w,dr));
        
        disp(['Calculating...'])
        um    = mean(u,2,'omitnan');     vm    = mean(v,2,'omitnan');
        wm    = mean(w,2,'omitnan');     Om    = mean(vo,2,'omitnan');
        Rm    = mean(rho,2,'omitnan');   Pm    = mean(p,2,'omitnan');
        TrpM  = mean(Trp,2,'omitnan');   TpzM  = mean(Tpz,2,'omitnan');
        TrrM  = mean(Trr,2,'omitnan');   TppM  = mean(Tpp,2,'omitnan');
        TrzM  = mean(Trz,2,'omitnan');
        UpblM = mean(Upbl,2,'omitnan');  VpblM = mean(Vpbl,2,'omitnan');
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
