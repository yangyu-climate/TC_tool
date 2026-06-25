function [data]=distilldata_read(infile)
%功能说明：
%将保存数据的原始文件中的数值数据读入到一个data变量中（自动判断数据行）
%使用说明：
% infile——原始数据文件名;
% data=数据变量

tmpfile='tmp_file.mat';

fidin=fopen(infile,'r'); % 打开原始数据文件（.list）

fidtmp=fopen(tmpfile,'w'); % 创建保存数据文件（不含说明文字）

while ~feof(fidin) % 判断是否为文件末尾
  tline=fgetl(fidin); % 从文件读入一行文本（不含回车键）
  if ~isempty(tline) % 判断是否空行
    str = '[^0-9 | \. | \- | \s | e | E]'; %正则表达式为：该行中是否包含除 - . E e 数字 和 空白字符 外的其他字符
    start = regexp(tline,str, 'once');
    if isempty(start)
      fprintf(fidtmp,'%s\n',tline);
    end
  end
end

fclose(fidin);

fclose(fidtmp);

data=textread(tmpfile);

delete(tmpfile)
