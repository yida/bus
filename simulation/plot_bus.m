function [axisRange, Ver] = plot_bus(busCenter, busTheta)


busWidth = 0.3;
busLength = 1;
busVer = [busWidth/2, busLength/2; -busWidth/2, busLength/2;...
          -busWidth/2, -busLength/2; busWidth/2, -busLength/2];

%% Rotation based on bus center
Ver = [busVer(:,1).*cos(busTheta) - busVer(:,2).*sin(busTheta),...
       busVer(:,1).*sin(busTheta) + busVer(:,2).*cos(busTheta)];
%% Translate bus center
Ver = bsxfun(@plus, Ver, busCenter);

%% draw bus and fill with color
plot([Ver(:,1);Ver(1,1)], [Ver(:,2);Ver(1,2)], '-');
patch([Ver(:,1);Ver(1,1)], [Ver(:,2);Ver(1,2)], 'b');

%axisRange = [min(Ver(:,1)), max(Ver(:,1)), min(Ver(:,2)), max(Ver(:,2))];

