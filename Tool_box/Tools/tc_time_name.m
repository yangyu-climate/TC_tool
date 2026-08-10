function name = tc_time_name(TIME,legacy)
%TC_TIME_NAME Cross-platform timestamp used in TC_tool result file names.
% New files use HH_MM_SS.  legacy=true returns the historic HH:MM:SS form.

if nargin < 2 || isempty(legacy)
    legacy = false;
end
[yy,mm,dd,hh,mi,ss] = date2str(TIME);
if legacy
    separator = ':';
else
    separator = '_';
end
name = [yy,'-',mm,'-',dd,'_',hh,separator,mi,separator,ss];
end
