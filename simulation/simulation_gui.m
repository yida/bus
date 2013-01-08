function simulation_gui

  close all;
 
   %  Create and then hide the GUI as it is being constructed.
   scrz = get(0, 'ScreenSize');
   guiPosX = scrz(3) * 1 / 16;
   guiPosY = scrz(4) * 1 / 4;
   guiWidth = 800; guiHeight = 450; % 16:9
   f = figure('Visible','off','Position',[guiPosX,guiPosY,guiWidth,guiHeight]);
 
   %  Construct the components.
   hsurf = uicontrol('Style','pushbutton','String','Surf',...
          'Position',[415,220,70,25],...
          'Callback',{@surfbutton_Callback});
   hmesh = uicontrol('Style','pushbutton','String','Mesh',...
          'Position',[415,180,70,25],...
          'Callback',{@meshbutton_Callback});
   hcontour = uicontrol('Style','pushbutton',...
          'String','Countour',...
          'Position',[415,135,70,25],...
          'Callback',{@contourbutton_Callback}); 
   htext = uicontrol('Style','text','String','Select Data',...
          'Position',[425,90,60,15]);
   hpopup = uicontrol('Style','popupmenu',...
          'String',{'Peaks','Membrane','Sinc'},...
          'Position',[400,50,100,25],...
          'Callback',{@popup_menu_Callback});
   ha = axes('Units','Pixels','Position',[50,60,300,225]); 

   align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');

   % Assign the GUI a name to appear in the window title.
   set(f,'Name','Bus-Pedestrian Collision Simulation GUI')
   % Move the GUI to the center of the screen.
%   movegui(f,'center')
   % Make the GUI visible.
   set(f,'Visible','on');
    
   % Create the data to plot.
   peaks_data = peaks(35);
   membrane_data = membrane;
   [x,y] = meshgrid(-8:.5:8);
   r = sqrt(x.^2+y.^2) + eps;
   sinc_data = sin(r)./r;
   
   % Initialize the GUI.
   % Change units to normalized so components resize 
   % automatically.
   set([f,ha,hsurf,hmesh,hcontour,htext,hpopup],...
   'Units','normalized');
   %Create a plot in the axes.
   current_data = peaks_data;

%   surf(ha, current_data);
   plot_intersection(ha);
   axis equal;

   %  Callbacks for simple_gui. These callbacks automatically
   %  have access to component handles and initialized data 
   %  because they are nested at a lower level.
 
   %  Pop-up menu callback. Read the pop-up menu Value property
   %  to determine which item is currently displayed and make it
   %  the current data.
      function popup_menu_Callback(source,eventdata) 
         % Determine the selected data set.
         str = get(source, 'String');
         val = get(source,'Value');
         % Set current data to the selected data set.
         switch str{val};
         case 'Peaks' % User selects Peaks.
            current_data = peaks_data;
         case 'Membrane' % User selects Membrane.
            current_data = membrane_data;
         case 'Sinc' % User selects Sinc.
            current_data = sinc_data;
         end
      end
  
   % Push button callbacks. Each callback plots current_data in
   % the specified plot type.
 
   function surfbutton_Callback(source,eventdata) 
   % Display surf plot of the currently selected data.
      surf(current_data);
   end
 
   function meshbutton_Callback(source,eventdata) 
   % Display mesh plot of the currently selected data.
      mesh(current_data);
   end
 
   function contourbutton_Callback(source,eventdata) 
   % Display contour plot of the currently selected data.
      contour(current_data);
   end 
 
end 
