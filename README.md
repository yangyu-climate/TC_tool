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
- Diagnose dry-theta or equivalent-potential-temperature PV budgets using the
  full local absolute-vorticity vector.

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
| `Pre/BGT` | Export fields required by MBG, KEBG, and PVBG, including the single canonical `omega=dp/dt` interface. |
| `Pre/PHY` | Export physical and radial-structure fields. |
| `TC_track` | Detect centres and create the storm-track file. |
| `TC_Rfield` | Diagnose storm-following radial and vertical structure. |
| `TC_MBG` | Diagnose mean and eddy momentum budgets. |
| `TC_KEBG` | Diagnose azimuthal-wavenumber KE/APE energetics. |
| `TC_PVBG` | Diagnose dry-theta or theta-e PV budgets. |
| `Tool_box/Tools` | Shared geometry, tracking, interpolation, and I/O utilities. |

## Workflow

### 1. Prepare preprocessing inputs

In `Pre/TC_pre_config.sh`, set `source_dir` to the read-only WRF experiment
directory and set `filename` to the WRF prefix (normally `wrfout_d03*`).
Each preprocessing `Run.sh` calls `link_wrf_data.sh`, which
creates or refreshes symbolic links to the matching WRF files in its own
`DATA` directory before starting NCL. Derived NetCDF fields are therefore
written in the directory expected by the MATLAB modules.
The NCL scripts deliberately process only these symbolic links, so rerunning
preprocessing does not mistake previously derived `*.nc` products for WRF
input. Use `link_wrf_data.sh` rather than copying raw WRF files into `DATA`.

The same WRF input set can safely be linked into each required directory:

```text
Pre/SLP/DATA/   # needed for TC_track
Pre/BGT/DATA/   # needed for TC_MBG, TC_KEBG, and TC_PVBG
Pre/PHY/DATA/   # needed for TC_Rfield
```

The link helper never moves source files or removes `DATA`. It refuses to
replace a regular file, preserving preprocessing output and making conflicting
input names explicit. Keep the original WRF archive read-only.

### 2. Preprocess WRF output

Run the required preprocessing scripts:

- `Pre/SLP` for cyclone tracking.
- `Pre/BGT` for MBG, KEBG, and PVBG.
- `Pre/PHY` for Rfield.

### 3. Build the storm track

From `TC_track`, run `Run.m` to create
`TC_track/Result/Track_data.mat`.

### 4. Run a diagnostic module

In the target diagnostic module, configure the case period, grid, input
paths, track path, file prefix, and output name in its `*_config.m` file.

From that module directory, run `Run.m`. The KEBG entry point always runs
remapping, azimuthal processing, and the energy calculation in that order.

Keep preprocessing files, tracks, and diagnostic outputs separate for each
experiment (for example, CTRL and NoTCFB).

New preprocessing and MATLAB result files use timestamps such as
`2011-07-28_00_00_00`, which work on Windows, Linux, and macOS. Readers still
recognize existing Linux files that use the older `00:00:00` form.

`Pre/BGT` exports pressure vertical velocity only as `*_omega.nc` with variable
`omega` in `Pa s-1`; this is the canonical interface used by KEBG. It also
exports `u`, `v`, `RUBLTEN`, and `RVBLTEN` in earth-relative east/north
coordinates. Regenerate all preprocessing and downstream results after updating
from an older version that exported WRF grid-relative wind components.

For heating-dependent KEBG/PVBG diagnostics, export the WRF tendency fields
available for the chosen physics: `H_DIABATIC`, `RTHRATEN`, `RTHBLTEN`,
`RTHCUTEN`, and, when shallow convection is enabled, `RTHSHTEN`. The
preprocessor accepts missing components and records what was available; inspect
this metadata before interpreting a heating budget. The `Run.sh` wrappers run
NCL in the foreground and write its log to `running.out`, so failures are
returned to the calling shell.

## Module documentation

- [TC_track](README/README.TC_track)
- [TC_Rfield](README/README.TC_Rfield)
- [TC_MBG](README/README.TC_MBG)
- [TC_KEBG](README/README.TC_KEBG)
- [TC_PVBG](README/README.TC_PVBG)

## Author and notices

Yang Yu (`yang.yu@whoi.edu`)

Copyright (c) 2026 Yang Yu. All rights reserved unless otherwise stated.
