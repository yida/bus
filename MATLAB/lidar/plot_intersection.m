function plot_intersection(handle)

  if nargin == 0
    handle = gca;
  end
 
  ItsWidth = 14;
  ItsLength = 10;

  ItsCorners = [-ItsWidth/2, -ItsLength/2;...
                        ItsWidth/2, -ItsLength/2;...
                        ItsWidth/2, ItsLength/2;...
                        -ItsWidth/2, ItsLength/2];
%  plot(ItsCorners(:,1), ItsCorners(:,2), '*');
  % draw curb
  hold on;
  signMat = [-1,-1; -1,1; 1,1; 1, -1];
  signMat2 = [-1,-1; 1,-1; 1,1; -1, 1];
  CurbExtension = 30;
  CurbExt =  signMat* CurbExtension;
  CornetR = 7;
  for i = 1 : 4
    circle = struct('name', 'circle',...
           'cx', ItsCorners(i,1)+CornetR*signMat(i,2),...
           'cy', ItsCorners(i,2)+CornetR*signMat(i,1),...
           'r', CornetR, 'arcStart',(i-1)*1/2*pi, 'arcEnd', i/2*pi, 'color', 'b');
    plot_circle(circle, handle);
    plot(handle, [ItsCorners(i,1), ItsCorners(i,1)],...
         [ItsCorners(i,2)+CornetR*signMat2(i,2), ItsCorners(i,2)+CurbExt(i,1)]);
    plot(handle, [ItsCorners(i,1)+CornetR*signMat2(i,1), ItsCorners(i,1)+CurbExt(i,2)],...
         [ItsCorners(i,2), ItsCorners(i,2)]);
  end
   
  % draw central line
  dirSign = [0,-1; 1, 0; 0,1; -1, 0];
  DotExtension = 30;
  CirCorners = [ItsCorners;ItsCorners(1,:)];
  for i = 1 : 4 
    plot(handle, [(CirCorners(i,1)+CirCorners(i+1,1))/2 + CornetR*dirSign(i,1),...
              (CirCorners(i,1)+CirCorners(i+1,1))/2 + DotExtension*dirSign(i,1)],...
         [(CirCorners(i,2)+CirCorners(i+1,2))/2 + CornetR*dirSign(i,2),...
              (CirCorners(i,2)+CirCorners(i+1,2))/2 + DotExtension*dirSign(i,2)],'--');
  end

