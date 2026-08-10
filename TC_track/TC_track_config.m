function cfg = TC_track_config

cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8 6];
cfg.Ini_loc  = [135.8 11.4]; % Lon, Lat

cfg.Input_dir  = '../Pre/SLP/DATA';
cfg.Head_nam   = 'wrfout_d03';
cfg.Save_nam   = 'TC';

cfg.resolution = 3;   % km; model resolution
cfg.dR         = 1;   % km; smoothing resolution
cfg.TCR        = 500; % km; 2-km-pressure centre search radius
cfg.TWR        = 500; % km; maximum-wind search radius
% Reject candidate jumps faster than this value.  Set Inf only for a
% deliberate sensitivity test without temporal track quality control.
cfg.Max_track_speed_ms = 50; % m s-1
% Defer the gate while the track locks onto the initial vortex.  This avoids
% rejecting a legitimate early correction from an approximate Ini_loc.
cfg.Track_speed_gate_start_hours = 24;
end
