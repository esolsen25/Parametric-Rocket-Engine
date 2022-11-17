%% Function Declaration
function [engine_contour,x_tangent] = create_chamber(nozzle_contour,L_chamber,D_chamber)
%% Chamber Geometry Calculation
    temp = transpose(nozzle_contour);
    
    y1=D_chamber/2.0;
    x1=-L_chamber;
    
    x3=nozzle_contour(1,1);
    y3=nozzle_contour(1,2);    
    entrant_slope=(y3-nozzle_contour(2,2))/(x3-nozzle_contour(2,1));
    y2=y1;
    b=y3-entrant_slope*x3;
    x2=(y2-b)/entrant_slope;

    vec1=[x1,y1,0]-[x2,y2,0];
    vec2=[x3,y3,0]-[x2,y2,0];
    theta=atan2d(norm(cross(vec1,vec2)),dot(vec1,vec2));
    bisect=theta/2;
    bisect_slope=sind(bisect)/cosd(bisect);

    x1_max=500;
    x1_min=-x1_max;
    b_bisect=y2-bisect_slope*x2;
    y1_max=bisect_slope*x1_max+b_bisect;
    y1_min=bisect_slope*x1_min+b_bisect;

    recip_entrant=-1/entrant_slope;
    b_recip=y3-recip_entrant*x3;
    x2_max=500;
    x2_min=-x2_max;
    y2_max=recip_entrant*x2_max+b_recip;
    y2_min=recip_entrant*x2_min+b_recip;

    P=line_intercept([x1_min x1_max;y1_min y1_max],[x2_min x2_max;y2_min y2_max]);
    delta_x=P(1)-x3;
    delta_y=P(2)-y3;
    R=(delta_x^2+delta_y^2)^0.5;

    angle1=acos((abs(P(1))-abs(x3))/R);
    x_tangent=P(1);
    chamber_wall=[linspace(x1,x_tangent,10);linspace(y1,y1,10);linspace(0,0,10)];
    
    th=pi/2:-pi/100:angle1;
    curve=[R*cos(th)+P(1);R*sin(th)+P(2);0*th];
    
    engine_contour = [chamber_wall curve temp];

    % Return to home directory
    cd ..\
end

