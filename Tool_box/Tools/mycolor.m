function map = mycolor(colormapFile,m)
%PARULA Blue-green-orange-yellow color map
%   PARULA(M) returns an M-by-3 matrix containing a colormap. 
%   The colors begin with dark purplish-blue and blue, range
%   through green and orange, and end with bright yellow. PARULA is named
%   after a bird, the tropical parula, which has these colors.
%
%   PARULA returns a colormap with the same number of colors as the current
%   figure's colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   EXAMPLE
%
%   This example shows how to reset the colormap of the current figure.
%
%       colormap(parula)
%
%   See also AUTUMN, BONE, COLORCUBE, COOL, COPPER, FLAG, GRAY, HOT, HSV,
%   JET, LINES, PINK, PRISM, SPRING, SUMMER, WHITE, WINTER, COLORMAP,
%   RGBPLOT.

%   Copyright 2013-2016 The MathWorks, Inc.

if nargin ==1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

load(colormapFile);
values = mymap;

P = size(values,1);
map = interp1(1:size(values,1), values, linspace(1,P,m), 'linear');
