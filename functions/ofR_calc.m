%% Function Declaration
% Developer: Jonah Gimmi
function [ofR] = ofR_calc(P_chamber,ambP)
    %% Variable Declaration
    ofRA = 0.25:0.25:25; % Oxidizer/Fuel Ratio [wt%]
    IspAI = []; % [s] Specific Impulse Array for Infinite Area CEA
    %% Infinite Area CEAM
    % Calculates all possible values for specific impulse for a given
    % matrix of OF Ratios.

    % Directs to \temp\ where CEA.p is contained in order to access the
    % CEA() function.
    cd ..\temp\
    for NofR=1:length(ofRA)
        % Calls NASA 'CEA.p', outputs structure into variable "sim"
        sim=CEA('problem','rocket','equilibrium','p,psia',P_chamber,'pi/p', ...
            P_chamber/ambP,'o/f',ofRA(NofR),'reactants','fuel','C3H8O', ...
            'C',3,'H',8,'O',1,'wt%',100,'h,kJ/mol',-272.8,'t(k)',298.15, ...
            'rho,g/cc',0.785,'oxid','N2O','N',2,'O',1,'wt%',100,'h,kJ/mol', ...
            82.05,'t(k)',298.15,'rho,g/cc',1.220,'end');
        IspAI = [IspAI,sim.output.eql.isp];
    end
    %% Calculates Optimal OF_Ratio
    % Finds the maximum value for specific impulse of the rocket engine
    % given reactants and maximum chamber pressure. Optimal OF Ratio is the
    % index of our ofRA matrix where IspVI is max
    IspVI = IspAI(3,:);
    for n = 1:length(IspVI)
        if max(IspVI) == IspVI(n)
            ofR = ofRA(n);
        end
    end
    % Directs back to main function directory
    cd ..\
end