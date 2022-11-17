function [L_chamber] = length_calc(D_throat,A_chamber,A_throat)
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

% Command Line Output in Imperial
cprintf('*black','Length Parameters:\n');
fprintf('L_chamber = %.2f [in]\nL_characteristic = %.2f [in]\n', ...
    L_chamber*39.3701,L_characteristic*39.3701);
cd ..\
end

