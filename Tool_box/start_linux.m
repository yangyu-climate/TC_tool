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
%
% Other software directories
%
addpath(fullfile(mypath,'m_map'))
addpath(fullfile(mypath,'ocean'))
addpath(fullfile(mypath,'coastline'))
addpath(fullfile(mypath,'Tools'))
addpath(fullfile(mypath,'SPDec'))
addpath(fullfile(mypath,'ncl_color'))
addpath(fullfile(mypath,'ncl_color','ncl_rgb'))
%
%-------------------------------------------------------
%
% Get the path to the mexcdf (it depends on the architecture)
mysystem = computer('arch');
if ~isempty(strfind(mysystem,'64'))
  mysystem2='64';
else
  mysystem2='32';
end

matversion=version('-release');
myversion=str2num(matversion(1:2));
disp(['Arch : ',mysystem,' - Matlab version : ',matversion])


if ((myversion > 13)    )
  disp(['Use of mexnc and loaddap in ',mysystem2,' bits.'])
  addpath(fullfile(mypath,'mexcdf','mexnc'))   % 32 and 64 bits version of mexnc
%
% - If these directories are already in your matlab native path, 
% you can comment these lines
addpath(fullfile(mypath,'mexcdf','netcdf_toolbox','netcdf'))
addpath(fullfile(mypath,'mexcdf','netcdf_toolbox','netcdf','ncsource'))
addpath(fullfile(mypath,'mexcdf','netcdf_toolbox','netcdf','nctype'))
addpath(fullfile(mypath,'mexcdf','netcdf_toolbox','netcdf','ncutility'))
%
%-------------------------------------------------------
elseif (myversion <= 13)
  disp('Use of mex60 and loaddap in 32 bits.')
  addpath(fullfile(mypath,'mex60'))         % Older/32 bits version of mexcdf

% - If these directories are already in your matlab native path, 
% you can comment these lines
% - In this case, if problems with subsrefs.m ans subsasign.m,
% it is because there is a conflict with another native subs.m routines in the
% symbolic native toolbox
addpath(fullfile(mypath,'netcdf_matlab_60'))
addpath(fullfile(mypath,'netcdf_matlab_60','ncfiles'))
addpath(fullfile(mypath,'netcdf_matlab_60','nctype'))
addpath(fullfile(mypath,'netcdf_matlab_60','ncutility'))

else
  disp(['Arch : ',mysystem,...
       ' you should provide the paths of your own loaddap and mexcdf directories'])
end

%-----------------------------------------------------------------
% If your Linux distribution is FEDORA 4, you can try to install
% opendap by uncommenting these lines. Otherwise you have to compile and
% install the libdap and loaddap library and executable on tour computer manually
% and add the specific path
%
%addpath([mypath,'Opendap_tools/FEDORA']) %tested on matlab6 / fedora4
%addpath([mypath,'Opendap_tools/FEDORA_X64']) % 64bits version of loaddap
