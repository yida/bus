function dataset = loadDataMP(filename)
    tic;
    fid = fopengeneric(filename);
    data = fread(fid, '*uint8');
    size(data);
    dataset = msgpack('unpacker', data);
    toc;