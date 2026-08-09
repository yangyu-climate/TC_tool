function [index,time_error] = tc_match_track_time(track_time,target_time,tolerance_day,center_valid)
% Nearest valid track point, accepted only within the supplied tolerance.
track_time=track_time(:);
if nargin<4 || isempty(center_valid), center_valid=true(size(track_time)); end
assert(numel(center_valid)==numel(track_time),'TC_tool:TrackShape','Track validity mask must match track time')
distance=abs(track_time-target_time);
distance(~logical(center_valid(:)))=Inf;
[time_error,index] = min(distance);
if isempty(index) || ~isfinite(time_error) || time_error>tolerance_day
    index=[];
end
end
