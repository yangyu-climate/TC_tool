# TC_tool

`TC_tool` is a MATLAB/NCL toolbox collection for tropical-cyclone diagnostics
from WRF output. It preprocesses WRF fields, detects and tracks the storm
center, remaps WRF variables into storm-following coordinates, and diagnoses
momentum, kinetic-energy, and potential-vorticity budgets.

## Project Status

- Repository: `https://github.com/yangyu-climate/TC_tool`
- Default branch: `main`
- Last README update: 2026-07-02
- Current release state: research toolbox; full numerical validation requires
  case-specific WRF-derived input data.

## Copyright

Copyright (c) 2026 Yang Yu. All rights reserved unless otherwise stated.

This repository also includes third-party MATLAB toolboxes and supporting data
under `Tool_box`. Those components keep their original copyright notices,
licenses, and citation requirements.

## Contact

For questions, bug reports, or collaboration requests, contact:

- Email: `yang.yu@whoi.edu`
- GitHub: `https://github.com/yangyu-climate/TC_tool`

## Repository Layout

```text
TC_tool/
|-- start.m              # Adds Tool_box paths for MATLAB
|-- Pre/                 # NCL preprocessing scripts for WRF output
|-- TC_track/            # Tropical cyclone center detection and tracking
|-- TC_Rfield/           # Storm-following radial structure fields
|-- TC_MBG/              # Momentum budget diagnostics
|-- TC_KEBG/             # Kinetic-energy budget diagnostics
|-- TC_PVBG/             # Potential-vorticity budget diagnostics
|-- Tool_box/            # MATLAB helper functions and third-party toolboxes
`-- README/              # Detailed module-level documentation
```

## Requirements

- MATLAB, tested with MATLAB R2021b.
- NCL with the WRF NCL scripts available through `NCARG_ROOT`.
- WRF output files using the configured domain prefix, for example
  `wrfout_d03`.
- A POSIX-compatible shell for `Run.sh` wrappers. On Windows, run each module's
  `Run.m` from MATLAB instead.

Before running MATLAB modules, start MATLAB from the repository root and run:

```matlab
start
```

This adds `Tool_box` and its configured subdirectories to the MATLAB path.

## Workflow

The usual processing order is:

1. Run the relevant `Pre` preprocessing scripts to create WRF-derived NetCDF
   files.
2. Run `TC_track` to produce `TC_track/Result/Track_data.mat`.
3. Run one or more downstream diagnostics:
   - `TC_Rfield`
   - `TC_MBG`
   - `TC_KEBG`
   - `TC_PVBG`

Each module has a `Run.m` entry point. For example:

```matlab
cd TC_track
Run
```

## Preprocessing

`Pre` contains three preprocessing groups:

- `Pre/SLP`: fields required by `TC_track`.
- `Pre/PHY`: fields required by `TC_Rfield`.
- `Pre/BGT`: fields required by `TC_MBG`, `TC_KEBG`, and `TC_PVBG`.

Each group contains:

- `NCL_WRF_DATA.ncl`
- `Run.sh`
- `link_wrf_data.sh`

The preprocessing scripts are case-specific and may contain local absolute WRF
data paths. Update those paths only when moving the workflow to another case or
machine.

## Module Summary

### TC_track

Detects and tracks the tropical cyclone center from WRF-derived 2 km pressure,
sea-level pressure, and 10 m wind fields.

Main output:

- `TC_track/Result/Track_data.mat`

Detailed documentation:

- `README/README.TC_track`

### TC_Rfield

Uses the track file to remap WRF variables into storm-following Cartesian and
radial grids, then produces radial and selected-level diagnostics.

Main outputs:

- `TC_Rfield/Result/MVCT`
- `TC_Rfield/Result/SLICE`
- `TC_Rfield/Result/VLEVEL`

Detailed documentation:

- `README/README.TC_Rfield`

### TC_MBG

Calculates mean and eddy radial/tangential momentum budget terms in a
storm-following cylindrical coordinate system.

Main outputs:

- `TC_MBG/Result/Data`
- `TC_MBG/Result/azimuthally`
- `TC_MBG/Result/MBG`

Detailed documentation:

- `README/README.TC_MBG`

### TC_KEBG

Diagnoses tropical-cyclone kinetic-energy and available-potential-energy budget
terms by azimuthal wavenumber.

Main outputs:

- `TC_KEBG/Result/Data`
- `TC_KEBG/Result/azimuthally`
- `TC_KEBG/Result/KEBG`

Detailed documentation:

- `README/README.TC_KEBG`

### TC_PVBG

Diagnoses generalized Ertel potential-vorticity budgets using either dry
potential temperature or equivalent potential temperature.

Main outputs:

- `TC_PVBG/Result/Data`
- `TC_PVBG/Result/PVBG`

Detailed documentation:

- `README/README.TC_PVBG`
- `TC_PVBG/doc/PV_Budget_Equations.docx`

## Key Inputs

Most downstream modules require:

- `TC_track/Result/Track_data.mat`
- Preprocessed WRF files in one of:
  - `Pre/SLP/DATA`
  - `Pre/PHY/DATA`
  - `Pre/BGT/DATA`

`Track_data.mat` is expected to contain:

- `TIME`
- `LON`
- `LAT`
- `SLP`
- `SWD`
- `LON_W`
- `LAT_W`

## Current Verification Notes

Static MATLAB checks were last run with MATLAB R2021b on 2026-06-25:

- First-party workflow files: 24 MATLAB files, 0 severe `checkcode` messages.
- `Tool_box`: 732 MATLAB files, 0 severe `checkcode` messages.

Full numerical validation requires real WRF-derived input data and a generated
`TC_track/Result/Track_data.mat` file.

## Detailed Documentation

For scientific assumptions, equations, saved variables, and module-specific
configuration options, read the module README files under `README/`.
