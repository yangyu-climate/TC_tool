# TC_tool

`TC_tool` is a MATLAB/NCL toolkit for diagnosing tropical cyclones in WRF
simulations. It exports WRF fields, constructs a storm track, remaps fields to
a common storm-following cylindrical coordinate system, and performs structure
and budget diagnostics.

## Capabilities

- Detect and track a simulated tropical cyclone from sea-level pressure and
  near-surface wind fields.
- Produce storm-centred radial and vertical structure diagnostics.
- Diagnose mean and eddy momentum budgets.
- Diagnose azimuthal-wavenumber kinetic-energy and available-potential-energy
  exchanges (A1--A6).
- Diagnose dry-theta or equivalent-potential-temperature PV budgets.

## Requirements

- MATLAB (verified with R2025b).
- NCL with WRF support for the preprocessing scripts.
- WRF output files using the configured prefix (normally `wrfout_d03`).
- A POSIX shell only when using the optional `Run.sh` wrappers; on Windows, use
  the equivalent `Run.m` entry points.

Run every MATLAB module from its own directory. Its entry point loads the
repository [start.m](start.m) script and shared tools.

## Project layout

| Directory | Purpose |
| --- | --- |
| `Pre/SLP` | Export fields used to detect and track the cyclone. |
| `Pre/BGT` | Export fields required by MBG, KEBG, and PVBG. |
| `Pre/PHY` | Export physical and radial-structure fields. |
| `TC_track` | Detect centres and create the storm-track file. |
| `TC_Rfield` | Diagnose storm-following radial and vertical structure. |
| `TC_MBG` | Diagnose mean and eddy momentum budgets. |
| `TC_KEBG` | Diagnose azimuthal-wavenumber KE/APE energetics. |
| `TC_PVBG` | Diagnose dry-theta or theta-e PV budgets. |
| `Tool_box/Tools` | Shared geometry, tracking, interpolation, and I/O utilities. |

## Workflow

1. In the relevant `Pre/*/NCL_WRF_DATA.ncl` scripts, set `dir` to the WRF
   experiment directory. Check each selected script independently: all must
   refer to the same experiment.
2. Run the required preprocessing scripts:
   - `Pre/SLP` for cyclone tracking.
   - `Pre/BGT` for MBG, KEBG, and PVBG.
   - `Pre/PHY` for Rfield.
3. From `TC_track`, run `Run.m` to create
   `TC_track/Result/Track_data.mat`.
4. In the target diagnostic module, configure the case period, grid, input
   paths, track path, file prefix, and output name in its `*_config.m` file.
5. From that module directory, run `Run.m`. The KEBG entry point always runs
   remapping, azimuthal processing, and the energy calculation in that order.

Keep preprocessing files, tracks, and diagnostic outputs separate for each
experiment (for example, CTRL and NoTCFB).

## Module documentation

- [TC_track](README/README.TC_track)
- [TC_Rfield](README/README.TC_Rfield)
- [TC_MBG](README/README.TC_MBG)
- [TC_KEBG](README/README.TC_KEBG)
- [TC_PVBG](README/README.TC_PVBG)

## Author and notices

Yang Yu (`yang.yu@whoi.edu`)

Copyright (c) 2026 Yang Yu. All rights reserved unless otherwise stated.
Third-party content under `Tool_box` retains its own copyright, licence, and
citation requirements.
