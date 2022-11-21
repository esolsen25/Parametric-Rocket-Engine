%% Script Details
% Developer: Evan Olsen
% Last Updated: 11-15-2022 4:16PM
% Purpose: Calculate Geometry Specifications for Rao Nozzle for Small
% Rocket Engines
% Iteration: HalfCat Liquid Rocket Engine
% Team: RIT Liquid Propulsion
clc; clear; close all;
%% INPUTS
% Constants ---------------------------------------------------------------
g = 9.80665;                                                               % [m/s^2] Acceleration Due to Gravity
% Material Properties -----------------------------------------------------
allowable_stress = 96.5*10^6;                                              % [Pa] Allowable Stress
    % MATERIAL: 2024-T1 Aluminum Alloy
    % Value pulled from ASTM Standard values for material being used to
    % manufacture a given rocket engine. Used in calculation for wall
    % thickness.
FOS = 3.0;                                                                 % [-] Factor of Safety
    % Factor of safety chosen to fit desired safety of a manufactured
    % rocket engine, only taking maximum internal pressure into account.
    % [PROGRAM NOT DEVELOPED TO DETERMINE THERMAL STRESSES]
% Engine Extensive Properties ---------------------------------------------
D_chamber_imp = 3.0;                                                       % [in] Chamber Diamater - Extensive Property
    % D_chamber_imp, or the desired chamber diamater is determined from the
    % limits of manufacturing an injector to be fitted within the limited
    % of the combustion chamber.
% CEAM Required Values ----------------------------------------------------
P_chamber = 550;                                                           % [psia] Chamber Pressure (Absolute Units)
    % psiA was determined from the previously outlined relation and is the
    % maximum sustainable pressure we can handle in our first engine iteration.
ambP = 14.6959;                                                            % [psia] Pressure at Sea Level
    % ampP is the ambient pressure at the altitude where the rocket engine
    % will be fired.
    % Sea level: 14.6959 [psia]
optimize_CEAM = true;                                                      % [bool] Optimize CEAM Parameters
    % optimize_CEAM boolean used to decide whether you want to input an
    % AcAt value or use a predetermined one. If optimize_CEAM = true,
    % following given AcAt is ignored.
if(optimize_CEAM==false)
    AcAt=4.0;                                                              % [-] Given AcAt
    % AcAt was traditionally determined through optimizing our OF Ratio vs.
    % specific impulse graph given a chamber pressure, the method that was
    % used to calculate this value has now been implemented in a function
    % within this script.
end
%% Calculate OF_Ratio
% Routes to directory containing sub-functions
cd functions
% OF_Ratio() Description:
%   Creates matrix of OF_Ratios and runs infinite chamber NASA CEAMs and
%   finds the OF_Ratio where specific impulse is maximized for the given
%   reactants.
% Inputs: P_chamber, ambP
% Outputs: OF_Ratio
%   (OF_Ratio used in AcAt_calc() and CEAM_Final())
OF_Ratio = ofR_calc(P_chamber,ambP);
%% Calculate AcAt
% Routes to directory containing sub-functions
cd functions
% AcAt_calc() Description:
%   Uses previously determined optimal OF_Ratio to run finite CEAMs to find
%   the most optimized AcAt value. Behavior of the graph of AcAt vs. Isp at
%   a specific chamber pressure and OF_Ratio approaches an upper limit as
%   AcAt approaches infinity. Script utilizes the 95% value of AcAt which
%   is close to the value when the relationship has diminishing returns. 
% Inputs: P_chamber, OF_Ratio, ambP
% Outputs: AcAt
%   (AcAt is used in CEAM_Final() and geometry_parameters())
if(optimize_CEAM == true)
    AcAt = AcAt_calc(P_chamber,OF_Ratio,ambP);
end
%% Run Final CEAM
% Routes to directory containing sub-functions
cd functions
% CEAM() Description:
%   Implements MATLAB version of NASA CEA to calculate the basic constants
%   which we require to generate rocket engine geometry.
% Inputs: AcAt,psiA,OF_Ratio,ampP
% Outputs: ispA,cstarA,aeatA,pressureA,gammaA
%     (Can be configured for any available CEAM output, see documentation)
[ispA,cstarA,aeatA,pressureA,gammaA] = CEAM_Final(AcAt,P_chamber,OF_Ratio,ambP);
% IMPORTANT: Outputs for CEAM will be 1x4 matrices, the following indices
% represent data at a different location:
%   [1] -> Injector Face
%   [2] -> Comb. End
%   [3] -> Throat
%   [4] -> Exit
%% Geometry Parameters Calculation
% Routes to directory containing sub-functions
cd functions
% geometry_parameters() Description:
%   Uses desired chamber diameter, proven to give ideal results during the
%   development of this program, as well as needed CEAM outputs to generate
%   and output basic radius, diameter, and area values for the combustion
%   chamber, throat, and engine exit.
% Inputs: D_chamber_imp,aeatA(4),AcAt
% Outputs: D_throat,R_throat,A_throat,D_chamber,A_chamber
%     (Values used throughout rest of program)
[D_throat,R_throat,A_throat,D_chamber,A_chamber] = geometry_parameters(D_chamber_imp,aeatA(4),AcAt);
%% Performance Parameters Calculation
% Routes to directory containing sub-functions
cd functions
% performance_parameters() Description:
%   Uses throat area to determine mass flowrate using C_star generated from
%   CEAM. Mass flowrate then calculates ideal steady-state thrust by
%   relating to our specific impulse, also generated by CEAM. Outputs
%   values in command window.
%  Inputs: ispA(4),g=9.81,cstarA(3),pressureA(1) [bar]->[Pa], A_throat
%  Outputs: N/A
performance_parameters(ispA(4),9.81,cstarA(3),pressureA(1)*100000,A_throat);
%% Chamber and Characteristic Length Calculation
% Routes to directory containing sub-functions
cd functions
% length_calc() Description:
%   Calculates the length of the combustion chamber, described as the
%   length from the end of the rocket engine to the throat, from an
%   equation calculated using a logarithmic regression of data from many
%   previous successful rocket engines.
%   Source: http://www.braeunig.us/space/propuls.htm
% Inputs: D_throat,A_chamber,A_throat
% Outputs: L_chamber
%     (L_chamber used in create_chamber() and plot_data())
[L_chamber] = length_calc(D_throat,A_chamber,A_throat);
%% Wall Thickness Calculations
% Routes to directory containing sub-functions
cd functions
% wall_thickness() Description:
%   Calculates the safe wall thickness needed to achieve a given factor of
%   safety. Determines this using normal stress equations, thermal stress
%   and heat transfer are NOT taken into consideration.
% Inputs: allowable_stress,pressureA(1) [bar]->[Pa]
[safe_wall_thickness] = wall_thickness(allowable_stress,pressureA(1)*100000,FOS,D_chamber);
%% Run Python Script
% IMPORTANT: Check README.txt for troubleshooting instructions
% Routes to directory containing sub-functions
cd functions
% runPython() Description:
%   Saves MATLAB generated variables into a '.mat' which Python can
%   understand through the SciPy.io library. Then runs the python program
%   through MATLAB API and returns the generated contour to MATLAB by
%   reversing the operation of SciPy.io and loading the '.mat' containing
%   contour geometry back into MATLAB.
% Inputs: gammaA(4),aeatA(4),R_throat [m]->[cm]
% Outputs: nozzle_contour
%     (nozzle_contour only contains geometry from the throat entrance to
%     the engine exit)
[nozzle_contour] = runPython(gammaA(4),aeatA(4),R_throat*100);
%% Process Data
% Routes to directory containing sub-functions
cd functions
% process_data() Description:
%   Data returned from the Python program contains values which are not
%   particularly useful for exporting geometry to Fusion360, such as
%   including negative values as well as segmenting the sections of the
%   engine into different rows. For our purposes, we would like everything
%   to be in a 3 by X matrix containing all XYZ data.
% Inputs: nozzle_contour
% Outputs: nozzle_contour
%     (NOTE: the input and output do not contain the same values, the
%     output contains processed values of the input function.)
[nozzle_contour] = process_data(nozzle_contour);
%% Create Chamber
% Routes to directory containing sub-functions
cd functions
% create_chamber() Description:
%   Since our processed data does not include combustion chamber geometry,
%   the goal of this function is to create that chamber geometry by
%   creating a smooth curve between using tangent circle trigonometry.
% Inputs: nozzle_contour,L_chamber [m]->[cm],D_chamber [m]->[cm]
% Outputs: engine_contour,x_tangent
%     (engine_contour contains combustion chamber_contour as well as
%     nozzle_contour combined together, x_tangent is used within
%     plot_data())
[engine_contour,x_tangent] = create_chamber(nozzle_contour,L_chamber*100,D_chamber*100);
%% Plot Data in MATLAB Figure Window
% Routes to directory containing sub-functions
cd functions
% plot_data() Description:
%   Main purpose is to output engine_contour in a meaningful way into a
%   MATLAB Figure Window, goal was to emulate Fusion360 section view.
%   Includes MATLAB coded shading engine! Also outputs 'contour.csv' in the
%   main function directory.
% Inputs: engine_contour,safe_wall_thickness [m]->[in], L_chamber
% [m]->[in],x_tangent)
% Outputs: N/A
plot_data(engine_contour(1:2,:)/2.54,safe_wall_thickness*39.3701,L_chamber*39.3701,x_tangent);