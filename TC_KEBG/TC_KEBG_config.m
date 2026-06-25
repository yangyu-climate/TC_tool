function cfg = TC_KEBG_config

% Time control
cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8  6];
cfg.Time_frq = 15; % minute

cfg.Radius = 300;      % km
cfg.dR     = 1;        % km
cfg.dPhi   = 1*pi/180; % rad

cfg.rough_dist = 1;
cfg.rough_reso = 3;    % km

cfg.TC_smooth_hours = 1; % hour
cfg.TC_smooth_pass  = 1; % pass
cfg.Kday_to_Ks      = 1/(24*60*60);

cfg.IF_Zfix = 0;
cfg.z_limit = 20000;   % m
cfg.z_level = 500;     % m
cfg.z_low   = 1000;    % m
cfg.z_lowL  = 50;      % m
cfg.z_hight = [0:cfg.z_lowL:(cfg.z_low-cfg.z_lowL) cfg.z_low:cfg.z_level:cfg.z_limit];

cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Input_dir  = '../Pre/BGT/DATA';
cfg.Head_nam   = 'wrfout_d03';
cfg.Save_nam   = 'KEBG';

% Budget calculation
cfg.calc.Tendency_frq = 15;  % minute
cfg.calc.Max_WN   = Inf;
cfg.calc.Use_thetaE = 0; % 0: theta-based APE; 1: thetaE proxy
cfg.calc.Budget_Radius = 100; % km
cfg.calc.min_N2 = 1.0e-6;
end
