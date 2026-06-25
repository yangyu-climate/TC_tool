function thetaE= get_thetaE(tk,p,rh,qv,qw)
Rd   = 287;           % J kg−1 K−1  Gas constant for dry air
Rv   = 461.6;         % J kg−1 K−1  Gas constant for water vapor
cp   = 7*Rd/2;        % J kg−1 K−1  Specific heat of dry air at constant pressure
cliq = 4190;          % J kg−1 K−1  Specific heat capacity of water
Lv   = 2.5 *10^6;     % J kg−1      Latent heat of vaporization
p0   = 100000;        % Pa          Standard reference pressure
T0   = 273.15;        % K
e0   = 611;           % Pa

es   = e0*exp(Lv/Rv*(1/T0-1./tk));
pd   = p-rh.*es;

if nargin>4
rtc  = (qv+qw)*cliq;
else
rtc  = 0;
end
Cp   = cp+rtc;

Pi   = (p0./pd).^(Rd./Cp);
Hi   = rh.^(-Rv*qv./Cp);
Vi   = exp(Lv*qv./(tk.*Cp));

thetaE = tk.*Pi.*Hi.*Vi;
