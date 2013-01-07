function sectionInfo = lidarDetection(LIDAR)

  sectCounter = 0;
  section = zeros(LIDAR.numBeams, 2);
  for i = 1 : LIDAR.numBeams
    if (i == 1)
      sectCounter = sectCounter + 1; 
      section(sectCounter, 1) = i;
    else
      if abs(LIDAR.range(i) - LIDAR.range(i-1)) > 1
        section(sectCounter,2) = i - 1;
        sectCounter = sectCounter + 1;
        section(sectCounter,1) = i;
      end
    end
  end
  section(sectCounter,2) = LIDAR.numBeams;
  section = section(1:sectCounter,:);
  sectionInfo = zeros(sectCounter,2);
  sectionInfoCounter = 0;
  for i = 1 : sectCounter
    sectx = LIDAR.range(section(i,1):section(i,2))...
            .* cos(LIDAR.beamAngles(section(i,1):section(i,2)))...
            + LIDAR.center(1);
    secty = LIDAR.range(section(i,1):section(i,2))...
            .* sin(LIDAR.beamAngles(section(i,1):section(i,2)))...
            + LIDAR.center(2);
    if (mean(LIDAR.range(section(i,1):section(i,2)))<20)
      sectionInfoCounter = sectionInfoCounter + 1;
      sectionInfo(sectionInfoCounter,1) = mean(sectx);
      sectionInfo(sectionInfoCounter,2) = mean(secty);
    end
  end


