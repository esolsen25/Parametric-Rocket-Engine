function [] = plot_data(engine_contour,safe_wall_thickness,L_chamber,x_tangent)
    figure(1);
%   Exterior Contour
    [offset_x,offset_y]=offset_curve(engine_contour(1,:),engine_contour(2,:),safe_wall_thickness);
%   Create Patch Object
    right_edge=[offset_x(end);offset_y(end)];
    top_surface=flip([offset_x;offset_y],2);
    left_edge=[offset_x(1) engine_contour(1,1);offset_y(1) engine_contour(2,1)];
    wall_obj=[engine_contour right_edge top_surface left_edge];
    
    contour_transp=transpose(wall_obj);
    len=size(wall_obj,2);
    z_data=zeros(len,1);
    processed_contour=[contour_transp z_data];
    % Export Processed Data to '.csv' IN [cm]:
    cd ..\
    writematrix(processed_contour,'contour.csv');
    cprintf('green','Done!\n');
    
    % Get file generated path
    filepath = fileparts(which('contour.csv'));
    cprintf('green','''contour.csv'' generated at %s\n',filepath);
    cd functions
    
    right_edge=[engine_contour(1,end) engine_contour(1,end); engine_contour(2,end) -engine_contour(2,end)];
    left_edge=[engine_contour(1,1) engine_contour(1,1); -engine_contour(2,1) engine_contour(2,1)];
    whole_eng=[engine_contour right_edge flip([engine_contour(1,:);-engine_contour(2,:)],2) left_edge];

    hold on
%   Engine Interior Shading
    patch('XData',whole_eng(1,:),'YData',whole_eng(2,:), ...
        'FaceColor','#E1E1E1','EdgeColor','white');
%   Engine Exterior Shading
    patch('XData',wall_obj(1,:),'YData',wall_obj(2,:), ...
        'FaceColor',"#ADB2BD",'EdgeColor','black','LineStyle',"-");
    patch('XData',wall_obj(1,:),'YData',-wall_obj(2,:), ...
        'FaceColor',"#ADB2BD",'EdgeColor','black','LineStyle',"-");
    hold off
%   Exterior Hatch
    engine_wall_patch_pos=patch('XData',wall_obj(1,:),'YData',wall_obj(2,:));
    engine_wall_patch_neg=patch('XData',wall_obj(1,:),'YData',-wall_obj(2,:));
    hatchfill(engine_wall_patch_pos,'single',-45,7)
    hatchfill(engine_wall_patch_neg,'single',45,7)
    
%   Grid represents a 1[in^2] section of the graph
    grid on
%   Axes Labels
    xlabel('X-Axis [in]','fontweight','bold')
    ylabel('Y-Axis [in]','fontweight','bold')
%   Plot Title
    title('Engine Contour','fontweight','bold')
%   Sets aspect ratio to 1:1
    pbaspect([1,1,1]);
%   Equal limits in both axes, fits to size of engine
    x_limits=[1.25*engine_contour(1,1),1.25*engine_contour(1,end)];
    dist=(1.25*engine_contour(1,end)-1.25*engine_contour(1,1))/2.0;
    y_limits=[-dist,dist];
    xlim(x_limits);ylim(y_limits)
%   Exit Diameter Label
    p1=[engine_contour(1,end) 0];
    p2=[engine_contour(1,end) engine_contour(2,end)];
    dist = p1-p2;
    middle_offset=dist(2)/8;
    p1(2)=middle_offset;
    hold on
    quiver(p1(1),p1(2),dist(1),dist(2)-middle_offset,0,'r','LineWidth',1);
    p1(2)=-middle_offset;
    quiver(p1(1),p1(2),dist(1),-dist(2)+middle_offset,0,'r','LineWidth',1);
    D_exit=abs(dist(2)*2);
    text(p1(1),0,sprintf('%.3f [in]',D_exit), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off
%   Throat Diameter Label
    abs_engine_contour=abs(engine_contour(1,:));
    [~,ind]=min(abs_engine_contour);
    D_throat=2*engine_contour(2,ind);

    p1=[engine_contour(1,ind) 0];
    p2=[engine_contour(1,ind) engine_contour(2,ind)];
    dist=p1-p2;
    middle_offset=dist(2)/4;
    p1(2)=middle_offset;
    hold on
    quiver(p1(1),p1(2),dist(1),dist(2)-middle_offset,0,'r','LineWidth',1);
    p1(2)=-middle_offset;
    quiver(p1(1),p1(2),dist(1),-dist(2)+middle_offset,0,'r','LineWidth',1);
    text(p1(1),0,sprintf('%.3f [in]',D_throat), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off
%   Chamber Diameter Label
    p1=[engine_contour(1,1) 0];
    p2=[engine_contour(1,1) engine_contour(2,1)];
    dist=p2-p1;
    middle_offset=abs(dist(2))/8;
    p1(2)=middle_offset;
    hold on
    quiver(p1(1),p1(2),dist(1),dist(2)-middle_offset,0,'r','LineWidth',1);
    p1(2)=-middle_offset;
    quiver(p1(1),p1(2),dist(1),-dist(2)+middle_offset,0,'r','LineWidth',1);
    D_chamber=abs(dist(2)*2);
    text(p1(1),0,sprintf('%.3f [in]',D_chamber(1)), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off    
%   Wall Thickness Label
    p1=[(x_tangent/2.54+engine_contour(1,1))/2.0 engine_contour(2,1)];
    p2=[(x_tangent/2.54+engine_contour(1,1))/2.0 engine_contour(2,1)+safe_wall_thickness];

    hold on
    quiver(p1(1),p1(2),0,safe_wall_thickness,0,'r','LineWidth',1);
    quiver(p2(1),p2(2),0,-safe_wall_thickness,0,'r','LineWidth',1);
    text(p2(1),p2(2)+1.1*safe_wall_thickness,sprintf('%.3f [in]',safe_wall_thickness), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off    
%   Chamber Length Label
    if(engine_contour(2,1)<engine_contour(2,end))
        p1=[0 -1.5*engine_contour(2,end)];
        p2=[engine_contour(1,1) -1.5*engine_contour(2,end)];
    else
        p1=[0 -1.5*engine_contour(2,1)];
        p2=[engine_contour(1,1) -1.5*engine_contour(2,1)];
    end
    midpoint=[(p2(1)-p1(1))/2 p1(1)];
    dist=(p1-midpoint);
    middle_offset=dist(1)/2;
    hold on
    p1(1)=midpoint(1)+middle_offset;
    quiver(p1(1),p1(2),abs(dist(1))-middle_offset,0,0,'r','LineWidth',1);
    p1(1)=midpoint(1)-middle_offset;
    quiver(p1(1),p2(2),-abs(dist(1))+middle_offset,0,0,'r','LineWidth',1);
    text(engine_contour(1,1)+L_chamber/2.0,p1(2),sprintf('%.3f [in]',L_chamber), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off 
%   Engine Length Label
    if(engine_contour(2,1)<engine_contour(2,end))
        p1=[engine_contour(1,1) -1.25*engine_contour(2,end)];
        p2=[engine_contour(1,end) -1.25*engine_contour(2,end)];
    else
        p1=[engine_contour(1,1) -1.25*engine_contour(2,1)];
        p2=[engine_contour(1,end) -1.25*engine_contour(2,1)];
    end
    midpoint=[(p2(1)+p1(1))/2 p1(2)];
    dist=(p1-midpoint);
    middle_offset=abs(dist(1))/4;
    hold on
    p1(1)=midpoint(1)+middle_offset;
    quiver(p1(1),p1(2),abs(dist(1))-middle_offset,0,0,'r','LineWidth',1);
    p1(1)=midpoint(1)-middle_offset;
    quiver(p1(1),p2(2),-abs(dist(1))+middle_offset,0,0,'r','LineWidth',1);
    L_engine=abs(engine_contour(1,1)-engine_contour(1,end));
    text(engine_contour(1,1)+L_engine/2.0,p1(2),sprintf('%.3f [in]',L_engine), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off

    cd ..\
end