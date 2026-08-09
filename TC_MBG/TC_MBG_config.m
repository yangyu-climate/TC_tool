function cfg = TC_MBG_config

cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8 6];
cfg.Time_frq = 15; % minute
cfg.Radius = 300; % km
cfg.dR = 1; % km
cfg.dPhi = pi/180; % rad
cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Head_nam = 'wrfout_d03';

cfg.IF_Zfix = 0;
cfg.z_limit = 20000;   % m
cfg.z_level = 500;     % m
cfg.z_low   = 1000;    % m
cfg.z_lowL  = 50;      % m
cfg.z_hight = [0:cfg.z_lowL:(cfg.z_low-cfg.z_lowL) cfg.z_low:cfg.z_level:cfg.z_limit];

cfg.Input_dir  = '../Pre/BGT/DATA';
cfg.Save_nam   = 'MBG';

% Budget calculation
cfg.calc.Tendency_frq = 15; % minute
% One and only one representation of subgrid momentum forcing enters the
% closure.  The direct WRF PBL tendency is the default; using kh/kv stresses
% instead is a diagnostic sensitivity and must not be combined with it.
cfg.calc.Subgrid_momentum_mode = 'wrf_pbl_tendency'; % or 'khkv_stress'
end
