function cfg = TC_track_config

cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8  6];
cfg.Ini_loc  = [135.8 11.4]; % Lon, Lat

cfg.Input_dir  = '../Pre/SLP/DATA';
cfg.Head_nam   = 'wrfout_d03';
cfg.Save_nam   = 'TC';

cfg.resolution = 3;   % km; model resolution
cfg.dR         = 1;   % km; smoothing resolution
cfg.TCR        = 500; % km; 2 km pressure center search radius
cfg.TWR        = 500; % km; VMAX search radius
end
