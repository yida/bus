magSize = size(magData, 2);

compassWidth = 1;
compassLength = 2;
compassVer = [0, compassLength/2; compassWidth/2, 0;...
              0, -compassLength/2; -compassWidth/2, 0];
compassCenter = [0,0];

mag = zeros(3, magSize);
showCompass = true;
for count = 1 : 100 : magSize
  magData{count}.mag';
  mag(:, count) = magData{count}.mag';
  heading = atan2(mag(2, count), mag(1, count));
  declinationAngle = -205.7 / 1000.0;
  heading = heading + declinationAngle;

%  if (heading < 0) heading = heading + 2 * pi; end
  fprintf(1, '%d Heading: %f, HeadingDring: %f\n', count, heading, heading * 180 / pi);

  hold on;
  plot3(mag(1,count), mag(2,count), mag(3, count), '*');
  hold off;
  grid on;

  pause(0.1);

  if showCompass 
    compassTheta = heading;
  
    Ver = [compassVer(:,1).*cos(compassTheta) - compassVer(:,2).*sin(compassTheta),...
          compassVer(:,1).*sin(compassTheta) + compassVer(:,2).*cos(compassTheta)];
    Ver = bsxfun(@plus, Ver, compassCenter);
    
    plot([Ver(:,1);Ver(1,1)], [Ver(:,2);Ver(1,2)], '-');
    upperVer = [Ver(1:2,:);Ver(4,:)];
    lowerVer = Ver(2:4,:);
    patch([upperVer(:,1);upperVer(1,1)], [upperVer(:,2);upperVer(1,2)], 'r');
    patch([lowerVer(:,1);lowerVer(1,1)], [lowerVer(:,2);lowerVer(1,2)], 'b');
    axis([-2.5 2.5 -2.5 2.5]);
    axis equal;
    grid on;
  
    pause(0.1);
  end

end

drawnow;

%plot(1:magSize, mag(1,:), 1:magSize, mag(2,:), 1:magSize, mag(3,:));
