# **CELAB 2025**

Automated MATLAB + Simulink scripts for the **Control Engineering Laboratory** (CELAB) course – University of Padova  
_Assignments on both the Accurate & Black-Box motor models_

---

*Every* **LAB x** session (`x = {0,1,2,3,4}`) contains **sub-projects** numbered in the order they appear in the corresponding **METHODS / ASSIGNMENT** Paper.

Each sub-project follows one consistent structure (the `_xxx` part of the filename is specific to the sub-project terminology used):

| FileDelimiter_xxx.filetype | Role |
| :-- | :-- |
| `Plant_xxx.m` | Defines Plant, Sensor and Actuator Parameters |
| `Controller_xxx.m` | Sets up and computes Controller Parameters (PID, LQR, …) |
| `A_final_results.m` or `A_final_measurements.m`  | *one-click* master script that loads everything, launches the Simulink Model, runs validation tests, and produces the outputs listed in §&nbsp;2 |
| `Model_xxx.slx` | The main Simulink Model which contains all Subsystem References |

---

## 2 End-outputs of **every** run <a id="end-products"></a>

* **CSV tables** &nbsp;|&nbsp; display the main response metrics (rise time, settling time, overshoot, RMS error, etc.)  
  &nbsp;&nbsp;↳ automatically saved to `*.csv` and displayed in the Command Window as the sub-project is run  
* **PNG plots** &nbsp;|&nbsp; response curves + parameter sweeps  
  &nbsp;&nbsp;↳ saved to `*.png` with the relevant legends, annotations & captions

All outputs are saved in the same directory where the sub-project exists and are intentionally overwritten per each run in this version of the Repository.
Minor variations exist in the outputs, based on the controller design and performance metrics of interest.

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
   * MATLAB loads parameters & controller  
   * Simulink compiles → runs validation scenarios  
   * The relevant CSV Tables + PNG Plots are displayed & Saved 
---

> *I hope you enjoy exploring these labs as much as I enjoyed crafting them!*  
> — *Lum B.*
