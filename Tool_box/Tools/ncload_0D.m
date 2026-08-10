function var = ncload_0D(file_name,var_name)

    var = ncload_builtin(file_name,var_name);
    if isnumeric(var)
        var = double(var);
    end
