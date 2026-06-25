function q = qsat(Ta,Pa)

% QSAT: computes specific humidity at saturation. 
% q=QSAT(Ta) computes the specific humidity (kg/kg) at satuation at
% air temperature Ta (deg C). Dependence on air pressure, Pa, is small,
% but is included as an optional input.
%
%    INPUT:   Ta - air temperature  [C]
%             Pa - (optional) pressure [mb]
%
%    OUTPUT:  q  - saturation specific humidity  [kg/kg]

% Version 1.0 used Tetens' formula for saturation vapor pressure 
% from Buck (1981), J. App. Meteor., 1527-1532.  This version 
% follows the saturation specific humidity computation in the COARE
% Fortran code v2.5b.  This results in an increase of ~5% in 
% latent heat flux compared to the calculation with version 1.0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3/8/97: version 1.0
% 4/7/99: version 1.2 (revised as above by AA)
% 8/5/99: version 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==1,
  as_consts;
  Pa = P_default; % pressure in mb
end;

% original code
% a=(1.004.*6.112*0.6220)./Pa;
% q=a.*exp((17.502.*Ta)./(240.97+Ta))

% as in Fortran code v2.5b for COARE
ew = 6.11210 * ( 1.0007 + 3.46e-6 * Pa ) .* exp(17.502*Ta./(240.97+Ta)); % in mb
q  = 0.62197 * ew ./ ( Pa - 0.378*ew );                         % mb -> kg/kg

function as_consts

% AS_CONSTS: returns values of many constants used in AIR_SEA TOOLBOX
% AS_CONSTS: returns values of many constants used in the AIR_SEA
% TOOLBOX.  At end of this file are values of constants from COARE
% to be used when running the test program t_hfbulktc.m 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8/19/98: version 1.1 (contributed by RP)
% 4/7/99: version 1.2 (revised to include COARE test values by AA)
% 8/5/99: version 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------- physical constants

g           = 9.8;       % acceleration due to gravity [m/s^2]
sigmaSB     = 5.6697e-8; % Stefan-Boltzmann constant [W/m^2/K^4]
eps_air     = 0.62197;   % molecular weight ratio (water/air)
gas_const_R = 287.04;    % gas constant for dry air [J/kg/K]
CtoK        = 273.16;    % conversion factor for [C] to [K]


% ------- meteorological constants

kappa          = 0.4;    % von Karman's constant
Charnock_alpha = 0.011;  % Charnock constant (for determining roughness length
                         % at sea given friction velocity), used in Smith
                         % formulas for drag coefficient and also in Fairall
                         % and Edson.  use alpha=0.011 for open-ocean and 
                         % alpha=0.018 for fetch-limited (coastal) regions. 
R_roughness   = 0.11;    % limiting roughness Reynolds # for aerodynamically 
                         % smooth flow         
                         
                        
% ------ defaults suitable for boundary-layer studies

%cp           = 1004.7;   % heat capacity of air [J/kg/K]
cpp           = 1004.7;   % heat capacity of air [J/kg/K]
rho_air       = 1.22;     % air density (when required as constant) [kg/m^2]
Ta_default    = 10;       % default air temperature [C]
P_default     = 1020;     % default air pressure for Kinneret [mbars]
psych_default = 'screen'; % default psychmometer type (see relhumid.m)
Qsat_coeff    = 0.98;     % satur. specific humidity coefficient reduced 
                          % by 2% over salt water


% the following are useful in hfbulktc.m 
%     (and are the default values used in Fairall et al, 1996)

CVB_depth     = 600; % depth of convective boundary layer in atmosphere [m]
min_gustiness = 0.5; % min. "gustiness" (i.e., unresolved fluctuations) [m/s]
                     % should keep this strictly >0, otherwise bad stuff
                     % might happen (divide by zero errors)
beta_conv     = 1.25;% scaling constant for gustiness


% ------ short-wave flux calculations

Solar_const = 1368.0; % the solar constant [W/m^2] represents a 
                      % mean of satellite measurements made over the 
                      % last sunspot cycle (1979-1995) taken from 
                      % Coffey et al (1995), Earth System Monitor, 6, 6-10.
                      
                      
% ------ long-wave flux calculations

emiss_lw = 0.985;     % long-wave emissivity of ocean from Dickey et al
                      % (1994), J. Atmos. Oceanic Tech., 11, 1057-1076.

bulkf_default = 'berliand';  % default bulk formula when downward long-wave
                             % measurements are not made.

%*************************************************

n = whos;
n = {n.name};

for nn = n(:)'
    assignin('caller',nn{1},eval(nn{1}));
end