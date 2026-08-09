# TC_tool

`TC_tool` is a MATLAB/NCL library for tropical-cyclone diagnostics from
WRF output.  It preprocesses fields, creates a supplied storm track, remaps
fields into a common moving cylindrical frame, and diagnoses radial structure,
momentum, multiscale energetics, and potential-vorticity budgets.

## Requirements

- MATLAB (checked with R2025b).
- NCL with WRF support for the `Pre` export scripts.
- WRF outputs with the configured prefix (normally `wrfout_d03`).
- A POSIX shell only if the optional `Run.sh` wrappers are used; on Windows use
  the corresponding `Run.m` entry point.

Before running a MATLAB module, start it from its module directory. Each
entry point calls the repository `start.m` script and adds the shared tools.

## Library layout

| Directory | Purpose | Primary output |
| --- | --- | --- |
| `Pre/SLP` | Export fields needed for centre detection and tracking. | `Pre/SLP/DATA` |
| `Pre/BGT` | Export fields for MBG, KEBG, and PVBG. | `Pre/BGT/DATA` |
| `Pre/PHY` | Export physical and radial-structure fields. | `Pre/PHY/DATA` |
| `TC_track` | Detect and construct the supplied storm track. | `TC_track/Result/Track_data.mat` |
| `TC_Rfield` | Storm-following Cartesian/radial fields. | `TC_Rfield/Result` |
| `TC_MBG` | Mean and eddy momentum budgets. | `TC_MBG/Result` |
| `TC_KEBG` | Azimuthal-wavenumber KE/APE energetics. | `TC_KEBG/Result` |
| `TC_PVBG` | Dry/equivalent-potential-temperature PV diagnostics. | `TC_PVBG/Result` |
| `Tool_box/Tools` | Shared first-party geometry, track, and I/O helpers. | — |

Third-party content under `Tool_box` retains its own copyright and citation
requirements.

## One-experiment workflow

1. Set the `dir` path in each required NCL exporter to that experiment's WRF
   output directory. The three scripts are independent: verify every edited
   script points to the same experiment before execution. Run the needed exporter(s): `Pre/SLP` for tracking,
   `Pre/BGT` for MBG/KEBG/PVBG, and `Pre/PHY` for Rfield.
2. Run `TC_track/Run.m` to create `Track_data.mat`.
3. Set the case time range, grid, track path, file prefix, and module-specific
   input/output paths in the selected `*_config.m`. Do this separately for
   CTRL and NoTCFB; do not mix their
   preprocessed files, tracks, or remapped products.
4. Run the module's `Run.m`. KEBG always runs remapping, azimuthal processing,
   and the energy calculation in that order.

## Shared diagnostic contract

- `LON/LAT` in `Track_data.mat` is the sole storm centre for all first-party
  remapping. Legacy `LON_W/LAT_W` fields remain in the track file for backward
  compatibility and are not used as a diagnostic centre.
- `CENTER_VALID` and `CENTER_HELD` identify a detected centre and a
  carry-forward placeholder, respectively. Remapping rejects held centres;
  it also rejects samples adjacent to a held centre because their translating
  velocity is undefined. Rerun `TC_track` before using any existing track file
  created without these fields.
- `tc_track_motion` calculates the translating-frame velocity by geodesic
  finite difference of that same track.
- `tc_match_track_time` selects only a nearest track point within half the
  output interval; unmatched outputs are skipped rather than silently paired.
- `tc_great_circle_xy` defines the local east/north coordinates from spherical
  great-circle distance and bearing. The first-party remappers do not use the
  old fixed-grid distance approximation.
- Remapped output stores `lon_TC`, `lat_TC`, `u_TC`, `v_TC`, and
  `center_motion_method` for provenance.

## Scientific scope and verification

`TC_KEBG` is the multiscale A1--A6 module. Its implementation uses a
dimensionally consistent local APE norm by default and writes a residual
diagnostic closure; see [TC_KEBG/README.md](TC_KEBG/README.md) for equations,
signs, units, inputs, and known limits. This residual is not a
process-separated total-energy budget: pressure work, friction, diffusion,
and boundary fluxes need additional WRF tendency diagnostics.

`TC_MBG`, `TC_PVBG`, and `TC_Rfield` retain their own diagnostic equations and
outputs, but use the same centre/time/geometry contract. Static MATLAB checks
and analytic tests of the shared helpers do not replace end-to-end validation:
before interpreting results, verify NetCDF dimensions/units, track quality,
time coverage, and sensitivity to grid and boundary choices with a real case.

For MBG, `cfg.calc.Subgrid_momentum_mode` selects either the direct WRF PBL
momentum tendency (default) or the diagnosed `kh/kv` stress divergence for the
budget sum. They are alternative representations and are never summed
together. PVBG dry-theta heating is the exported resolved set of theta
tendencies; unresolved tendencies remain in `PV_residual`.
