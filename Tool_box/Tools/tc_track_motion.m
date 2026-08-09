function [u_ms,v_ms] = tc_track_motion(time,lat,lon,center_valid)
% Geodesic finite-difference velocity of a valid storm-centre track.
n=numel(time); u_ms=NaN(size(time)); v_ms=NaN(size(time));
assert(numel(lat)==n && numel(lon)==n,'TC_tool:TrackShape','Track arrays must have equal length')
if nargin<4 || isempty(center_valid), center_valid=true(size(time)); end
assert(numel(center_valid)==n,'TC_tool:TrackShape','Track validity mask must match track time')
center_valid=logical(center_valid(:)');
for k=1:n
    if ~center_valid(k), continue, end
    if n==1, continue, end
    if k==1
        if ~center_valid(2), continue, end
        i1=1; i2=2;
    elseif k==n
        if ~center_valid(n-1), continue, end
        i1=n-1; i2=n;
    else
        % Do not bridge a held/missing centre: the velocity is undefined at
        % either side of an unresolved track gap.
        if ~center_valid(k-1) || ~center_valid(k+1), continue, end
        i1=k-1; i2=k+1;
    end
    dt_s=(time(i2)-time(i1))*86400;
    assert(isfinite(dt_s) && dt_s>0,'TC_tool:TrackTime','Track time must be strictly increasing')
    [~,dx,dy]=tc_great_circle_xy(lat(i2),lon(i2),lat(i1),lon(i1));
    u_ms(k)=dx*1000/dt_s; v_ms(k)=dy*1000/dt_s;
end
end
