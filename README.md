# CELAB_2025
--- Automated Scripts for running Assignments (on the Accurate \& Black-Box models) of the CELAB Course at UNIPD

- This repository is organized according to the LAB{x}, (x: 0,1,2,3,4) Sessions organized throughout the course.
  
- Each LAB{x} Session is consequently organized in 'sub-projects' which take up subfolders, sorted in numerical order according to their appearance in the respective LAB{x} METHODS / ASSIGNMENTS Paper.

- Finally, each sub-project of any LAB{x} Session has the similar structural organization (with slight modifications based on the particular nature of the Controller type and implementation):
  ~ One 'EstimTrial---.m' file or 'model_parameters.m' file consisiting of the main parameters to be loaded for defining the plant dynamics
  ~ One 'Controller.m' file consisting of the controller parameters and method to calculate them
  ~ One 'final_results.m' file which coherently links all of the sub-project components together (MATLAB Scripts, Functions, Simulink Models and Subsystems) so that the MATLAB + Simulink Environment is set up autonomously and the Validation Tests required in each LAB{x} METHODS Paper are ran all at once, with one click from the user.

- The end outputs of each sub-project trial are:
  > Tables of the relevant Response Parameters, displayed and saved as .csv files
  > Plots of the Response Parameters and how they vary depending on what parameter is used to test them, displayed and saved as .png images

INSTRUCTIONS FOR USE:
---

PRELIMINARIES:
1. Make sure, depending on the LAB{x} Session you are testing, to have set up the correct solver and step for your system: 'ode45' for Continuous-Time Systems and 'Discrete-Time' for Discrete-Time Systems (even though I never had problems with running Discrete-Time Systems using 'ode45')
2. For the correct passing of variables and data between the MATLAB Workspace and Simulink, make sure that you enable the following in your Settings:
   - In Simulation/Model Settings/Data Import-Export:
   a. Enable 'Time','States','Output', 'Signal Logging', 'Data stores'
   b. Set the Format to 'Dataset; (the toWorkspace Variables sending Simulation data to MATLAB are 'Timmeseries' and their contents are accessed this way in the code

--
1. Open the sub-project you want to test; all the files required for running the project are found in its directory
2. Find and Open the '0.final_results.m' file in that directory (the name is delimited by a '0.' for ease of finding the file
3. Run this file, and the aforementioned end outputs should be displayed and saved as expected

I hope you enjoy using this Repo as much as I enjoyed building it!
