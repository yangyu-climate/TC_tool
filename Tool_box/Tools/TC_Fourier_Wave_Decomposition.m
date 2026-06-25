function [WN0,WNL,WNS] = TC_Fourier_Wave_Decomposition(R,PHI,VAR,WN_lim)

if nargin<4
    WN_lim=10;
end

% TC_Fourier_Wave_Decomposition
% f = a0/2 + sum ( an*cos(nx) + bn*sin(nx) )

Large_Wave_N = [1 2];
Small_Wave_N = [3:WN_lim];

DSize = length(size(VAR));
[L,M] = size(R);

if DSize==3
  for k=1:size(VAR,1)
    for i=1:size(VAR,3)
      X = squeeze(PHI(:,i));
      Y = squeeze(VAR(k,:,i));
      [wn0,wnA] = Fourier_Wave_Decomposition_1D(X,Y,WN_lim);
      WN0(k,:,i)  = wn0;
      WNL(k,:,i)  = squeeze(nansum(wnA(Large_Wave_N,:)));
      WNS(k,:,i)  = squeeze(nansum(wnA(Small_Wave_N,:)));
    end
  end
elseif DSize==2
  for i=1:size(VAR,2)
    X = squeeze(PHI(:,i));
    Y = squeeze(VAR(:,i));
    [wn0,wnA] = Fourier_Wave_Decomposition_1D(X,Y,WN_lim);
    WN0(:,i)  = wn0;
    WNL(:,i)  = squeeze(nansum(wnA(Large_Wave_N,:)));
    WNS(:,i)  = squeeze(nansum(wnA(Small_Wave_N,:)));
  end
end
