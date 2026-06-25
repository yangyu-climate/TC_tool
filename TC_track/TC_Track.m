clear
clc

warning off
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

T_beg    = datenum(Time_beg);
T_end    = datenum(Time_end);
NUM      = 0;

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

  if ~isempty(filename)
    for N = 1:length(filename)
      NUM = NUM + 1; 
      file_name = filename(N).name;
      disp(file_name)
      fileN = [Data_dir,'/',file_name];
      load(fileN)

      if ~isnan(nanmean(tc_lon.*tc_lat))
        if NUM==1
          x   = Ini_loc(1);
          y   = Ini_loc(2);
          DD  = (tc_lon-x).^2 + (tc_lat-y).^2;
          loc = find(DD==min(DD));
          loc = min(loc);
          LON(NUM)   = tc_lon(loc);
          LAT(NUM)   = tc_lat(loc);
          SLP(NUM)   = tc_p(loc);
          SWD(NUM)   = tc_w(loc);
          LON_W(NUM) = tw_lon(loc);
          LAT_W(NUM) = tw_lat(loc);
          TIME(NUM)  = T;
        else
          x   = LON(NUM-1);
          y   = LAT(NUM-1);
          DD  = (tc_lon-x).^2 + (tc_lat-y).^2;
          loc = find(DD==min(DD));
          loc = min(loc);
          LON(NUM)   = tc_lon(loc);
          LAT(NUM)   = tc_lat(loc);
          SLP(NUM)   = tc_p(loc);
          SWD(NUM)   = tc_w(loc);
          LON_W(NUM) = tw_lon(loc);
          LAT_W(NUM) = tw_lat(loc);
          TIME(NUM)  = T;
        end
      else
        if NUM>1
          LON(NUM)   = LON(NUM-1);
          LAT(NUM)   = LAT(NUM-1);
          SLP(NUM)   = SLP(NUM-1);
          SWD(NUM)   = SWD(NUM-1);
          LON_W(NUM) = LON_W(NUM-1);
          LAT_W(NUM) = LAT_W(NUM-1);
          TIME(NUM)  = T;
        else
          NUM = NUM-1;
        end
      end

    end
  end

end

save([Save_dir,'/Track_data.mat'],'TIME','LON','LAT','SLP','SWD','LON_W','LAT_W')
