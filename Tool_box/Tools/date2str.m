function [year_num,month_num,day_num,...
          hour_num,minu_num,seco_num] = date2str(T);

[year,month,day,hour,minu,seco] = date2num(T);

year_num = num2str(year);
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
if hour<10
    hour_num = ['0',num2str(hour)];
else
    hour_num = num2str(hour);
end
if minu<10
    minu_num = ['0',num2str(minu)];
else
    minu_num = num2str(minu);
end
if seco<10
    seco_num = ['0',num2str(seco)];
else
    seco_num = num2str(seco);
end
