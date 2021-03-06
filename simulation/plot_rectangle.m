function Ver = plot_rectangle(REC, handle)

  if nargin < 2
    handle = gca;
  end
   
  recVer = [REC.w/2, REC.h/2; -REC.w/2, REC.h/2;...
            -REC.w/2, -REC.h/2; REC.w/2, -REC.h/2];
  
  %% Rotation based on bus center
  Ver = [recVer(:,1).*cos(REC.theta) - recVer(:,2).*sin(REC.theta),...
         recVer(:,1).*sin(REC.theta) + recVer(:,2).*cos(REC.theta)];
  %% Translate bus center
  Ver = bsxfun(@plus, Ver, [REC.cx, REC.cy]);
  
  %% draw bus and fill with color
  if isfield(REC,'color') == 1;
    color = REC.color;
  else color = 'k'; end
  plot(handle, [Ver(:,1);Ver(1,1)], [Ver(:,2);Ver(1,2)], '-');
  patch([Ver(:,1);Ver(1,1)], [Ver(:,2);Ver(1,2)], color);
  
  
