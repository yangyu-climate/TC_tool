function [files,matched_name] = tc_find_time_file(data_dir,head_name,TIME,suffix)
%TC_FIND_TIME_FILE Find a timestamped file in new or historic name format.
% New HH_MM_SS names are preferred; HH:MM:SS remains readable on Linux.

files = [];
matched_name = '';
for legacy = [false true]
    name = tc_time_name(TIME,legacy);
    files = dir(fullfile(data_dir,[head_name,'*',name,suffix]));
    if ~isempty(files)
        [~,order] = sort({files.name});
        files = files(order);
        matched_name = name;
        return
    end
end
end
