function cfg = TC_KEBG_config

cfg.Time_beg = [2011 7 28];
cfg.Time_end = [2011 8 6];
cfg.Time_frq = 15; % minute
cfg.Radius = 300; % km
cfg.dR = 1; % km
cfg.dPhi = pi/180; % rad
cfg.Track_file = '../TC_track/Result/Track_data.mat';
cfg.Head_nam = 'wrfout_d03';
cfg.Kday_to_Ks      = 1/(24*60*60);
% The supplied TC track is the sole cylindrical centre definition.

cfg.Input_dir  = '../Pre/BGT/DATA';
cfg.Save_nam   = 'KEBG';

% Bhalachandran et al. (2020) scale-interaction energetics
% All terms are diagnosed after cylindrical remapping on fixed isobaric levels.
cfg.calc.Pressure_levels_hPa = 1000:-25:100;
cfg.calc.Cp = 1005;          % J kg-1 K-1
cfg.calc.Rd = 287;           % J kg-1 K-1
cfg.calc.Budget_Radius = 300; % km, as in the paper
cfg.calc.Max_WN = Inf;       % Inf: every resolvable azimuthal WN
cfg.calc.Heating_is_theta_tendency = true;
% WRF H_DIABATIC, RTHRATEN, RTHBLTEN and RTHCUTEN are treated as
% potential-temperature tendencies (K s-1); calculate converts to dT/dt.
cfg.calc.Run_self_test = true;
% The published A3/A4 notation omits Cp although its gamma contains 1/Cp.
% ``dimensionally_consistent'' returns J kg-1 and W kg-1; ``paper_literal''
% is retained only for a direct sensitivity comparison with the printed form.
cfg.calc.APE_convention = 'dimensionally_consistent';
% Finite-difference energy tendency minus the resolved A1--A6 pathways.
cfg.calc.Diagnose_equation_closure = true;
cfg.calc.Save_full_triad_tensor = false;
cfg.calc.Triad_precision = 'single'; % one file is about 2.9 GB at default grid
end
