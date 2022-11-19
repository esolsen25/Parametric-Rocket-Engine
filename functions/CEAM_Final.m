%% Function Declaration
function [ispA,cstarA,aeatA,pressureA,gammaA] = CEAM(acatRA,psiaA,ofRA,ambP)
    % Declaration of desired values for geometry calculation
    ispA = []; cstarA = []; aeatA = []; pressureA = []; gammaA = [];
    % Matrix Indices: 1 = Injector
    %                 2 = Comb. End
    %                 3 = Throat
    %                 4 = Exit
    
    % Returns to home directory and into /temp
    cd ../temp/
    % Runs the CEAM with C3H8O and N20 as reactants
    cprintf('green','Running Final NASA CEAM'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.'); pause(0.1); cprintf('green','.\n');
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
    cprintf('green','Done!\n\n');

    % Returns to the main directory
    cd ..\
end

