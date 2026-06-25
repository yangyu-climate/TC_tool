function [VAR_HADV,VAR_VADV] = Budget_Advection_Pressure(var_name,u_name,v_name,w_name,...
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

disp(['Calculating... : ',var_name,' Advection    M_option: ',num2str(M_option)])
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
ZZ  = Z;
for k=1:size(Z,1)
  XX(k,:,:) = X;
  YY(k,:,:) = Y;
  if smooth_number>0
  for smoothN = 1:smooth_number
      U(k,:,:) = running_mean_2D(squeeze(U(k,:,:)),smooth_point);
      V(k,:,:) = running_mean_2D(squeeze(V(k,:,:)),smooth_point);
      W(k,:,:) = running_mean_2D(squeeze(W(k,:,:)),smooth_point);
      T(k,:,:) = running_mean_2D(squeeze(T(k,:,:)),smooth_point);
  end
  end
end
[X_y,X_z,DX] = gradient(XX);
[DY,Y_z,Y_x] = gradient(YY);
[Z_y,DZ,Z_x] = gradient(ZZ);
    
T_R = NaN*ones(size(T));
T_L = NaN*ones(size(T));
U_R = NaN*ones(size(T));
U_L = NaN*ones(size(T));

T_F = NaN*ones(size(T));
T_B = NaN*ones(size(T));
V_F = NaN*ones(size(T));
V_B = NaN*ones(size(T));

T_U = NaN*ones(size(T));
T_D = NaN*ones(size(T));
W_U = NaN*ones(size(T));
W_D = NaN*ones(size(T));

% right boundary
T_R(:,2:end-1,2:end-1) = (T(:,2:end-1,2:end-1)...
                         +T(:,2:end-1,3:end  ))/2;
U_R(:,2:end-1,2:end-1) = (U(:,2:end-1,2:end-1)...
                         +U(:,2:end-1,3:end  ))/2;
F_R = U_R.*T_R;
% left boundary
T_L(:,2:end-1,2:end-1) = (T(:,2:end-1,2:end-1)...
                         +T(:,2:end-1,1:end-2))/2;
U_L(:,2:end-1,2:end-1) = (U(:,2:end-1,2:end-1)...
                         +U(:,2:end-1,1:end-2))/2;
F_L = U_L.*T_L;
% front boundary
T_F(:,2:end-1,2:end-1) = (T(:,2:end-1,2:end-1)...
                         +T(:,3:end  ,2:end-1))/2;
V_F(:,2:end-1,2:end-1) = (V(:,2:end-1,2:end-1)...
                         +V(:,3:end  ,2:end-1))/2;
F_F = V_F.*T_F;
% back boundary
T_B(:,2:end-1,2:end-1) = (T(:,2:end-1,2:end-1)...
                         +T(:,1:end-2,2:end-1))/2;
V_B(:,2:end-1,2:end-1) = (V(:,2:end-1,2:end-1)...
                         +V(:,1:end-2,2:end-1))/2;
F_B = V_B.*T_B;
% up boundary
T_U(2:end-1,:,:)       = (T(2:end-1,:,:)...
                         +T(3:end  ,:,:))/2;
W_U(2:end-1,:,:)       = (W(2:end-1,:,:)...
                         +W(3:end  ,:,:))/2;
F_U = W_U.*T_U;
% down boundary
T_D(2:end-1,:,:)       = (T(2:end-1,:,:)...
                         +T(1:end-2,:,:))/2;
W_D(2:end-1,:,:)       = (W(2:end-1,:,:)...
                         +W(1:end-2,:,:))/2;
F_D = W_D.*T_D;

F_X      = F_L-F_R;
F_Y      = F_B-F_F;
F_Z      = F_D-F_U;

VAR_HADV = - F_X./DX - F_Y./DY;
VAR_VADV = - F_Z./DZ;
%--------------------------------------------------------------------------
elseif M_option==2
[GT_x,GT_y,GT_z] = get_grad(X,Y,Z,T);

VAR_HADV = GT_x.*u + GT_y.*v;
VAR_VADV = GT_z.*w;
%--------------------------------------------------------------------------
elseif M_option==3
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
[GuT_x,GuT_y,GuT_z] = get_grad(X,Y,Z,U.*T);
[GvT_x,GvT_y,GvT_z] = get_grad(X,Y,Z,V.*T);
[GwT_x,GwT_y,GwT_z] = get_grad(X,Y,Z,W.*T);

[Gu_x,Gu_y,Gu_z] = get_grad(X,Y,Z,U);
[Gv_x,Gv_y,Gv_z] = get_grad(X,Y,Z,V);
[Gw_x,Gw_y,Gw_z] = get_grad(X,Y,Z,W);

VAR_HADV = GuT_x - T.*Gu_x...
         + GvT_y - T.*Gv_y;
VAR_VADV = GwT_z - T.*Gw_z;  
%--------------------------------------------------------------------------
    
end
