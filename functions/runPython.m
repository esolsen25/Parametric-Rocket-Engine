%% Function Declaration
function [engine_contour] = runPython(k,AeAt,R_throat_imp)
    % Return to main directory to save files
    cd ..\
%% Save '.mat' File to \temp
    pathname_temp = append(fileparts(which('geometry_calculation.m')),'\temp');
    file_folder = fullfile(pathname_temp,'to_python.mat');
    save(file_folder,'k','AeAt','R_throat_imp');
%% Runs Python Script
    % Outputs to command window the current process...
    cprintf('green','\nRunning Python script'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.\n');
    pathname_func = append(fileparts(which('geometry_calculation.m')),'\functions');
    % Calls the Python script to run
    runPython = fullfile(pathname_func,'contour_calculation.py');
    pyrunfile(runPython);
    % Load calculated nozzle_geometry into MATLAB 
    load(append(pathname_temp,'\engine_contour.mat'));
    % Prints progress to command window
    cprintf('green','Done!\n');
end

