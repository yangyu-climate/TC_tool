caxis([-100 40])
CS = 10;
c3 = 1-gray(CS*8+1);
c2 = hsv(CS*7);
c1 = gray(CS+1);
c  = [c1;c2;c3];
colormap(c)            

h = colorbar;
h.Ticks=[-90:10:-30];
h.Label.String='Brightness Temperature in (10.3-11.3 um)';
h.Label.FontSize = 12;
h.LineWidth = 1.2;
h.TickLength = .06;
h.FontSize   = 12;
h.YDir='reverse';