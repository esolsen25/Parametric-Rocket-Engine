function [safe_wall_thickness] = wall_thickness(allowable_stress,P_chamber,FOS,D_chamber)
% Calculates minimum and safe allowable wall thickness given pressure and
% given a factor of safety for our engine.
min_wall_thickness = P_chamber*D_chamber/(2*allowable_stress);             % [m] Minimum wall thickness                                                                 % [-] Factor of Safety
safe_wall_thickness = min_wall_thickness * FOS;                            % [m] Safe Wall Thickness
%% Output and Conversions
cprintf('*black','Wall Thickness:\n')
fprintf('safe_wall_thickness = %.3f [in]\n',safe_wall_thickness*39.3701)
cd ../
end

