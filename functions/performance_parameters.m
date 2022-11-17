function [] = performance_parameters(Isp,g,c_star,P_chamber,A_throat)
% Equation - Mass Flow Calculation
m_flowrate = A_throat*P_chamber/c_star;                                    % [kg/s] Mass Flowrate through entire engine
% Equation - Thrust Calculation
thrust = Isp*g*m_flowrate;                                                 % [N] Thrust at engine exit
% Command Line Output
cprintf('*white','Performance Parameters:\n');
fprintf('Generated Thrust = %.3f [lbf]\nm_flowrate = %.4f [kg/s]\n', ...
    thrust/4.448,m_flowrate);
cd ..\
end

