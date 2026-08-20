function tc_assert_earth_relative_wind(u_file,v_file,u_var,v_var)
%TC_ASSERT_EARTH_RELATIVE_WIND Require east/north components from preprocessing.
% Older TC_tool products contain WRF projected-grid ua/va components.  Those
% cannot be mixed with geographic storm-track translation velocities.
% By default this validates variables u and v.  Supply u_var/v_var for
% earth-relative vector tendencies such as RUBLTEN and RVBLTEN.

if nargin<3
    u_var = 'u';
    v_var = 'v';
elseif nargin~=4
    error('TC_tool:WindCoordinateArguments',...
        'Provide both eastward and northward variable names, or neither.')
end

assert_component(u_file,u_var,'eastward')
assert_component(v_file,v_var,'northward')
end

function assert_component(file_name,var_name,expected)
try
    info = ncinfo(file_name,var_name);
catch exception
    error('TC_tool:WindCoordinateFile',...
        'Cannot inspect %s in %s: %s',var_name,file_name,exception.message)
end

names = {info.Attributes.Name};
index = find(strcmp(names,'components'),1);
if isempty(index) || ~strcmpi(string(info.Attributes(index).Value),expected)
    error('TC_tool:WindCoordinateSystem',...
        ['%s must carry components="%s". Regenerate preprocessing with the ',...
         'current Pre/BGT or Pre/PHY NCL script; grid-relative ua/va products ',...
         'are incompatible with the geographic storm-following diagnostics.'],...
        file_name,expected)
end
end
