%% Script Details
% Developer: Evan Olsen
% Last Updated: 11-13-2022 5:19AM
% Purpose: Calculate Geometry Specifications for Rao Nozzle
% Iteration: HalfCat Liquid Rocket Engine
% Team: RIT Liquid Propulsion
clc; clear;
%% CONSTANTS
% Material Properties
allowable_stress = 96.5*10^6;                                              % [Pa] Allowable stress of aluminum
FOS = 3.0;                                                                 % [-] Factor of Safety
D_chamber_imp = 2;                                                         % [in] Chamber Diamater - Extensive Property
% CEAM Inputs
AnalysisType = 2;                                                          % 1=InfiniteArea, 2=FiniteArea
% acatRA (Ac/At) was determined from finding the most ideal value from a 3D relation
% graph of Isp vs. AcAt vs. P_chamber
acatRA = 4.4;                                                              % Combustion Chamber Area Ratio (Ac/At)
% psiA was determined from the previously outlined relation and is the
% maximum sustainable pressure we can handle in our first engine iteration.
psiaA = 550.0;                                                             % [psia] Chamber Pressure in Absolute
% ofRA was determined from the previously outlined relation and is the
% most ideal O/F Ratio given the other two values.
ofRA = 6.0;                                                                % Oxidizer/Fuel Ratio [wt%]
ambP = 14.6959;                                                            % [psia] Pressure at Sea Level
%% Run Final CEAM
cd functions
[ispA,cstarA,aeatA,pressureA,gammaA] = CEAM(AnalysisType,acatRA,psiaA,ofRA,ambP);
%% Geometry Parameters Calculation
cd functions
[D_throat,R_throat,A_throat,D_chamber,A_chamber] = geometry_parameters(D_chamber_imp,aeatA(4),acatRA);
%% Performance Parameters Calculation
cd functions
performance_parameters(ispA(4),9.81,cstarA(3),pressureA(1)*100000,A_throat);
%% Chamber and Characteristic Length Calculation
cd functions
[L_chamber] = length_calc(D_throat,A_chamber,A_throat);
%% Wall Thickness Calculations
cd functions
wall_thickness(allowable_stress,pressureA(1)*100000,FOS,D_chamber);
%% Run Python Script
% IMPORTANT: Check README.txt
cd functions
[nozzle_contour] = runPython(gammaA(3),aeatA(4),R_throat*100);
%% Process Data
cd functions
% Creates 'contour.csv' file in [cm]
[nozzle_contour] = process_data(nozzle_contour);
%% Create Chamber
cd functions
[engine_contour] = create_chamber(nozzle_contour,L_chamber*100,D_chamber*100);
%% Plot Data in MATLAB
cd functions
plot_data(engine_contour);