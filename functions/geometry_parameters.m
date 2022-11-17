function [D_throat,R_throat,A_throat,D_chamber,A_chamber] = geometry_parameters(D_chamber_imp,AeAt,AcAt)
% Equation - Chamber Parameters
D_chamber = D_chamber_imp/39.37;                                           % [m] Chamber Diameter converted from [in] to [m]
R_chamber = D_chamber/2.0;                                                 % [m] Chamber Radius
A_chamber = pi*(R_chamber)^2;                                            % [m^2] Chamber Area
% Equation - Throat Parameters
A_throat = A_chamber/AcAt;                                                 % [m^2] Area at the throat
R_throat = (A_throat/pi)^0.5;                                              % [m] Radius of Throat
D_throat = 2*R_throat;                                                     % [m] Diameter of Throat
% Equation - Exit Parameters
A_exit = AeAt*A_throat;                                                    % [m^2] Area of the Exit
R_exit = (A_exit/pi)^0.5;                                                  % [m] Radius of the Exit
D_exit = 2*R_exit;                                                         % [m] Diameter of the Exit

% Command Line Output in Imperial Units
cprintf('*black','Geometry Parameters:\n');
fprintf(['D_chamber = %.3f [in]\nD_throat = %.3f [in]\nD_exit = %.3f [in]\n'], ...
    D_chamber*39.3701,D_throat*39.3701,D_exit*39.3701);
cd ..\
end