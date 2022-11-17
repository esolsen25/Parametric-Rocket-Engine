%%  Function Declaration
function [processed_contour] = process_data(nozzle_contour)
    % Outputs progress to command window
    cprintf('green','Processing data'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.\n');
%%  Process Data
    nozzle_contour(3,:)=[]; % Deletes -y data from third row
    nozzle_contour(5,:)=[]; % Deletes -y data from the fifth row
    nozzle_contour(7,:)=[]; % Deletes -y data from the seventh row
    % Combines XYZ data into their respective rows
    x_data=[nozzle_contour(1,:),nozzle_contour(3,:),nozzle_contour(5,:)];
    y_data=[nozzle_contour(2,:),nozzle_contour(4,:),nozzle_contour(6,:)]; 
    z_data=zeros(1,300);
    xyz_data=[x_data;y_data;z_data];
    % Removes repeating values
    xyz_data(:,100)=[];xyz_data(:,100)=[];xyz_data(:,198)=[];
    % Transposes the data to be outputted 
    processed_contour=transpose(xyz_data);

    % Returns to main directory
    cd ..\
end

