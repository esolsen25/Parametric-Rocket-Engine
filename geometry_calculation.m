%% Script Details
% Developer: Evan Olsen
% Last Updated: 11-12-2022 s10:37PM
% Purpose: Calculate Geometry Specifications for Rao Nozzle
% Iteration: HalfCat Liquid Rocket Engine
% Team: RIT Liquid Propulsion
clc; clear;
%% NASA CEAM Initialization
% CEAM Input Values
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

% Declaration of desired values for geometry calculation
ispA = []; cstarA = []; aeatA = []; pressureA = []; gammaA = [];
% Matrix Indices: 1 = Injector
%                 2 = Comb. End
%                 3 = Throat
%                 4 = Exit

% Runs the CEAM with C3H8O and N20 as reactants
cprintf('green','Running NASA CEAM'); pause(0.5); cprintf('green','.'); pause(0.5); cprintf('green','.'); pause(0.5); cprintf('green','.\n\n');
sim=CEA('problem','rocket','equilibrium','fac','acat',acatRA,'p,psia',psiaA,'pi/p', ...
    psiaA/ambP,'o/f',ofRA,'reactants','fuel','C3H8O','C',3,'H',8,'O',1,'wt%', ...
    100,'h,kJ/mol',-272.8,'t(k)',298.15,'rho,g/cc',0.785,'oxid','N2O', ...
    'N',2,'O',1,'wt%',100,'h,kJ/mol',82.05,'t(k)',298.15,'rho,g/cc',1.220, ...
    'end');
% Look up documentation for NASA CEAM for further configuration
% Calculating the desired values from CEAM
ispA = [ispA,sim.output.eql.isp];
cstarA = [cstarA,sim.output.eql.cstar];
aeatA = [aeatA,sim.output.eql.aeat];
pressureA = [pressureA,sim.output.eql.pressure];
gammaA = [gammaA,sim.output.eql.gamma];
%% Throat Area and Radius Calculation
% Equation Variables
AeAt = aeatA(4);                                                           % [-] Exit to Throat Area Ratio
AcAt = acatRA;                                                             % [-] Chamber to Throat Area Ratio

% Equation - Chamber Parameters
D_chamber_imp = 2;                                                         % [in] Chamber Diamater - Extensive Property
D_chamber = D_chamber_imp/39.37;                                           % [m] Chamber Diameter converted from [in] to [m]
R_chamber = D_chamber/2.0;                                                 % [m] Chamber Radius
A_chamber = pi*(D_chamber/2)^2;                                            % [m^2] Chamber Area
% Equation - Throat Parameters
A_throat = A_chamber/AcAt;                                                 % [m^2] Area at the throat
R_throat = (A_throat/pi)^0.5;                                              % [m] Radius of Throat
D_throat = 2*R_throat;                                                     % [m] Diameter of Throat
% Equation - Exit Parameters
A_exit = AeAt*A_throat;                                                    % [m^2] Area of the Exit
R_exit = (A_exit/pi)^0.5;                                                  % [m] Radius of the Exit
D_exit = 2*R_exit;                                                         % [m] Diameter of the Exit
%% Ideal Mass Flowrate in Combustion Chamber calculation
% Equation Variables
Isp = ispA(4);                                                             % [s] Specific impulse at the exit
g = 9.81;                                                                  % [m/s^2] Acceleration Due to Gravity
c_star = cstarA(3);                                                        % [m/s] Characteristic Velocity at the Throat (Constant)
pressure_chamber = pressureA(1)*100000;                                    % [Pa] Chamber Pressure converted from [bar] to [Pa]

% Equation - Mass Flow Calculation
m_flowrate = A_throat*pressure_chamber/c_star;                             % [kg/s] Mass Flowrate through entire engine

% Equation - Thrust Calculation
thrust = Isp*g*m_flowrate;                                                 % [N] Thrust at engine exit
%% Chamber Length Calculation
% Equation Variables
D_throat_cm = D_throat*100.0;                                              % [cm] Throat Diameter in [m] Converted to [cm]

% Equation - Chamber Length (Only Defined for [cm])
% Source: http://www.braeunig.us/space/propuls.htm
L_chamber_cm = exp(0.029*log(D_throat_cm)^2+0.47*log(D_throat_cm)+1.94);   % [cm] Ideal Chamber Length
L_chamber = L_chamber_cm/100.0;                                            % [m] Ideal Chamber Length in [cm] Converted to [m]

% Equation - Chamber Volume
% Source: https://risacher.org/rocket/eqns.html
V_chamber = 1.1*A_chamber*L_chamber;                                       % [m^3] Ideal Chamber Volume

% Equation - Characteristic Length
% Source: https://risacher.org/rocket/eqns.html
L_characteristic = V_chamber/A_throat;                                     % [m] Characteristic Length
%% Wall Thickness Calculations
% Following values are given from ASTM Standards for Aluminum 2024-T4
P_chamber = pressure_chamber;                                              % [Pa] Chamber Pressure - Conversion from [bar] to [Pa]
allowable_stress = 96.5*10^6;                                              % [Pa] Allowable stress of aluminum
% Calculates minimum and safe allowable wall thickness given pressure and
% given a factor of safety for our engine.
min_wall_thickness = P_chamber*D_chamber/(2*allowable_stress);             % [m] Minimum wall thickness
FOS = 3.0;                                                                 % [-] Factor of Safety
safe_wall_thickness = min_wall_thickness * FOS;                            % [m] Safe Wall Thickness
%% Output and Conversions
cprintf('*black','Performance Parameters:\n');
fprintf('Generated Thrust = %.3f [lbf]\nm_flowrate = %.4f [kg/s]\n',thrust/4.448,m_flowrate);
cprintf('*black','Geometry Parameters:\n');
fprintf('D_chamber = %.3f [in]\nD_throat = %.3f [in]\nD_exit = %.3f [in]\nL_chamber = %.2f [in]\n',D_chamber*39.3701,D_throat*39.3701,D_exit*39.3701,L_chamber*39.3701);
cprintf('*black','Wall Thickness:\n')
fprintf('safe_wall_thickness = %.3f [in]\n',safe_wall_thickness*39.3701)
%% Run Python Script
% IMPORTANT: Requires Python 3.8, as well as Numpy and Matplotlib packages
% in order to run correctly. Requires additional configuration of MATLAB's
% API in order to run the script from command window.

% Check version: 'pyversion'

% Example configuration after installation of Numpy and Matplotlib through
% Python's normal procedure, in this case PyCharm Educational:
% pysis = py.sis.path;
% pysis.append('C:/Users/*USER*/PycharmProjects/pythonProject/venv/Lib/site-packages')
% np = py.importlib.import_module('numpy');

% Additional Variables to Convert to '.mat'
k = gammaA(3); % [-] Specific Heat Ratio
R_throat_imp = R_throat*39.3701;

% Converting to '.mat' file:
save('to_python.mat','k','AeAt','R_throat_imp');
% Runs Geometry Calculation:
cprintf('green','\nRunning Python script'); pause(0.5); cprintf('green','.'); pause(0.5); cprintf('green','.'); pause(0.5); cprintf('green','.\n');
pyrunfile("bell_nozzle.py");
% Load calculated engine geometry into MATLAB:
load contour.mat;

% Process Data to get Autodesk Fusion360
cprintf('green','Processing data'); pause(0.5); cprintf('green','.'); pause(0.5); cprintf('green','.'); pause(0.5); cprintf('green','.\n');
contour(3,:)=[]; % Deletes -y data from third row
contour(5,:)=[]; % Deletes -y data from the fifth row
contour(7,:)=[]; % Deletes -y data from the seventh row
x_data=[contour(1,:),contour(3,:),contour(5,:)];
y_data=[contour(2,:),contour(4,:),contour(6,:)];
z_data=zeros(1,300);
xyz_data=[x_data;y_data;z_data];
processed_contour=transpose(xyz_data);
% Export Processed Data to '.csv':
writematrix(processed_contour,'contour.csv');
cprintf('green','Processed!\n');