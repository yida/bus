clear all;
fid = serialopen('/dev/tty.usbserial-A700eEMR', 38400);
i=0;
Sample = zeros(500,7);
while(1);
    
    line = fgets(fid);
    my_t = now;
    if( ~isempty(line) && (line(1)=='I') && (sum(line==' ')==9))
        line
        sample = sscanf(line, 'IMU %d %d %d %d %d %d %f %f %f');
        Sample(i+1,1) = my_t;
        Sample(i+1,2:7) = sample(1:6)';
    %    fprintf('%f %s\n',my_t, char(line) );
        i=i+1;
    end
    
    pause(0.02);
    
    if(i>500)
        return;
    end
    
end