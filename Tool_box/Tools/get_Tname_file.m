function fileN = get_Tname_file(TIME,Data_dir,Head_nam)

[filename,~] = tc_find_time_file(Data_dir,Head_nam,TIME,'.mat');
if isempty(filename)
    fileN = [];
else
    fileN = filename.name;
    fileN = [Data_dir,'/',fileN];
end

