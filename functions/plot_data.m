function [] = plot_data(engine_contour,safe_wall_thickness,L_chamber,x_tangent)
%%  Create Patch Object
    [offset_x,offset_y]=offset_curve(engine_contour(1,:),engine_contour(2,:),safe_wall_thickness);
    right_edge=[offset_x(end);offset_y(end)];
    top_surface=flip([offset_x;offset_y],2);
    left_edge=[offset_x(1) engine_contour(1,1);offset_y(1) engine_contour(2,1)];
    wall_obj=[engine_contour right_edge top_surface left_edge];
%%  Export Full Contour Data to '.csv' in [cm]:
    % A limitation of the python program is that the data it exports is
    % understood to use [cm] as the units. This issue continues into
    % exporting it as a .csv, as Fusion360 only understands the XYZ data
    % using [cm] as units. As long as we are consistent with our units,
    % data transfer from MATLAB->Python->Fusion360 should operate smoothly.
    contour_transp=transpose(wall_obj);
    len=size(wall_obj,2);
    z_data=zeros(len,1);
    processed_contour=[contour_transp z_data];

    cd ..\
    writematrix(processed_contour,'contour.csv');
    cprintf('green','Done!\n');
    
    % Outputs file path where the 'contour.csv' file was generated
    filepath = fileparts(which('contour.csv'));
    cprintf('green','''contour.csv'' generated at %s\n',filepath);
    cd functions
%%   Engine Interior Shading
    % This big block of code *basically* takes our contour that was
    % generated by Python and gives it a thickness value. We then create a
    % closed object that can be used to create a patch which then can be
    % assigned a color. We need to repeat this process from the outer
    % radius to the x-axis to create a quasi-solid patch that appears to
    % form a gradient. To achieve the gradient it is relatively simple
    % compared to the rest of the code, where we simply generate a matrix
    % full of RGB Triplets from 0 to 1 and iterate through this matrix as
    % we generate more lines down. Since the engine geometry is not a flat
    % line, offsetting the line as we get closer to 0 becomes more
    % complicated, so we need to detect when the y-value in any part of the
    % offsetted matrix becomes less than or equal to 0, and then we need to
    % delete the x and y data in that portion of the matrix. This achieves
    % the desired effect of a cylindrical object following the generated
    % chamber geometry.
    if(engine_contour(2,end)>engine_contour(2,1))
        radius=engine_contour(2,end);

        if(engine_contour(2,end)>3.247)
            accuracy=255*8;
        elseif(engine_contour(2,end)>2.797)
            accuracy=255*7;
        elseif(engine_contour(2,end)>2.328)
            accuracy=255*6;
         elseif(engine_contour(2,end)>1.870)
             accuracy=255*5;
        else
            accuracy=255*4;
        end
    else
        radius=engine_contour(2,1);

        if(engine_contour(2,1)>3.247)
            accuracy=255*8;
        elseif(engine_contour(2,1)>2.797)
            accuracy=255*7;
        elseif(engine_contour(2,1)>2.328)
            accuracy=255*6;
         elseif(engine_contour(2,1)>1.870)
             accuracy=255*5;
        else
            accuracy=255*4;
        end
    end
    rgb_triplets=zeros(256,3);
    for i=1:1:accuracy+1
        rgb_triplets(i,1)=(i-1)/accuracy;
        rgb_triplets(i,2)=rgb_triplets(i,1);
        rgb_triplets(i,3)=rgb_triplets(i,1);
    end
    thickness=safe_wall_thickness/8;
    [offset_x,offset_y]=offset_curve(engine_contour(1,:),engine_contour(2,:),thickness);
    top=flip([offset_x;offset_y],2);
    [~,ind]=min(abs(engine_contour(2,:)));
    top_left=top(:,ind:end); bottom_left=engine_contour(:,1:ind);
    gradient_left=[bottom_left top_left];
    bottom_right=engine_contour(:,ind-1:end);
    top_right=flip([bottom_right(1,:);bottom_right(2,:)+thickness],2);
    gradient_right=[bottom_right top_right];
    k=1; interval=thickness/3;
    for j=radius:-interval:0
        gradient_left(2,:)=gradient_left(2,:)-interval;
        gradient_right(2,:)=gradient_right(2,:)-interval;
        i=1;
        while(i<length(gradient_left))
            if(gradient_left(2,i)<=0)
                gradient_left(:,i)=[];
            end
            i=i+1;
        end
        i=1;
        while(i<=length(gradient_right))
            if(gradient_right(2,i)<=0)
                gradient_right(:,i)=[];
            end
            i=i+1;
        end
        hold on
        patch('XData',gradient_left(1,:),'YData',gradient_left(2,:),'FaceColor', ...
            rgb_triplets(4*(k+1),:),'EdgeColor',rgb_triplets(4*(k+1),:))
        patch('XData',gradient_left(1,:),'YData',-gradient_left(2,:),'FaceColor', ...
             rgb_triplets(4*(k+1),:),'EdgeColor',rgb_triplets(4*(k+1),:))            
        patch('XData',gradient_right(1,:),'YData',gradient_right(2,:),'FaceColor', ...
            rgb_triplets(4*(k+1),:),'EdgeColor',rgb_triplets(4*(k+1),:))
        patch('XData',gradient_right(1,:),'YData',-gradient_right(2,:),'FaceColor', ...
              rgb_triplets(4*(k+1),:),'EdgeColor',rgb_triplets(4*(k+1),:))
        hold off        
        k=k+1;
    end
%%  Engine Exterior Shading
    % A much simpler process, simply fills with solid color
    patch('XData',wall_obj(1,:),'YData',wall_obj(2,:), ...
        'FaceColor',"#fcd4fc",'EdgeColor','black','LineStyle',"-");
    patch('XData',wall_obj(1,:),'YData',-wall_obj(2,:), ...
        'FaceColor',"#fcd4fc",'EdgeColor','black','LineStyle',"-");
    hold off
%%  Exterior Hatch
    % Uses open-source function found on mathworks.com to generate
    % hash-lines to emulate a section-view as is seen in Fusion360.
    % Source Files: https://www.mathworks.com/matlabcentral/fileexchange/30733-hatchfill
    engine_wall_patch_pos=patch('XData',wall_obj(1,:),'YData',wall_obj(2,:));
    engine_wall_patch_neg=patch('XData',wall_obj(1,:),'YData',-wall_obj(2,:));
    hatchfill(engine_wall_patch_pos,'single',70,4);
    hatchfill(engine_wall_patch_neg,'single',-70,4);
%%  Axes Configuration
    % Each "grid" represents 1[in^2]
    grid on
    % Axes Labels
    xlabel('X-Axis [in]','fontweight','bold')
    ylabel('Y-Axis [in]','fontweight','bold')
    % Figure Title
    title('Engine Contour','fontweight','bold')
    % Sets our figure aspect ratio to 1:1:1, which is important to maintain
    % a real-to-life visualization of the engine geometry.
    pbaspect([1,1,1]);
    % Related to previous point on aspect ratio, in order for the aspect
    % ratio to remain true, the axes limits must also be equal.
    x_limits=[1.25*engine_contour(1,1),1.25*engine_contour(1,end)];
    dist=(1.25*engine_contour(1,end)-1.25*engine_contour(1,1))/2.0;
    y_limits=[-dist,dist];
    xlim(x_limits);ylim(y_limits)
%% Quiver Annotations
    % Exit Diameter Annotation
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
    % Throat Diameter Annotation
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
    % Chamber Diameter Annotation
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
    % Wall Thickness Annotation
    p1=[(x_tangent/2.54+engine_contour(1,1))/2.0 engine_contour(2,1)];
    p2=[(x_tangent/2.54+engine_contour(1,1))/2.0 engine_contour(2,1)+safe_wall_thickness];

    hold on
    quiver(p1(1),p1(2),0,safe_wall_thickness,0,'r','LineWidth',1);
    quiver(p2(1),p2(2),0,-safe_wall_thickness,0,'r','LineWidth',1);
    text(p2(1),p2(2)+1.1*safe_wall_thickness,sprintf('%.3f [in]',safe_wall_thickness), ...
        'HorizontalAlignment','center','VerticalAlignment','middle',FontWeight='bold',FontSize=8);
    hold off    
    % Chamber Length Annotation
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
    % Engine Length Annotation
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

    % Returns to main function directory
    cd ..\
end