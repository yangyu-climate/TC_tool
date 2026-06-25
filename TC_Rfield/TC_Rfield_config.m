function cfg = TC_Rfield_config

% Time control
cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8  6];
cfg.Time_frq = 15; % minute

cfg.Radius     = 300; % km
cfg.resolution = 1;   % km
cfg.rough_dist = 1;
cfg.rough_reso = 3;   % km

cfg.TC_smooth_hours = 1; % hour
cfg.TC_smooth_pass  = 1; % pass

cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Input_dir  = '../Pre/PHY/DATA';
cfg.Head_nam   = 'wrfout_d03';
cfg.Save_nam   = 'RF';

% Slice diagnostics
cfg.slice.smooth_dR = 3; % km

% Vertical-level diagnostics
cfg.vlevel.level_type  = 0; % 0: height; 1: pressure
cfg.vlevel.level_slect = [1 2 3 4 5 6 9 12]*1000;
end
