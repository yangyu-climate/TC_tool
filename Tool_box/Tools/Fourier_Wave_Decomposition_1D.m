function [WN0,WNA] = Fourier_Wave_Decomposition_1D(PHI,VAR,WN_lim)
    
if nargin<3
    WN_lim=10;
end

L = length(PHI);
A(1:L,1) = squeeze(PHI);
B(1:L,1) = squeeze(VAR);

loc0 = find(A==0);
if ~isempty(loc0)
    A = [A;2*pi];   
    B = [B;B(loc0)];
else
    locS = find(A==min(A));
    locL = find(A==max(A));
    A = [A(locL)-2*pi;A;A(locS)+2*pi];
    B = [B(locL)     ;B;B(locS)     ];
end

[a0,an,bn] = FourierSD(A,B,WN_lim);  

% F   = 0.5*a0 + sum ( an*cos(nx) + bn*sin(nx) )
% WN0 = 0.5*a0;
% WN  = an*cos(nx) + bn*sin(nx)

WN0(1,:) = 0.5*a0*ones(1,L);
for N=1:WN_lim
WNA(N,:) = an(N)*cos(N*PHI)...
         + bn(N)*sin(N*PHI);
end

