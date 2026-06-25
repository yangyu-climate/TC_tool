function VAR_DIV = Budget_Divergence_Pressure(var_name,u_name,v_name,w_name,...
                                              TIME,del_T,Data_dir,Head_nam,M_option)
% Calculate U*delta(var)
                               
if nargin<9
    M_option=1;
end
smooth_number = 2;
smooth_point  = 3;                               
                               
x_name  = 'x';
y_name  = 'y';
% x_name  = 'lon';
% y_name  = 'lat';
% Changed by Yang %20220630

disp(['Calculating... : ',var_name,' Divergence    M_option: ',num2str(M_option)])
disp(['by components: ',u_name,', ',v_name,', ',w_name])

file_TN = get_Tname_file(TIME,Data_dir,Head_nam);
x       = load_data(file_TN,x_name);
y       = load_data(file_TN,y_name);
X       = load_data(file_TN,'x')*1000;
Y       = load_data(file_TN,'y')*1000;
Z       = load_data(file_TN,'P')*100;

%at the moment
fileT  = file_TN;
file_TB= fileT;
x_T    = load_data(file_TB,x_name);
y_T    = load_data(file_TB,y_name);
var_T  = load_data(file_TB,var_name);
u_T    = load_data(file_TB,u_name);
v_T    = load_data(file_TB,v_name);
w_T    = load_data(file_TB,w_name);
if nansum(nansum(abs(x_T-x)+abs(y_T-y)))>0
    for k = 1:size(var_T,1)
        var_B(k,:,:) = griddata(x_T,y_T,squeeze(var_T(k,:,:)),x,y);
        u_B(k,:,:)   = griddata(x_T,y_T,squeeze(  u_T(k,:,:)),x,y);
        v_B(k,:,:)   = griddata(x_T,y_T,squeeze(  v_T(k,:,:)),x,y);
        w_B(k,:,:)   = griddata(x_T,y_T,squeeze(  w_T(k,:,:)),x,y);
    end
else
    var_B = var_T;
    u_B   =   u_T;
    v_B   =   v_T;
    w_B   =   w_T;
end

%forward
fileT = get_Tname_file(TIME+del_T,Data_dir,Head_nam);
if isempty(fileT)
    fileT = file_TN;
end
file_TF= fileT;
x_T    = load_data(file_TF,x_name);
y_T    = load_data(file_TF,y_name);
var_T  = load_data(file_TF,var_name);
u_T    = load_data(file_TF,u_name);
v_T    = load_data(file_TF,v_name);
w_T    = load_data(file_TF,w_name);
if nansum(nansum(abs(x_T-x)+abs(y_T-y)))>0
    for k = 1:size(var_T,1)
        var_F(k,:,:) = griddata(x_T,y_T,squeeze(var_T(k,:,:)),x,y);
        u_F(k,:,:)   = griddata(x_T,y_T,squeeze(  u_T(k,:,:)),x,y);
        v_F(k,:,:)   = griddata(x_T,y_T,squeeze(  v_T(k,:,:)),x,y);
        w_F(k,:,:)   = griddata(x_T,y_T,squeeze(  w_T(k,:,:)),x,y);
    end
else
    var_F = var_T;
    u_F   =   u_T;
    v_F   =   v_T;
    w_F   =   w_T;
end

T   = (var_B+var_F)/2;
u   = (u_B  +u_F  )/2;
v   = (v_B  +v_F  )/2;
w   = (w_B  +w_F  )/2;

%--------------------------------------------------------------------------
if M_option==1
U   = u;
V   = v;
W   = w;
for k=1:size(Z,1)
  if smooth_number>0
  for smoothN = 1:smooth_number
      U(k,:,:) = running_mean_2D(squeeze(U(k,:,:)),smooth_point);
      V(k,:,:) = running_mean_2D(squeeze(V(k,:,:)),smooth_point);
      W(k,:,:) = running_mean_2D(squeeze(W(k,:,:)),smooth_point);
      T(k,:,:) = running_mean_2D(squeeze(T(k,:,:)),smooth_point);
  end
  end
end

[Gu_x,Gu_y,Gu_z] = get_grad(X,Y,Z,U);
[Gv_x,Gv_y,Gv_z] = get_grad(X,Y,Z,V);
[Gw_x,Gw_y,Gw_z] = get_grad(X,Y,Z,W);
VAR_DIV = T.*(Gu_x+Gv_y);      
%--------------------------------------------------------------------------
    
end
