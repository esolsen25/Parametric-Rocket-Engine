%% Function Declaration
% Developer: Jonah Gimmi
function [AcAt] = AutoCEA_AcAtFinder(Pc_Psia,ofR,ambP)
    %% Typical Values
    AcAtA = [1:0.1:10];                                                    % [-] Contraction Ratio Array
        % Contraction Ratio Array where 1 is minimum possible AcAt and 10
        % is larger than most small combustion chambers.
    PercentIspFDesired = 0.95;                                             % [-] Percent Isp Desired
        % Percent of maximum Isp desired from finite analysis to find AcAt,
        % where 95% is the typical value.
    %% Variable Declaration
    AcAt = [];                                                             % [-] Contraction Ratio
    IspAF = [];                                                            % [s] Specific Impulse Array
    %% Finite Area CEAM
    % Calculates Isp matrix containing all values for given values for CEAs
    % from all given AcAt values.

    % Directs to \temp\ containing 'CEA.p' in order to access the CEA()
    % function.
    cd ..\temp\
    for NAcAt = 1:length(AcAtA)
        % Calls NASA 'CEA.p'
        sim=CEA('problem','rocket','equilibrium','fac','acat',AcAtA(NAcAt), ...
            'p,psia',Pc_Psia,'pi/p',Pc_Psia/ambP,'o/f',ofR,'reactants', ...
            'fuel','C3H8O','C',3,'H',8,'O',1,'wt%',100,'h,kJ/mol',-272.8, ...
            't(k)',298.15,'rho,g/cc',0.785,'oxid','N2O','N',2,'O',1,'wt%', ...
            100,'h,kJ/mol',82.05,'t(k)',298.15,'rho,g/cc',1.220,'end');
        IspAF = [IspAF,sim.output.eql.isp];
    end
    
    % Only uses IspAF at nozzle exit
    IspVF = IspAF(4,:);
    % Isp curve appears to fit a logarithmic regression curve, starts at a
    % point and approaches an upper limit as x->inf
    MaxIspF = IspVF(end);
        % Max Isp will occur at the end of the matrix, approaches upper
        % limit.
    MinIspF = IspVF(1);
        % Min Isp is the first datapoint within the matrix.

    % Finds average reasonable value using the total difference and our
    % desired Isp percentage.
    DiffIspF = MaxIspF - MinIspF;
    DesiredIspF = MinIspF+(PercentIspFDesired*DiffIspF);

    % Rounds AcAt to the nearest value previosly valculated
    for n=1:length(IspVF)
        if (IspVF(n) <= DesiredIspF) && (DesiredIspF < IspVF(n+1))
            LowerBound = IspVF(n);
            UpperBound = IspVF(n+1);
            DiffDown = DesiredIspF - IspVF(n);
            DiffUp = IspVF(n+1) - DesiredIspF;
            if DiffDown < DiffUp
                AcAt = AcAtA(n);
            else
                AcAt = AcAtA(n+1);
            end
        end
    end
    
    %% Output to Command Window
    % Outputs our calculated ideal values
    cprintf('*black','Ideal Finite CEAM Parameters:\n')
    fprintf('OF_Ratio = %.0f [-]\nAcAt = %.2f [-]\n\n',ofR,AcAt);

    % Directs back to main directory
    cd ..\
end

