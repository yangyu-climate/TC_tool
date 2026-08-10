function cfg = TC_PVBG_config

cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8 6];
cfg.Time_frq = 15; % minute
cfg.Tendency_frq = 15; % minute; neighboring states must exist at t +/- n*Tendency_frq
cfg.Radius = 300; % km
cfg.dR = 1; % km
cfg.dPhi = pi/180; % rad
cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Head_nam = 'wrfout_d03';

% Unit conversion
cfg.Kday_to_Ks = 1/(24*60*60);
cfg.Omega = 7.292115e-5; % Earth rotation rate, rad s-1

% Fixed-height remapping
cfg.IF_Zfix = 1;
cfg.z_limit = 20000;     % m
cfg.z_level = 500;       % m
cfg.z_low   = 1000;      % m
cfg.z_lowL  = 50;        % m
cfg.z_hight = [0:cfg.z_lowL:(cfg.z_low-cfg.z_lowL) cfg.z_low:cfg.z_level:cfg.z_limit];

% Budget options
cfg.Use_thetaE = 1;      % 0: theta PV; 1: thetaE PV
cfg.Use_khkv_friction = 0; % 0: diagnostic only; 1: add kh/kv term to PV_friction

% File naming
cfg.Input_dir  = '../Pre/BGT/DATA';
cfg.Save_nam   = 'PVBG';
end
