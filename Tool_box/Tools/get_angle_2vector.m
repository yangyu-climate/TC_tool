function angle = get_angle_2vector(x1,y1,x2,y2)

uwind = x2;
vwind = y2;
u     = x1;
v     = y1;

[uwind,vwind] = normalize_vector(uwind,vwind);
[u    ,v    ] = normalize_vector(u    ,v    );

base_angle1   = get_angle(u    ,v    );
base_angle2   = get_angle(uwind,vwind);


X     = uwind - u;
Y     = vwind - v;
L     = sqrt(X^2+Y^2);

if L == 0
    angle = 0;
else
    A     = acos(L/2)/pi*180;
    angle = 180 -2*A;
end

if abs(base_angle2-base_angle1)>180
    if base_angle2<base_angle1
        base_angle2 = base_angle2+360;
    else
        base_angle1 = base_angle1+360;
    end
end

if base_angle1>base_angle2
    angle = -angle;
end
    
    