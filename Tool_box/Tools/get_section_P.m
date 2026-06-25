function [lon,lat] = get_section_P(position_begin,position_end,dl)


P1 = position_begin;
P2 = position_end;

if P1(1)<P2(1)
    dll = dl; 
    lon = P1(1):dll:P2(1);
    if (P2(2)-P1(2))~=0
        dll = dll*(P2(2)-P1(2))/(P2(1)-P1(1));
        lat = P1(2):dll:P2(2);
    else
        lat = P1(2)*ones(size(lon));
    end
elseif P1(1)>P2(1)
    dll = -dl; 
    lon = P1(1):dll:P2(1);
    if (P2(2)-P1(2))~=0
        dll = dll*(P2(2)-P1(2))/(P2(1)-P1(1));
        lat = P1(2):dll:P2(2);
    else
        lat = P1(2)*ones(size(lon));
    end
elseif P1(2)<P2(2)
    dll = dl;
    lat = P1(2):dll:P2(2);
    lon = P1(1)*ones(size(lat));
else
    dll = -dl;
    lat = P1(2):dll:P2(2);
    lon = P1(1)*ones(size(lat));
end