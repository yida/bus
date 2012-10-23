clear all;
fid = serialopen('/dev/tty.usbserial-A700eEMV', 115200);
i=0;
while(1);
    
    line = fgets(fid);
    my_t = now;
    if( ~isempty(line) )
        size(line);
        fprintf('%f %s\n',my_t, char(line) );
        i=i+1;
    end
    
    if(i>10000)
        return;
    end
    
end

%fclose(fid);