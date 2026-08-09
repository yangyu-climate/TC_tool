function cfg = TC_Rfield_config

cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8 6];
cfg.Time_frq = 15; % minute
cfg.Radius = 300; % km
cfg.resolution = 1; % km
cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Head_nam = 'wrfout_d03';

cfg.Input_dir  = '../Pre/PHY/DATA';
cfg.Save_nam   = 'RF';

% Slice diagnostics
cfg.slice.smooth_dR = 3; % km

% Vertical-level diagnostics
cfg.vlevel.level_type  = 0; % 0: height; 1: pressure
cfg.vlevel.level_slect = [1 2 3 4 5 6 9 12]*1000;
end
