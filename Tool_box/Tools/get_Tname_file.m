function fileN = get_Tname_file(TIME,Data_dir,Head_nam)

window_opt = 0;

[year_num,month_num,day_num,...
 hour_num,minu_num,seco_num]    = date2str(TIME);
if window_opt
    T_name = [year_num,'-',month_num,'-',day_num,'_',...
              hour_num,'_',minu_num,'_',seco_num];
else
    T_name = [year_num,'-',month_num,'-',day_num,'_',...
              hour_num,':',minu_num,':',seco_num];
end
file_name = [Head_nam,'*',T_name,'.mat'];
filename  = dir([Data_dir,'/',file_name]);
if isempty(filename)
    fileN = [];
else
    fileN = filename.name;
    fileN = [Data_dir,'/',fileN];
end

