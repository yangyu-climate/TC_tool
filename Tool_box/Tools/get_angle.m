function angle = get_angle(x,y)

    F_C = 1/pi*180;

    [x,y] = normalize_vector(x,y);
    
    
    if x*y~=0
        if x>0
            angle = atan(y/x)*F_C;
        elseif x<0
            angle = atan(y/x)*F_C;
            angle = 180 + angle;       
        end
    else
        if x==0
            angle = sign(y)*90;
        elseif y==0
            if x>0
                angle = 0;
            else
                angle = 180;
            end
        else
            disp('Error in Vector')
            angle = MaN;
        end
    end
    
    if angle<0
        angle = angle+360;
    end
