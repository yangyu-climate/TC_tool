function [year,month,day,hour,minu,seco] = date2num(T);

T     = round(T*24*60*60)/(24*60*60);
TIME  = datevec(T);
year  = TIME(1);
month = TIME(2);
day   = TIME(3);
hour  = TIME(4);
minu  = TIME(5);
seco  = round(TIME(6));
