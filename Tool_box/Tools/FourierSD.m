function [a0,an,bn] = FourierSD(x,y,n)
% % Generate data
% n = 3;
% x = 0:2*pi/180:2*pi;
% y = 10+1*sin(x)-2*cos(2*x)+3*cos(3*x);

% Use FSERIES to fit
% f = a0/2 + sum ( an*cos(nx) + bn*sin(nx) )
[a,b] = Fseries(x,y,n);
a0 = a(1);
for i=1:length(b)
    an(i) = a(i+1)*(-1)^i;
    bn(i) = b(i)*(-1)^i;
end
