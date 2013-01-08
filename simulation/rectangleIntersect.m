function range = rectangleIntersect(LIDAR, REC)

  recVer = [REC.w/2, REC.h/2; -REC.w/2, REC.h/2;...
            -REC.w/2, -REC.h/2; REC.w/2, -REC.h/2];
  
  %% Rotation based on center
  Ver = [recVer(:,1).*cos(REC.theta) - recVer(:,2).*sin(REC.theta),...
         recVer(:,1).*sin(REC.theta) + recVer(:,2).*cos(REC.theta)];
  %% Translate center
  Ver = bsxfun(@plus, Ver, [REC.cx, REC.cy]);

  cirVer = [Ver;Ver(1,:)];
  for i = 1 : 4
    p1 = cirVer(i, :);
    p2 = cirVer(i+1, :);
    c = p1(1) - p2(1); % y1 - y2
    a = p1(2) - p2(2); % x1 - x2
    b = (p1(1) - p2(1)) * p1(2) - (p1(2) - p2(2)) * p1(1);
        % (y1 - y2)y1 - (x1-x2)x1
    line = struct('name','line', 'a', a, 'b', b, 'c', c);
    LIDAR.range = lineIntersect(LIDAR, line, p1, p2);
  end

  range = LIDAR.range;
