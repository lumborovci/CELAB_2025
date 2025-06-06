# **CELAB 2025**

Automated MATLAB + Simulink scripts for the **Control Engineering Laboratory** (CELAB) course – University of Padova  
_All Validation Tests on the Accurate Models prescribed in the Laboratory Handouts_

---

*Every* **LAB x** session (`x = {0,1,2,3,4}`) contains **sub-projects** ordered as they appear in the corresponding **METHODS / ASSIGNMENT** Paper.

Each sub-project follows one consistent structure (the `_xxx` part of the filename is specific to the sub-project terminology used):

| FileDelimiter_xxx.filetype | Role |
| :-- | :-- |
| `Plant_xxx.m` | The first file to be run. Defines Plant, Sensor and Actuator Parameters |
| `Controller_xxx.m` | The second file to be run, in the form of a script or a standalone function. Sets up and computes Controller Parameters (ex: PID, Error-Space SSM, LQR, …) |
| `Model_xxx.slx` | The main Simulink Model which contains all Subsystem References |
| `A_final_results.m` or `A_final_measurements.m`  | *One-click* master script that loads the previous files, launches the Simulink Model, runs validation tests, and produces the outputs outlining Control Performance |


---

## 2 End-outputs of **every** run <a id="end-products"></a>

* **CSV tables** &nbsp;|&nbsp; display the main response metrics (For Step Inputs: rise time, settling time, overshoot. For Nonlinear References: RMS Error, Peak-to-Peak Error, etc.)  
  &nbsp;&nbsp;↳ automatically saved to `*.csv` and displayed in the Command Window as the sub-project is run  
* **PNG plots** &nbsp;|&nbsp; display the response curves + sweeps with respect to a specific parameter (ex: Sweeping for the reference amplitude, sampling time, method of discretization,etc.)  
  &nbsp;&nbsp;↳ saved to `*.png` with the relevant legends, annotations & captions

All outputs are saved in the same directory where the sub-project exists and are intentionally overwritten per each run (in this version of the Repository).
Minor variations exist in the output display format, based on the controller design and performance metrics of interest.

---

## 3 Instructions for use

### 3.1 Preliminary checks:

1. **Solver & Step Settings**  
   * Continuous-time: `ode45`   ·  Discrete-time: `Discrete (no states)`<br>
     _(Discrete models will still run with `ode45`, but in case of errors, match the solver to the model type)._

2. **Model Settings**  
   *Simulink ➜ Model Settings ➜ Data Import/Export*  
   - tick **Time**, **States**, **Output**, **Signal logging**, **Data stores**  
   - set **Format** = **Dataset** (since all *toWorkspace* blocks return **Timeseries** objects)

### 3.2 Run a sub-project

1. `cd` into the desired sub-project folder.  
2. Open **`A_final_results.m`**   
3. Hit **Run**.  
   * MATLAB loads Plant & Controller parameters  
   * Simulink Model compiles → Validation scenarios are run on it 
   * The relevant CSV Tables + PNG Plots are Displayed & Saved 
---

> *I hope you enjoy exploring these labs as much as I enjoyed crafting them!*  
> — *Lum B.*
