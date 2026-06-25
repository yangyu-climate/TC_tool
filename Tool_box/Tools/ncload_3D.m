function var = ncload_3D(file_name,var_name)

    nc   = netcdf(file_name);
    var  = nc{var_name}(:);
    scale= nc{var_name}.scale_factor(:);
    ofset= nc{var_name}.add_offset(:);
    missV= nc{var_name}.missing_value(:);
    
    if ~isempty(missV)
        var(find(var==missV)) = NaN;
    end
    
    if ~isempty(scale)
        var = var*scale;
    end
    
    if ~isempty(ofset)
        var = var+ofset;
    end
    
    var = squeeze(var);

    close(nc)
