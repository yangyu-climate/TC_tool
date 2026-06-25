%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add the paths of the different toolboxes
%
%  Copyright (c) 
%  e-mail: clarkyuchina@live.com
%
%  Updated    11-Apr-2015 by Clark
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Add the paths of the different toolboxes')

if ~exist('Run_dir','var') || isempty(Run_dir)
    Run_dir = fileparts(mfilename('fullpath'));
    if isempty(Run_dir)
        Run_dir = pwd;
    end
end

mypath = fullfile(Run_dir,'Tool_box');
addpath(mypath)
%
% Other software directories
%
if ispc
    start_windows
else
    start_linux
end
