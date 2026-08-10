clear
clc

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
        T_name = tc_time_name(TIME);
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
        P          = load_data(fileN,'P');
        p          = P*100;
        omega      = load_data(fileN,'omega');
        u          = load_data(fileN,'u');
        v          = load_data(fileN,'v');
        tk         = load_data(fileN,'tk');
        theta      = load_data(fileN,'theta');
        H_DIABATIC = load_data(fileN,'H_DIABATIC');
        lon_TC     = load_data(fileN,'lon_TC');
        lat_TC     = load_data(fileN,'lat_TC');
        lon_track  = load_data(fileN,'lon_track');
        lat_track  = load_data(fileN,'lat_track');
        center_slp = load_data(fileN,'center_slp');
        slp_track  = load_data(fileN,'slp_track');
        swd_track  = load_data(fileN,'swd_track');
        heating_components_available = load_data(fileN,'heating_components_available');
        u_TC = load_data(fileN,'u_TC'); v_TC = load_data(fileN,'v_TC');
        center_motion_method = load_data(fileN,'center_motion_method');

        dr = dR*1000;
        r = repmat(reshape(R*1000,1,1,[]),size(P,1),size(P,2),1);
        r(r==0) = NaN;

        disp(['Calculating...'])
        um     = mean(u,2,'omitnan');
        vm     = mean(v,2,'omitnan');
        Pm     = mean(p,2,'omitnan');
        omegam = mean(omega,2,'omitnan');
        Tm     = mean(tk,2,'omitnan');
        thm    = mean(theta,2,'omitnan');
        Hm     = mean(H_DIABATIC,2,'omitnan');

        up   = u          - um;
        vp   = v          - vm;
        Pp   = p          - Pm;
        omegap = omega    - omegam;
        Tp   = tk         - Tm;
        thp  = theta      - thm;
        Hp   = H_DIABATIC - Hm;

        dthmdr = dVdR(thm,dr);
        dTmdr  = dVdR(Tm,dr);

        Save_file = [Save_nam,'_',T_name,'.mat'];
        save([Save_dir,'/',Save_file],...
              'R','PHI','dR','dPhi','r','dr',...
              'TIME','lon','lat','P','p','omega',...
              'u','v','tk','theta','H_DIABATIC',...
              'um','vm','Pm','Tm','thm','Hm','omegam',...
              'up','vp','Pp','Tp','thp','Hp','omegap',...
              'dthmdr','dTmdr',...
              'lon_TC','lat_TC','lon_track','lat_track','center_slp','slp_track','swd_track',...
              'u_TC','v_TC','center_motion_method','heating_components_available')
        clear R PHI dR dPhi r dr
        clear TIME lon lat P p omega
        clear u v tk theta H_DIABATIC
        clear um vm Pm Tm thm Hm omegam
        clear up vp Pp Tp thp Hp omegap
        clear dthmdr dTmdr
        clear lon_TC lat_TC lon_track lat_track center_slp slp_track swd_track u_TC v_TC center_motion_method heating_components_available
    end
end
