# **CELAB 2025**

Automated MATLAB + Simulink scripts for the **Control Engineering Laboratory** (CELAB) course – University of Padova  
_Assignments on both the Accurate & Black-Box motor models_

---

## 1 Repository layout

.
├── LAB0/

│ └── sub-project-00/

│ ├── 0.final_results.m

│ ├── EstimTrial_… .m

│ ├── Controller.m

│ └── *.slx

├── LAB1/

│ └── …

├── LAB2/

│ └── …

├── LAB3/

│ └── …

└── LAB4/

└── …


*Every* **LAB x** session (`x = 0‥4`) contains **sub-projects** numbered in the order they appear in the corresponding **METHODS / ASSIGNMENT** hand-out.

Each sub-project follows one consistent structure<sup>†</sup>:

| File / folder | Role |
| :-- | :-- |
| `EstimTrial_….m`  or  `model_parameters.m` | defines plant & sensor parameters |
| `Controller.m` | computes controller parameters (PID, LQR, …) |
| `0.final_results.m` | *one-click* master script that loads everything, launches Simulink, runs validation tests, and produces the outputs listed in §&nbsp;2 |

<sup>† Minor variations exist when a particular controller requires extra helper files, but the spirit is identical.</sup>

---

## 2 End-product of **every** run <a id="end-products"></a>

* **CSV tables** &nbsp;|&nbsp; key response specs (rise time, settling time, overshoot, …)  
  &nbsp;&nbsp;↳ automatically saved to `*.csv` and echoed to the Command Window  
* **PNG plots** &nbsp;|&nbsp; response curves + parameter sweeps  
  &nbsp;&nbsp;↳ saved to `*.png` with tidy legends & captions

Both artefacts land in the same sub-project folder, so version control diffing is effortless.

---

## 3 Instructions for use

### 3.1 Pre-run checks

1. **Solver & step**  
   * Continuous-time: `ode45`   ·  Discrete-time: `Discrete (no states)`<br>
     _(Discrete models will still run with `ode45`, but it is cleaner to match the solver to the model type)._

2. **Data exchange settings**  
   *Simulink ➜ Model Settings ➜ Data Import/Export*  
   - tick **Time**, **States**, **Output**, **Signal logging**, **Data stores**  
   - set **Format** = **Dataset** (all *toWorkspace* blocks then return **Timeseries** objects)

### 3.2 Run a sub-project

1. `cd` into the desired sub-project folder.  
2. Open **`0.final_results.m`** (quickly spotted thanks to the `0.` prefix).  
3. Hit **Run**.  
   * MATLAB loads parameters & controller  
   * Simulink compiles → runs validation scenarios  
   * See §&nbsp;2 for the resulting CSV + PNG files

---

## 4 Need the quick reference again?

Jump back to **[§ 2 End-product of every run](#end-products)** to recall what artefacts to expect.

---

> *I hope you enjoy exploring these labs as much as I enjoyed crafting them!*  
> — *Lum B.*
