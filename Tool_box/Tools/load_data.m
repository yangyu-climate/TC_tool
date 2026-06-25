function data = load_data(name,varname)

    if nargin >1
        data = cell2mat(struct2cell(load(name,varname)));
    else
        data = cell2mat(struct2cell(load(name)));
    end
    