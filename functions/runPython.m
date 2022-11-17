function [engine_contour] = runPython(k,AeAt,R_throat_imp)
% Converting to '.mat' file:
cd ..\
pathname_temp = append(fileparts(which('geometry_calculation.m')),'\temp');
file_folder = fullfile(pathname_temp,'to_python.mat');
save(file_folder,'k','AeAt','R_throat_imp');
% Runs Geometry Calculation:
cprintf('green','\nRunning Python script'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.\n');
pathname_func = append(fileparts(which('geometry_calculation.m')),'\functions');
runPython = fullfile(pathname_func,'contour_calculation.py');
pyrunfile(runPython);
% Load calculated engine geometry into MATLAB:
load(append(pathname_temp,'\engine_contour.mat'));

cprintf('green','Done!\n');
end

