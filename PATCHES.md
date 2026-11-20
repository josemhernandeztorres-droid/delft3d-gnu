# Patches on top of DIMRset_2026.02

One commit per patch, in this order. Paths are relative to `src/`, line numbers are those of the original source.

- **portability**: Intel extensions that gfortran/g++ 14 reject, or that cpp reads differently.
- **arm64**: architecture-specific code.
- **UB-alloc**: undefined behaviour on an unallocated array or undefined pointer that Intel builds tolerate (size 0,
  assignment without effect). The fix reproduces what the Intel build does. Found with `-O0 -g -fcheck=all -fbacktrace`.
- **handle reuse**: 0050, a bug on any compiler.

None changes physics or numerics.

| Patch | File:line | Problem and fix | Kind |
|---|---|---|---|
| 0001 | `deltares_common/src/unit_utils.f90:76` | Different CHARACTER lengths in array constructor: typed constructor | portability |
| 0002 | `deltares_common/src/unit_utils.f90:77` | Same as 0001 | portability |
| 0003 | `deltares_common/src/properties.f90:1795` | Logicals compared with `==`: `.eqv.` | portability |
| 0004 | `flow1d_core/src/structures.f90:471` | Character dummy with VALUE must have constant length; the routine modifies it: local copy | portability |
| 0005 | `dflowfm_kernel/src/dflowfm_data/fm_external_forcings_data.f90:429` | `*.tim/*.bc` in a comment: cpp reads `/*` as a C comment | portability |
| 0006 | `flow1d_implicit/src/GAREADHEAD.f90:90` | FORM='binary' (Intel): unformatted + access='stream' (same behaviour) | portability |
| 0007 | `flow1d_implicit/src/MOZOPENHS.f90:16` | Same as 0006 | portability |
| 0008 | `deltares_common_c/src/cpuinfo.cpp:116` | `rdtsc` undeclared on arm64: `cntvct_el0` under `__aarch64__`; x86 unchanged | arm64 |
| 0009 | `dflowfm_kernel/src/dflowfm_data/m_map_his_precision.f90:48` | VALUE on a character(len=*) dummy that is only read: VALUE dropped | portability |
| 0010 | `ice/packages/ice_data/src/icecover_module.f90:279` | Function returns `associated(...)` in an INTEGER: LOGICAL, as its callers use it | portability |
| 0011 | `dflowfm_kernel/src/dflowfm_kernel/compute/links_to_centers.f90:72` | `!$OMP SIMD ASSERT` (Intel-only clause): `!$OMP SIMD` | portability |
| 0012 | `flow1d_implicit/src/FLHYPA.f90:275` | Trailing comma before `)` in an argument list | portability |
| 0013 | `flow1d_implicit/src/FLOW.f90:510` | Same as 0012 | portability |
| 0014 | `flow1d_implicit/src/FLOWIT.f90:398` | Same as 0012 | portability |
| 0015 | `flow1d_implicit/src/SOFLOW_wrap.f90:303` | Same as 0012 | portability |
| 0016 | `dflowfm_kernel/src/dflowfm_io/read_statistical_output.f90:124` | Character dummy with VALUE; the routine consumes the string: local copy | portability |
| 0017 | `dflowfm_kernel/src/dflowfm_data/partition.F90:6287` | `if (jampi)` on an INTEGER that is only 0/1: `== 1` | portability |
| 0018 | `dflowfm_kernel/src/dflowfm_io/caching.f90:60` | Different CHARACTER lengths in array constructor | portability |
| 0019 | `dflowfm_kernel/src/dflowfm_io/unstruc_netcdf.f90:9536, 11045` | `if (ja_icecover)` on an INTEGER 0/1/2: `btest(ja_icecover, 0)`, what Intel does (low bit). Output only | portability |
| 0020 | `dflowfm_kernel/src/dflowfm_data/unstruc_model.f90:3569` | INTEGER 0/1 used as LOGICAL: `== 1` | portability |
| 0021 | `dflowfm_kernel/src/dflowfm_io/unc_write_his.F90 (33 sites)` | Type-spec in an implied-do index (F2008) not accepted by gfortran 14: index declared in the routine | portability |
| 0022 | `dflowfm_kernel/src/dflowfm_kernel/timespace/fm_external_forcings_init.f90:426` | Same as 0021 | portability |
| 0023 | `dflowfm_kernel/src/dflowfm_kernel/compute/m_dambreak_breach_submodule.f90:31` | Symbol `dp` conflicts: the submodule repeats its parent's `use` | portability |
| 0024 | `dflowfm_kernel/src/dflowfm_kernel/timespace/fm_external_forcings_init.f90:31` | Same as 0023 | portability |
| 0025 | `dflowfm_kernel/src/dflowfm_kernel/timespace/fm_external_forcings_update.f90:58` | `ecgetvalues` is not in `time_class` (it comes from `m_meteo`, already used) | portability |
| 0026 | `dflowfm_kernel/src/dflowfm_kernel/prepost/flow_init_structurecontrol_implementation.f90:59` | `c_f_pointer`, `c_loc` not imported from `iso_c_binding` | portability |
| 0027 | `dflowfm_kernel/src/dflowfm_kernel/compute/setumod.f90:897` | `if (jasfer3D)` on an INTEGER: `btest(jasfer3D, 0)` (as Intel) | portability |
| 0028 | `m_dambreak_breach_submodule.f90:228, 273, 339` | IMPORT in a submodule procedure: `t_dambreak` is already host-associated | portability |
| 0029 | `flow_init_structurecontrol_implementation.f90:100` | CPTR of C_F_POINTER must be TYPE(C_PTR): `c_loc` into a `c_ptr` first, as line 310 does | portability |
| 0030 | `dflowfm_kernel/src/dflowfm_kernel/compute/laterals.f90:103-120` | No specific for the generic: unnamed interfaces so the type-bound procedures bind | portability |
| 0031 | `dflowfm_kernel/src/dflowfm_kernel/timespace/fm_external_forcings.f90:113` | 11 undefined references at link time: PRIVATE procedures used only by submodules are dropped by gfortran: PUBLIC | portability |
| 0032 | `dflowfm_kernel/src/dflowfm_utils/saadf.F90:10860` | `integer, external :: irand` (Intel ifport): `intrinsic :: irand` (GNU) | portability |
| 0033 | `dflowfm_kernel/src/dflowfm_kernel/timespace/nearfield.f90` | Run time, SIGSEGV: scalar assignment to an unallocated allocatable (gfortran writes to NULL, Intel does nothing): `if (allocated(...))` | UB-alloc |
| 0034 | `dflowfm_kernel/src/dflowfm_kernel/prepost/set_model_boundingbox.F90:66` | Run time, SIGSEGV: uninitialised local pointers tested with `associated()`: nullify on entry | UB-alloc |
| 0035 | `dflowfm_kernel/src/dflowfm_kernel/compute_transport/ini_transport.f90:257-263` | Run time, SIGSEGV: as 0033 | UB-alloc |
| 0036 | `dflowfm_kernel/src/dflowfm_data/inifcori.f90:163` | `size(fcori)` of a deallocated array: 0 when not allocated | UB-alloc |
| 0037 | `gridgeom/src/generalmodules.f90:158` | `size(xpl)` unallocated: 0 | UB-alloc |
| 0038 | `gridgeom/src/gridoperations.F90:1026` | `(numc > size(xz)) .or. (.not. allocated(xz))`: Fortran does not short-circuit | UB-alloc |
| 0039 | `gridgeom/src/gridoperations.F90:1032` | Same as 0038 with `xzw` | UB-alloc |
| 0040 | `gridgeom/src/gridoperations.F90:1038` | Same as 0038 with `ba` | UB-alloc |
| 0041 | `dflowfm_kernel/src/dflowfm_kernel/prepost/find1dcells.f90:92` | `size()` of an unassociated pointer (model without 1D): 0 | UB-alloc |
| 0042 | `dflowfm_kernel/src/dflowfm_kernel/prepost/addopenbndsection.f90:66` | `size(nopenbndlin)` unallocated at the first boundary | UB-alloc |
| 0043 | `deltares_common/src/malloc.f90 (`reallocP*`, 24 identical sites)` | `associated(b) .and. size(b) > 0` without short-circuit: nested `if` | UB-alloc |
| 0044 | `ice/packages/ice_data/src/icecover_module.f90:497` | `size()` of an unassociated pointer (no ice): 0 | UB-alloc |
| 0045 | `dflowfm_kernel/src/dflowfm_io/caching.f90:632` | Cache written from unallocated arrays: `allocate(x(0))`, the idiom the file already uses for `crs` | UB-alloc |
| 0046 | `dflowfm_kernel/src/dflowfm_data/m_outputconfig.f90:617` | SIGSEGV: `nc_att_set%atts` pointer left undefined for an output variable without extra attributes: zero-size set | UB-alloc |
| 0047 | `dflowfm_kernel/src/dflowfm_io/unc_write_his.F90:1513-1556 (7 sites)` | Character constructor with n = 0: gfortran evaluates `indices(0)` for the length: explicit type-spec | UB-alloc |
| 0048 | `dflowfm_kernel/src/dflowfm_data/unstruc_inifields.f90:1333` | `intent(out)` pointer `target_array_3d` not nullified before `associated()`: `=> null()`, as the sibling routine does | UB-alloc |
| 0049 | `ec_module/src/ec_typedefs.f90:107` | `tEcBCBlock%timecolumn` has no default; a constant forcing never sets it: `= 0` | UB-alloc |
| 0050 | `ec_module/src/ec_provider.F90:1651, 1973` | The `.pli` unit is closed but its number stays in `fileHandle`; `ecFileReaderFree` later closes it again. gfortran reuses NEWUNIT numbers, so another, live unit was closed: SIGSEGV at shutdown. `fileHandle = ec_undef_int` after each `close` | handle reuse (bug) |
