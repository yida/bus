function LIDAR = intersectCal(LID, OBJECT)
  
  LIDAR = LID;

  objectSize = size(OBJECT, 2);

  for i = 1 : objectSize
    if (strcmp(OBJECT{i}.name, 'line')) 
      LIDAR.range = lineIntersect(LIDAR, OBJECT{i});
    elseif (strcmp(OBJECT{i}.name, 'circle'))
      LIDAR.range = circleIntersect(LIDAR, OBJECT{i});
    elseif (strcmp(OBJECT{i}.name, 'rectangle'))
      LIDAR.range = rectangleIntersect(LIDAR, OBJECT{i});
    end
  end
