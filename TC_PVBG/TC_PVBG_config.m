function cfg = TC_PVBG_config

% Time control
cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8  6];
cfg.Time_frq = 15;       % minute; WRF/output analysis interval
cfg.Tendency_frq = 15;   % minute; neighbor interval for tendency terms

% Cylindrical grid
cfg.Radius = 300;        % km
cfg.dR     = 1;          % km
cfg.dPhi   = 1*pi/180;   % rad

% Approximate Cartesian distance option
cfg.rough_dist = 1;      % 1: use grid spacing when center is on model grid
cfg.rough_reso = 3;      % km; used only with rough_dist=1

% TC translation speed smoothing
cfg.TC_smooth_hours = 1; % hour
cfg.TC_smooth_pass  = 1; % pass

% Unit conversion
cfg.Kday_to_Ks = 1/(24*60*60);

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
cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Input_dir  = '../Pre/BGT/DATA';
cfg.Head_nam   = 'wrfout_d03';
cfg.Save_nam   = 'PVBG';
end
