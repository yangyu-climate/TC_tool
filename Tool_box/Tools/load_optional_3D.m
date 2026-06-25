function var = load_optional_3D(file_name,var_name,template)

if ~isempty(dir(file_name))
    var = ncload_3D(file_name,var_name);
else
    var = zeros(size(template));
end
end