function fid = fopengeneric(filepath)
    fid = -1;
    flists = dir([filepath,'*']);
    if numel(flists) > 0
        filename = flists(end).name;
        lastslash = strfind(filepath, '/');
        filename = [filepath(1 : lastslash(end)), filename];
        fid = fopen(filename);
    end
end