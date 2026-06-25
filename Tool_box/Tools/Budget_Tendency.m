function [VAR_TEND_F,VAR_TEND_M] = Budget_Tendency(var_name,TIME,del_T,Data_dir,Head_nam)

x_name  = 'x';
y_name  = 'y';
X_name  = 'lon';
Y_name  = 'lat';
% Changed by Yang %20210226

D_to_S  = 24*60*60;
dt      = 2*del_T*D_to_S;

disp(['Calculating... : ',var_name,' Tendency'])
file_TN = get_Tname_file(TIME,Data_dir,Head_nam);
x       = load_data(file_TN,x_name);
y       = load_data(file_TN,y_name);
X       = load_data(file_TN,X_name);
Y       = load_data(file_TN,Y_name);

%at the moment
fileT = []; %Yang 20210219
if isempty(fileT)
    dt    = dt/2;
    fileT = file_TN;
end
file_TB= fileT;
x_T    = load_data(file_TB,x_name);
y_T    = load_data(file_TB,y_name);
X_T    = load_data(file_TB,X_name);
Y_T    = load_data(file_TB,Y_name);
var_T  = load_data(file_TB,var_name);
if nansum(nansum(abs(x_T-x)+abs(y_T-y)))>0
    for k = 1:size(var_T,1)
        var_B(k,:,:) = griddata(x_T,y_T,squeeze(var_T(k,:,:)),x,y); 
    end
else
    var_B = var_T;
end
if nansum(nansum(abs(X_T-X)+abs(Y_T-Y)))>0
    for k = 1:size(var_T,1)
        VAR_B(k,:,:) = griddata(X_T,Y_T,squeeze(var_T(k,:,:)),X,Y); 
    end
else
    VAR_B = var_T;
end

%forward
fileT = get_Tname_file(TIME+del_T,Data_dir,Head_nam);
if isempty(fileT)
    dt    = dt/2;
    fileT = file_TN;
end
file_TF= fileT;
x_T    = load_data(file_TF,x_name);
y_T    = load_data(file_TF,y_name);
X_T    = load_data(file_TF,X_name);
Y_T    = load_data(file_TF,Y_name);
var_T  = load_data(file_TF,var_name);  
if nansum(nansum(abs(x_T-x)+abs(y_T-y)))>0
    for k = 1:size(var_T,1)
        var_F(k,:,:) = griddata(x_T,y_T,squeeze(var_T(k,:,:)),x,y);
    end
else
    var_F = var_T;    
end
if nansum(nansum(abs(X_T-X)+abs(Y_T-Y)))>0
    for k = 1:size(var_T,1)
        VAR_F(k,:,:) = griddata(X_T,Y_T,squeeze(var_T(k,:,:)),X,Y);
    end
else
    VAR_F = var_T;    
end


VAR_TEND_F = (VAR_F-VAR_B)/dt;
VAR_TEND_M = (var_F-var_B)/dt;

