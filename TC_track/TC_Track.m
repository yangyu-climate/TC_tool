clear
clc

Run_dir = ['../'];
addpath(Run_dir);
start

cfg = TC_track_config;

Data_dir = [pwd,'/Data'];
Save_dir = [pwd,'/Result'];
mkdir(Save_dir)
Time_beg = cfg.Time_beg;
Time_end = cfg.Time_end;
Ini_loc  = cfg.Ini_loc;
Max_track_speed_ms = cfg.Max_track_speed_ms;
Track_speed_gate_start_hours = cfg.Track_speed_gate_start_hours;
assert(isfinite(Max_track_speed_ms) && Max_track_speed_ms>0 || isinf(Max_track_speed_ms),...
    'TC_track:MaxTrackSpeed','Max_track_speed_ms must be positive or Inf')
assert(isscalar(Track_speed_gate_start_hours) && isfinite(Track_speed_gate_start_hours) && ...
    Track_speed_gate_start_hours>=0,...
    'TC_track:SpeedGateStart','Track_speed_gate_start_hours must be a nonnegative scalar.')

T_beg    = datenum(Time_beg);
T_end    = datenum(Time_end);
NUM      = 0;
last_valid_num = 0;
first_valid_time = NaN;

for T_D = T_beg:T_end
  T         = datevec(T_D);
  year      = T(1);
  month     = T(2);
  day       = T(3);
  year_num  = num2str(year);
  if month<10
    month_num = ['0',num2str(month)];
  else
    month_num = num2str(month);
  end
  if day<10
    day_num = ['0',num2str(day)];
  else
    day_num = num2str(day);
  end
  T_name   = [year_num,'-',month_num,'-',day_num];
  disp(T_name)
  file_name = ['*',T_name,'*'];
  filename  = dir([Data_dir,'/',file_name]);
  [~, order] = sort({filename.name});
  filename = filename(order);

  if ~isempty(filename)
    for N = 1:length(filename)
      NUM = NUM + 1; 
      file_name = filename(N).name;
      disp(file_name)
      fileN = [Data_dir,'/',file_name];
      % Keep the detection timestamp explicit.  Loading into a structure
      % prevents the saved scalar T from silently overwriting the outer-loop
      % date vector and preserves the exact WRF output time.
      D = load(fileN);
      detection_time = D.T;
      tc_lon = D.tc_lon;
      tc_lat = D.tc_lat;
      tc_p = D.tc_p;
      tc_w = D.tc_w;
      tw_lon = D.tw_lon;
      tw_lat = D.tw_lat;

      valid_center = isfinite(tc_lon) & isfinite(tc_lat);
      if any(valid_center)
        if last_valid_num==0
          x   = Ini_loc(1);
          y   = Ini_loc(2);
          [DD,~,~] = tc_great_circle_xy(tc_lat,tc_lon,y,x);
          DD(~valid_center) = Inf;
          [~, loc] = min(DD(:));
        else
          x   = LON(last_valid_num);
          y   = LAT(last_valid_num);
          [DD,~,~] = tc_great_circle_xy(tc_lat,tc_lon,y,x);
          DD(~valid_center) = Inf;
          dt_s = (detection_time-TIME(last_valid_num))*86400;
          if ~isfinite(dt_s) || dt_s<=0
              error('TC_track:TimeOrder','Detection times must be strictly increasing.')
          end
          if (detection_time-first_valid_time)*24 >= Track_speed_gate_start_hours
              DD(DD*1000/dt_s > Max_track_speed_ms) = Inf;
          end
          [~, loc] = min(DD(:));
        end
        if isfinite(DD(loc))
          CENTER_VALID(NUM) = true;
          CENTER_HELD(NUM) = false;
          LON(NUM)   = tc_lon(loc);
          LAT(NUM)   = tc_lat(loc);
          SLP(NUM)   = tc_p(loc);
          SWD(NUM)   = tc_w(loc);
          LON_W(NUM) = tw_lon(loc);
          LAT_W(NUM) = tw_lat(loc);
          TIME(NUM)  = detection_time;
          last_valid_num = NUM;
          if ~isfinite(first_valid_time)
              first_valid_time = detection_time;
          end
        elseif last_valid_num>0
          CENTER_VALID(NUM) = false;
          CENTER_HELD(NUM) = true;
          LON(NUM)   = LON(last_valid_num);
          LAT(NUM)   = LAT(last_valid_num);
          SLP(NUM)   = SLP(last_valid_num);
          SWD(NUM)   = SWD(last_valid_num);
          LON_W(NUM) = LON_W(last_valid_num);
          LAT_W(NUM) = LAT_W(last_valid_num);
          TIME(NUM)  = detection_time;
          warning('TC_track:SpeedGate','No candidate at %s satisfies the %.1f m s-1 speed gate; centre held.',...
              datestr(detection_time),Max_track_speed_ms)
        else
          NUM = NUM-1;
        end
      else
        if last_valid_num>0
          CENTER_VALID(NUM) = false;
          CENTER_HELD(NUM) = true;
          LON(NUM)   = LON(last_valid_num);
          LAT(NUM)   = LAT(last_valid_num);
          SLP(NUM)   = SLP(last_valid_num);
          SWD(NUM)   = SWD(last_valid_num);
          LON_W(NUM) = LON_W(last_valid_num);
          LAT_W(NUM) = LAT_W(last_valid_num);
          TIME(NUM)  = detection_time;
        else
          NUM = NUM-1;
        end
      end

    end
  end

end

save([Save_dir,'/Track_data.mat'],'TIME','LON','LAT','SLP','SWD','LON_W','LAT_W','CENTER_VALID','CENTER_HELD')
