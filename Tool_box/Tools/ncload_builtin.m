function var = ncload_builtin(file_name,var_name)

    ncid = netcdf.open(file_name,'NOWRITE');
    cleanup = onCleanup(@() netcdf.close(ncid));

    varid = netcdf.inqVarID(ncid,var_name);
    var = netcdf.getVar(ncid,varid);
    if ndims(var) > 1
        var = permute(var,ndims(var):-1:1);
    end

    missV = read_attr(ncid,varid,'missing_value');
    fillV = read_attr(ncid,varid,'_FillValue');
    scale = read_attr(ncid,varid,'scale_factor');
    ofset = read_attr(ncid,varid,'add_offset');

    if isnumeric(var)
        var = double(var);
    end

    var = replace_missing(var,missV);
    var = replace_missing(var,fillV);

    if ~isempty(scale)
        var = var*double(scale);
    end

    if ~isempty(ofset)
        var = var+double(ofset);
    end

    var = squeeze(var);

end

function attr = read_attr(ncid,varid,attr_name)

    try
        attr = netcdf.getAtt(ncid,varid,attr_name);
    catch
        attr = [];
    end

end

function var = replace_missing(var,missing_values)

    if isempty(missing_values) || ~isnumeric(var)
        return
    end

    missing_values = double(missing_values(:));
    for i = 1:numel(missing_values)
        if isnan(missing_values(i))
            var(isnan(var)) = NaN;
        else
            var(var == missing_values(i)) = NaN;
        end
    end

end
