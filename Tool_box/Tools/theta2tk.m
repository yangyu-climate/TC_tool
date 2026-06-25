function tk = theta2tk(theta,p)
Rd   = 287;           % J kg−1 K−1  Gas constant for dry air
cp   = 7*Rd/2;        % J kg−1 K−1  Specific heat of dry air at constant pressure
p0   = 100000;        % Pa          Standard reference pressure

M    = (p0./p).^(Rd/cp);
tk   = theta./M;
