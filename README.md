# Delft3D (D-Flow FM) with GNU compilers

This repository is [Deltares Delft3D](https://github.com/Deltares/Delft3D) at tag **DIMRset_2026.02**
(commit `5a4649830b1e5072caf019fb4850bbdefd9ad431`) plus 50 small patches that let the **D-Flow FM**
engine (`dflowfm`) build and run with **gfortran/g++ 14 and Open MPI**, on Linux x86-64 and arm64, with no Intel component.

- The first commit is the Deltares tag, unmodified (its tree is identical to the tag's). Each later commit is one patch.
- The patches are portability fixes (Intel extensions that gfortran rejects, an arm64 timer) and fixes for undefined
  behaviour that Intel builds happen to tolerate (unallocated arrays read with `size()`, undefined pointers, a reused
  file unit). **None changes physics or numerics.** See [PATCHES.md](PATCHES.md).
- Patch 0050 fixes a dangling file unit in `ec_provider.F90` that is a bug on any compiler; it is being reported to Deltares.
- Licences are those of Delft3D, unchanged: [LICENSE](LICENSE), AGPL-3.0, GPL-3.0, LGPL-2.1, BSD (see the `*.txt` files).
  The original README is [README.deltares.md](README.deltares.md).
- This is not a Deltares product and is not supported by Deltares.

Only the `dflowfm` executable (`dflowfm_cli_exe/dflowfm`) is built and tested. Other engines and the unit-test
targets were not built.

## Build

Requires Docker. From the repository root:

```bash
PLATFORM=linux/amd64 gnu/build.sh     # or linux/arm64
```

- `gnu/deps.Dockerfile`: Debian trixie, gfortran/g++ 14, Open MPI, NetCDF, PROJ/GDAL, Boost, preCICE 3.3.1.
- `gnu/petsc.Dockerfile`: PETSc 3.24.5 from source (the version Deltares' CI uses; Debian's 3.22.5 does not match the
  Fortran API of `solve_petsc.F90`).
- `gnu/configure.sh`: the CMake call. It sets the compiler flags that `compiler_options/gnu.cmake` lacks, as cache
  variables (no CMake file is edited); each is explained in the script.

## Test case A-1 (tilted plane)

`gnu/a1-plane/`: 200 x 100 m plane, slope 0.01, Manning n = 0.03, 50 mm/h of rain for 1 h, 2 h simulated, 2 m grid,
outflow boundary at x = 200 (`plane_neumann.ext`, water-level gradient −0.01; or `plane_critical.ext`).

```bash
cd gnu/a1-plane && OMP_NUM_THREADS=1 dflowfm --autostartstop plane.mdu
ncdump -v time,waterlevel,bedlevel,discharge_magnitude,water_balance_boundaries_out,water_balance_storage,water_balance_precipitation_total,water_balance_volume_error output/plane_his.nc > his.txt
python3 a1_his.py his.txt
```

Measured (Neumann boundary): rain 1000.00 m³; outflow after 1 h 821.30 m³; storage closure 0.0000 m³ (volume error
−4e-10 m³); mean depth at x = L/2 between 1800 and 3600 s 9.445 mm, +0.77 % against the kinematic-wave value 9.373 mm.

The x86-64 `-O2` build, the arm64 `-O0 -fcheck=all` build and the arm64 `-O2 -ffp-contract=off` build give
bit-identical his and map files on this case. Plain arm64 `-O2` differs only through GCC's FMA contraction on
aarch64 (volume error ≤ 7e-10 m³).

## Notes

- [LATERALS.md](LATERALS.md): how 2D lateral discharges are sampled in time, and settings we use when running meshes
  made for other engines.
- Known leftover: with gfortran, a stray file named `output\plane.dia` (backslash in the name) is written next to the
  correct `output/plane.dia`. It does not affect the run.
