# TC_KEBG

`TC_KEBG` diagnoses selected scale-interaction energy conversions in one TC
simulation.  Its A1--A6 nomenclature follows Bhalachandran et al. (2020), but
the implementation is independently checked against the cylindrical,
pressure-coordinate momentum and thermodynamic equations.  It intentionally
contains no CTRL--NoTCFB comparison or RI-selection module.

## Run order

1. Run `../Pre/BGT/NCL_WRF_DATA.ncl`. Its output must include `*_omega.nc`
   (`omega = dp/dt`, Pa s-1) and every enabled heating tendency.
   `RTHCUTEN` is exported only when it exists in WRF output. Confirm NetCDF
   metadata before every experiment.
2. Set the case, time range, track and input paths in `TC_KEBG_config.m`.
3. Run `Run.m` (or `Run.sh`).  The scripts always execute in this order:
   `TC_KEBG_mvct.m` -> `TC_KEBG_azimuthally.m` -> `TC_KEBG_calculate.m`.

## File roles

| File | Function |
| --- | --- |
| `TC_KEBG_config.m` | Case paths, cylindrical grid, isobaric levels and constants. |
| `TC_KEBG_mvct.m` | Makes storm-relative cylindrical fields and carries `p`, `u`, `v`, `T`, `theta`, `H_DIABATIC` (treated as `H_theta`), and `omega`. |
| `TC_KEBG_azimuthally.m` | Stores azimuthal means and perturbations; preserves the full fields used by the Fourier calculation. |
| `TC_KEBG_calculate.m` | Interpolates to pressure levels; Fourier-decomposes every field; evaluates Appendix A terms A1--A6. |

## Output

Each `Result/KEBG/KEBG_*.mat` file contains fields on `(pressure, radius,
wavenumber)` and mass-weighted domain means (`*_int`).  The grouped quantities
use WN0, WN1--2, WN3+, and all retained non-Nyquist wavenumbers.  The Nyquist
harmonic is excluded to avoid one-sided Fourier double counting.

| Field | Meaning |
| --- | --- |
| `KE`, `APE` | Specific energy (`J kg-1`) by azimuthal wavenumber. |
| `A1` | WN0-to-WNn barotropic KE transaction (`W kg-1`; positive: mean to eddy). |
| `A2` | Nonlinear eddy-to-eddy KE transfer (`W kg-1`). `A2_m_low` and `A2_m_high` group contributions by `abs(m) = 1--2` and `abs(m) >= 3`. |
| `A3`, `A4` | WN0 and WNn diabatic APE generation (`W kg-1`). |
| `A5`, `A6` | WN0 and WNn APE-to-KE conversion (`W kg-1`). |

## Physical meaning and sign conventions

### Coordinates, averaging, and units

All fields are expressed in storm-centred cylindrical pressure coordinates
`(r,phi,p)`. The supplied track is the default horizontal origin; `u` is the
storm-relative **radial** wind (positive outward), `v` is the storm-relative
**tangential** wind (positive counter-clockwise), and `omega=dp/dt` is positive
downward. `WN 0` is the azimuthal mean. A positive WN `n` contains its positive
and negative Fourier partners, so its KE and APE are real one-sided spectral
energies. Pointwise energy is `J kg-1`; rate terms are `W kg-1`. Variables with
the `_int` suffix are mass-weighted domain means over the configured pressure
and radial domain, not total Watts.

The translational velocity removed from the horizontal wind is a geodesic
finite-difference velocity of that same supplied track, with no independent
wind track or smoothing. `u_TC`, `v_TC`, and `center_motion_method` are saved
with every output so the moving-frame tendency can be audited.

The dry static-stability factor is

`gamma = -[(theta/T) Rd/(Cp p)] / (d theta/dp)`.

Only statically stable points (`gamma>0`) define the positive-definite local
APE norm. Columns with incomplete azimuthal coverage and grid points with an
undefined APE norm are excluded from the affected diagnostics; inspect
`azimuth_valid_column` before interpreting a domain mean.

### Energy reservoirs

`KE(n) = 1/2 [F_uu(n)+F_vv(n)]` is kinetic energy at WN `n`. In the default
dimensionally consistent convention,

`APE(0) = 1/2 Cp gamma (<T>-<T>_area)^2`,

`APE(n) = 1/2 Cp gamma F_TT(n)` for `n>0`.

`<T>_area` is the horizontal area mean inside the configured radius on each
pressure surface. Thus WN0 APE measures the radial/vertical departure of the
azimuthal mean temperature from that area reference; WNn APE measures the
temperature variance at that azimuthal scale. These are local dry-APE norms,
not moist static energy or a globally unique Lorenz APE reservoir.

### A1: mean--eddy kinetic-energy transaction

`A1(n)` is the barotropic transaction between WN0 KE and WN `n` KE. Positive
`A1(n)` means **WN0 loses KE and WN n gains KE**; negative values mean eddy KE
is transferred back to the azimuthal mean. It arises from eddy momentum fluxes
acting on radial and pressure gradients of the mean radial/tangential wind,
including cylindrical curvature terms. `A1_WN0=-sum(A1(n),n>0)` is the paired
mean-flow loss/gain and is provided to check the mean--eddy exchange sign.

### A2: nonlinear multiscale KE transfer

`A2(n)` is the net nonlinear KE transfer into WN `n` from triad interactions.
It includes nonlinear momentum advection and its radial/vertical flux-divergence
form in cylindrical pressure coordinates. Positive `A2(n)` means net KE gain by
the target WN; negative means net loss by that WN. This is a redistribution
among resolved azimuthal scales, not a KE source. `A2_m_low` and `A2_m_high`
partition the summed contributions by `abs(m)=1--2` and `abs(m)>=3`.

When enabled, `A2_triad(p,r,target_n,interacting_m)` is the individual A2
contribution to `target_n`; `A2_k_WN=target_n-interacting_m` supplies the third
triad index. It is not a unique one-way donor--receiver matrix: both `k` and
`m` are active members of each nonlinear interaction. Summing its fourth
dimension reconstructs `A2` for every nonzero target WN.

### A3/A4: diabatic generation of APE

`A3` is WN0 APE generation by the covariance of mean temperature anomaly and
mean diabatic temperature heating. `A4(n)` is the corresponding in-scale
generation at WN `n` through `F_HT(n)`. Positive values create APE; negative
values destroy it. The input WRF tendencies are treated as potential-temperature
tendencies and converted before this calculation using
`H_T=(T/theta)H_theta`. The default total heating is microphysical latent,
radiative, PBL, and available cumulus theta tendencies; consult
`heating_components_available` to identify absent optional components.

### A5/A6: conversion from APE to KE

`A5` (WN0) and `A6(n)` (WNn) are `-Cp omega T/p` covariance conversions.
Positive values mean APE is converted to KE; the paired APE budget receives the
same term with a negative sign. With the convention `omega>0` downward, a warm
anomaly rising (`omega<0`, `T anomaly>0`) produces positive conversion.

### Diagnostic equation closure

For WN0, the selected-pathway right-hand sides are
`KE_rhs=A1_WN0+A5` and `APE_rhs=A3-A5`. For WN `n>0`, they are
`KE_rhs=A1+A2+A6` and `APE_rhs=A4-A6`. `KE_tendency` and `APE_tendency` are
finite differences of the respective diagnosed spectral energy reservoirs at
adjacent output times. Consequently, `KE_residual=KE_tendency-KE_rhs` and
`APE_residual=APE_tendency-APE_rhs` are **unresolved remainders**, not named
physical parameterizations. They contain omitted transport, pressure work,
friction, diffusion, boundary fluxes, coordinate/discretization effects, and
any mismatch between the local APE norm and the full thermodynamic energy
equation.

`lon_TC/lat_TC` are the coordinates used for the cylindrical centre;
`center_slp` is the SLP at that centre. The supplied `lon_track/lat_track` is
the sole centre definition.

`Save_full_triad_tensor` defaults to `false`. When explicitly set to `true`, each output also stores
`A2_triad(pressure,radius,target_n,interacting_m)` in single precision.
`A2_target_WN`, `A2_m_WN`, and `A2_k_WN=target_n-interacting_m` define every
triad index. This is the complete resolved contribution tensor to each target
WN, not a unique one-way donor label because both `k` and `m` participate in a
nonlinear triad. It requires MAT v7.3 and, at the default grid, about 2.9 GB
per output time.

`H_DIABATIC` and the WRF radiation, PBL, and cumulus tendencies are treated
as potential-temperature tendencies (`K s-1`). `TC_KEBG_calculate.m` converts
their sum to temperature heating using `H_T=(T/theta) H_theta` before A3/A4.
If a case writes temperature rather than potential-temperature tendencies, set
`cfg.calc.Heating_is_theta_tendency = false` only after metadata verification.

`cfg.calc.APE_convention='dimensionally_consistent'` is the default: APE and
A3/A4 include a factor `Cp` and therefore have `J kg-1` and `W kg-1` units.
`'paper_literal'` omits that factor to reproduce the printed A3/A4 notation;
because the printed gamma already contains `1/Cp`, its A3/A4 values have
`K s-1` rather than energy-rate units. Each output records the selected
convention. Do not combine results from the two conventions.

The cylindrical remapping uses great-circle distance and initial bearing from
the selected centre (the supplied track by default). It never uses the legacy fixed-grid-distance
approximation. Spectral columns with incomplete azimuthal coverage are marked
invalid and excluded; they are not filled with an azimuthal mean.

## Required checks

The calculation runs an analytic self-test by default: axisymmetric fields
must have zero eddy exchange, and a single cosine harmonic must satisfy the
one-sided Parseval APE relation. Before interpreting a case, also verify:

1. NetCDF dimensions and units of `p`, `omega`, and all heating components.
2. The track centre and its time alignment with every WRF output time.
3. A1 mean--eddy sign reversal and the sensitivity to radial/vertical limits.
4. A2 convergence with azimuthal resolution and wavenumber truncation.
5. `heating_components_available` in every remapped input file; a missing
   optional tendency is zero, not an inferred substitute.

This is a diagnostic of selected exchanges plus a residual closure, not a
process-separated total-energy budget. Friction, diffusion, pressure work and
open-boundary fluxes are not separately diagnosed. `A2` is the total eddy-to-eddy transfer into each WN and is
also grouped by interacting m. This is not a unique pairwise donor--receiver
transfer; the optional full triad tensor is disabled by default because of its
size.
