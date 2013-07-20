function dataset = load_data_msgpack(filename)
    tic;
    fid = fopengeneric(filename);
    data = fread(fid, '*uint8');
    dataset = msgpack('unpacker', data);
%    h_unpack = msgpack('init_unpacker', data);
%    [flag, value] = msgpack('next_unpacker', h_unpack);
%    data_counter = 1;
%    while flag == 1 
%      dataset{data_counter} = value;
%      data_counter = data_counter + 1;
%      [flag, value] = msgpack('next_unpacker', h_unpack);
%    end
    toc;
