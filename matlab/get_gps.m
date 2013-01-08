clear all;
if ismac()
  fid = serialopen('/dev/tty.usbmodem1d1141', 38400);
else
  fid = serialopen('/dev/ttyACM0', 38400);
end

i=0;
Sample = zeros(500,7);
while(1);
    
    line = fgets(fid);
    my_t = now;
    if( ~isempty(line))
        if (strcmp(line(1:6),'$GPGGA')==1)
        line
        sample = sscanf(line, '$GPGGA,%f,%f,%c,%f,%c,%d,%d, %d %d %d %d %d %d %f %f %f');
%        Sample(i+1,1) = my_t;
%        Sample(i+1,2:7) = sample(1:6)';
    %    fprintf('%f %s\n',my_t, char(line) );
        i=i+1;
        end
    end
    
    pause(0.02);
    
    if(i>500)
        return;
    end
    
end
