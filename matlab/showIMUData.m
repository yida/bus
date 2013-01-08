imuSize = size(imuData, 2);

lastTuc = imuData{1}.tuc;
lastTurnTS = 100;
leftcount = 0;
rightcount = 0;
label = cell(0);
labelcount = 0;
for cnt = 2 : imuSize
  if (imuData{cnt}.tuc ~= lastTuc) 
    lastTuc = imuData{cnt}.tuc;
    if (strcmp(imuData{cnt}.label, '01') > 0)
      if imuData{cnt}.tstamp - lastTurnTS > 1
        fprintf(1, 'left turning %d %f\n', imuData{cnt}.tuc, imuData{cnt}.tstamp);
        lastTurnTS = imuData{cnt}.tstamp;
        leftcount = leftcount + 1;
        labelcount = labelcount + 1;
        label{labelcount} = imuData{cnt};
      end
    elseif (strcmp(imuData{cnt}.label, '10') > 0)
      if imuData{cnt}.tstamp - lastTurnTS > 1
        fprintf(1, 'right turning %d %f\n', imuData{cnt}.tuc, imuData{cnt}.tstamp);
        lastTurnTS = imuData{cnt}.tstamp;
        rightcount = rightcount + 1;
        labelcount = labelcount + 1;
        label{labelcount} = imuData{cnt};      
      end
    end
  end
end
leftcount
rightcount
