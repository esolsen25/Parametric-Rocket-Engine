PRE-REQUISITES:
MATLAB R2022a (Most recent version as of 11/12/2022)
>> https://matlab.mathworks.com/
cprintf() AddOn for formatted colored text
>> https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-command-window
Python 3.8
>> https://www.jetbrains.com/pycharm-edu/




PACKAGES:
-> After Python installation, run following commands in administrator shell
'py -m ensurepip --upgrade'
'pip install numpy'
'pip install matplotlib'
'pip install scipy'

-> From MATLAB Command Window
pysis = py.sis.path;
pysis.append('C:/Users/*USER*/PycharmProjects/pythonProject/venv/Lib/site-packages')
py.importlib.import_module('numpy');
py.importlib.import_module('matplotlib');

INSTRUCTIONS:
CEAM INPUTS
>> AnalysisType, Finite or Infinite Area CEA Analysis
>> acatRA, Ideal Combustion Chamber Area Ratio (Ac/At)
>> psiaA, Chamber Pressure
>> ofRA, Oxidizer/Fuel Ratio
>> ambP, Ambient pressure at given altitude
GEOMETRY INPUTS
>> D_chamber_imp, chamber diameter used as the extensive property to design around

Run code, enjoy responsibly.
