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
- Set desired input values outlined in the first section for a given rocket
  engine, run code.

FUTURE IDEAS:
- Import capability to produce tank specifications neccessary to power the
  desired rocket engine generated.
- Injector specifications, mostly preference.
- Thermal analysis given burn time from tank specifications and temperature
  at steady state from NASA 'CEA.p'
- Regenerative cooling, ablative cooling, film cooling options for generated
  geometry.
